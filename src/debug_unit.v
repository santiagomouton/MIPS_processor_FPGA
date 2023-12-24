`timescale 1ns / 1ps

module debug_unit 
#(
    parameter CLK        = 50E6,
    parameter BAUD_RATE  = 9600,
    parameter NB_DATA    = 32,
    parameter NB_REG     = 5,
    parameter N_BITS     = 8,
    parameter N_BYTES    = 4,		
    parameter NB_STATE   = 12,
    parameter N_COUNT	 = 10,
    parameter N_REGISTER = 32,
    parameter N_MEMORY_DATA = 127,
    parameter NB_ADDR = 7,
    parameter RX_DATA   = 8                        // input bits rx
) 
(
    input wire clock_i,
    input wire reset_i,
	input wire tick,
	input wire tx_rx,
    
	output wire debug_out,
	output reg [NB_DATA-1:0] o_data_mem,
	output reg write_to_register,
	output reg [NB_ADDR-1:0] o_dir_wr_mem,
    output reg en_pipeline_o,
	output reg en_read_mem,


	output wire [N_BITS-1:0] data_to_send_paraver,
	
	// in/out para obtener datos de registros
	output reg select_debug_or_wireA,
	output reg [NB_REG-1:0] addr_reg_debug,
	input  wire [NB_DATA-1:0] data_registers_debug,
	// in/out para obtener datos de memoria //implementar esto de abajo
	output reg select_debug_or_alu_result,
	output reg [NB_ADDR-1:0] addr_mem_debug,
	input  wire [NB_DATA-1:0] data_mem_debug,

	input wire [6:0] data_pc_debug,

	output wire [NB_STATE-1:0] state_paraver,
	output wire [2:0] count_paraver,
	output wire en_send_registers_paraver,
	output wire tx_done_paraver,
	output wire [2:0] count_send_bytes_paraver
);

    reg en_pipeline_reg;
	reg [2:0]count;
	// reg [6:0]o_dir_wr_mem_next;
	reg en_snd_instr;
    reg finish_rcv;
	reg rcv_instr_complete;
	reg [NB_STATE-1:0] state;
	reg [NB_STATE-1:0] next_state;
	reg en_rcv_instr;
	reg wrote;
	reg en_wait_state;
	reg mode_rcv;
	reg [7:0] mode;
	reg step_mode_en;
	reg aux_step_mode;
	reg stop_step;
	reg en_send_data_pc;

	// wire tick;
	wire read_rx;
	wire [7:0] dout;
	wire tx_done;

/*     always @(posedge clock ) begin
        if (finish_rcv)
            en_pipeline_o <= 1'b1;
        else 
            en_pipeline_o <= 1'b0;
    end */

	assign state_paraver = state;
	assign count_paraver = count;

	localparam 	[NB_STATE-1:0]          Iddle			    	=  12'b000000000001;
	localparam 	[NB_STATE-1:0]          Receive_Instruction    	=  12'b000000000010;
	localparam 	[NB_STATE-1:0]			Write_Instruction  		=  12'b000000000100;
	localparam 	[NB_STATE-1:0]			Wait_mode          		=  12'b000000001000;
 	localparam 	[NB_STATE-1:0]			Check_Operation    		=  12'b000000010000;
	localparam 	[NB_STATE-1:0]			Step_mode            	=  12'b000000100000; //32
	localparam 	[NB_STATE-1:0]			Stop					=  12'b000001000000; //64
	localparam 	[NB_STATE-1:0]			Continue  		   		=  12'b000010000000; //128
	localparam 	[NB_STATE-1:0]			Sending_data_pc    	   	=  12'b000100000000; //256
/*	
	localparam 	[NB_STATE-1:0]			Sending_count_cyles 	=  12'b001000000000; //512
	localparam 	[NB_STATE-1:0]			Sending_data_registers	=  12'b010000000000; //1024
	localparam 	[NB_STATE-1:0]			Sending_data_mem		=  12'b100000000000; //2048 */

	/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
	always @(posedge clock_i) 
		begin			
			if (reset_i)
				en_pipeline_o <= 1'b0;						
			else
				en_pipeline_o <= en_pipeline_reg;
		end
	/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
	always @(posedge clock_i) 
		begin			
			if (reset_i)
				state <= Iddle;					
			else
				state <= next_state;
		end
	/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* 	always @(posedge clock_i) 
		begin			
			if (reset_i)
				o_dir_wr_mem <= 7'b0000000;						
			else
				o_dir_wr_mem <= o_dir_wr_mem_next;
		end */
	/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

    always @(posedge clock_i)
    	begin
    		if (reset_i)
    			begin
    				rcv_instr_complete = 1'b0;
					finish_rcv <= 1'b0;
    				count <= 3'b000;
    			end  	
    		else
    			begin
    				if (en_rcv_instr)
    					begin
							if (count == 3'b100) begin
								count <= 3'b000;
								/* Si recivo 32 bits en 1 logicos significa que termino la recepcion de instrucciones */
								if (o_data_mem == 32'b11111111111111111111111111111111)
								begin
									finish_rcv <= 1'b1;
									// o_dir_wr_mem <= 7'bxxxxxxx;
								end
								else begin
									rcv_instr_complete <= 1;
								end
							end
							else if (read_rx) begin
								o_data_mem <= {dout, o_data_mem[NB_DATA    -1:8]};
								count <= count + 1;
							end
							else begin
								rcv_instr_complete <= 0;
							end    												
    					end		    			
		    		else
		    			begin		    			
		    				count <= count;
							rcv_instr_complete <= 0;
		    			end 			
    			end
    	end

	always @(posedge clock_i)
		begin
			if (reset_i)
				begin
					o_dir_wr_mem <= 7'b0000000;
					write_to_register <= 1'b0;
				end	
			else
				begin
					if (en_snd_instr)
						begin
							// count <= 3'b000;
							write_to_register <= 1'b1;
    						en_snd_instr <= 0;
							o_dir_wr_mem <= o_dir_wr_mem + 1;
    						wrote <= 1;
						end
					/* else if (read_rx)
						begin
							o_data_mem <= {dout, o_data_mem[NB_DATA    -1:8]};
							count <= count + 1;
						end   */			
					else
						begin
							wrote <= 0;
							write_to_register <= 1'b0;
						end	  
				end
		end

	always @(posedge clock_i)
		begin
			if (reset_i)
				begin
					mode_rcv <= 1'b0;
					mode <= 8'b00000000;
				end	
			else
				begin
					if (en_wait_state)
						begin
							if (read_rx)
							begin
								mode_rcv <= 1'b1;
								mode <= dout;
							end
						end		    			
					else
						begin
							mode_rcv <= 1'b0;
						end	  
				end
		end

	always @(posedge clock_i)
		begin
			if (reset_i)
				begin
					// aux_step_mode <= 1'b0;
					stop_step <= 1'b0;
				end	
			else
				begin
					if (step_mode_en)
						begin
							//aux_step_mode ? (stop_step <= 1'b1) : (aux_step_mode <= 1'b1);
							// if (aux_step_mode)
							// begin
								stop_step <= 1'b1;
							// end
							// else begin
							// 	aux_step_mode <= 1'b1;
							// end
						end		    			
					else
						begin
							// aux_step_mode <= 1'b0;
							stop_step <= 1'b0;
						end	  
				end
		end

reg [2:0] count_send_bytes;
reg [N_BITS-1:0] data_to_send;
reg tx_start;
reg	en_send_registers;
reg	en_send_memory;
reg	en_send_pc;
reg	all_data_sent;

assign data_to_send_paraver = data_to_send;
assign en_send_registers_paraver = en_send_memory;
assign tx_done_paraver = tx_done;
assign count_send_bytes_paraver = count_send_bytes;

	always @(posedge clock_i)
		begin
			if (reset_i)
				begin
					en_send_registers <= 1'b0;
					en_send_memory    <= 1'b0;
					en_send_pc    	  <= 1'b0;
					count_send_bytes  <= 3'b000;
					addr_reg_debug      <= 5'b0;
					addr_mem_debug 		<= 7'b0;
					all_data_sent 		<= 1'b0;
					tx_start 			<= 1'b0;
				end	
			else
				begin
					if (en_send_data_pc)
						begin
							if (en_send_registers)
							begin
								if (tx_done) begin
									if (count_send_bytes == N_BYTES) begin
										count_send_bytes <= 3'b000;
										if (addr_reg_debug == N_REGISTER-1) begin
											addr_reg_debug <= 5'b0;
											en_send_registers <= 1'b0;
											en_send_memory <= 1'b1;
										end
										else begin
											addr_reg_debug <= addr_reg_debug + 1;
										end
									end else begin
										data_to_send <= data_registers_debug[count_send_bytes*N_BITS+:N_BITS];
										tx_start <= 1'b1;
										count_send_bytes <= count_send_bytes + 1;
									end
								end
								else begin
									tx_start <= 1'b0;
								end

							end
							else if(en_send_memory) begin
								if (tx_done) begin
									if (count_send_bytes == N_BYTES) begin
										count_send_bytes  <= 3'b000;
										if (addr_mem_debug == N_MEMORY_DATA-1) begin
											addr_mem_debug <= 7'b0;
											en_send_memory 	  <= 1'b0;
											en_send_pc	 	  <= 1'b1;
										end
										else begin
											addr_mem_debug <= addr_mem_debug + 1;
										end
									end else begin
										data_to_send <= data_mem_debug[count_send_bytes*N_BITS+:N_BITS];
										tx_start <= 1'b1;
										count_send_bytes <= count_send_bytes + 1;
									end
								end
								else begin
									tx_start <= 1'b0;
								end

							end
							else if(en_send_pc) begin
								if (tx_done) begin
									if (count_send_bytes == 1) begin
										count_send_bytes  <= 3'b000;
										en_send_pc	   <= 1'b0;
										all_data_sent <= 1'b1;
									end else begin
										data_to_send <= data_pc_debug;
										tx_start <= 1'b1;
										count_send_bytes <= count_send_bytes + 1;
									end
								end
								else begin
									tx_start <= 1'b0;
								end

							end
							else begin
								tx_start <= 1'b0;
								en_send_registers <= 1'b1;
							end
						end		    			
					else
						begin
							en_send_registers <= 1'b0;
							en_send_memory    <= 1'b0;
							addr_reg_debug    <= 5'b0;
							addr_mem_debug 	  <= 7'b0;
							all_data_sent 	  <= 1'b0;
							tx_start 		  <= 1'b0;
							count_send_bytes  <= 3'b000;
						end	  
				end
		end

  /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

	always @(*) //logica de cambio de estado
		begin: next_state_logic		    
		    
			next_state = state;
			en_rcv_instr = 1'b0;
							
			en_snd_instr = 1'b0;		// ojo con esta variable			
			// finish_rcv = 1'b0;
			en_wait_state = 1'b0;
			en_pipeline_reg = 1'b0;
			en_read_mem = 1'b0;
			step_mode_en = 1'b0;
			en_send_data_pc = 1'b0;

			select_debug_or_wireA = 1'b0;
			select_debug_or_alu_result = 1'b0;

			case (state)
				Iddle:
					begin
						next_state = Receive_Instruction;
						// o_dir_wr_mem_next = 7'b0000000;
						en_wait_state = 1'b0;

					end
				Receive_Instruction:
					begin
						next_state = Receive_Instruction;
						en_rcv_instr = 1'b1;					
						if (rcv_instr_complete)
							begin																												
								next_state = Write_Instruction;
								en_snd_instr = 1;													
							end					      
						else if (finish_rcv)
							begin																												
								next_state = Wait_mode;												
							end					      
					end				
				Write_Instruction:					
					begin
						// rcv_instr_complete = 0;		
						if (wrote)
							begin
								// o_dir_wr_mem_next = o_dir_wr_mem + 1;
								next_state  = Receive_Instruction;						
							end
						else
							next_state  = Write_Instruction;	
					end	
				Wait_mode:
					begin
						en_wait_state = 1'b1;
						if (mode_rcv)
							begin
								en_wait_state = 1'b0;
								next_state = Check_Operation;
							end											
						else
							next_state = Wait_mode;				

					end					
 				Check_Operation:
					begin
						case (mode)
							8'b00000001:
								next_state = Step_mode;	
							8'b00000010:
								next_state = Continue;	
							default:
								next_state = Wait_mode;
						endcase				
					end
				Step_mode:
					begin						
						en_read_mem = 1'b1;
						step_mode_en = 1'b1;
						if (stop_step) begin
							en_pipeline_reg = 1'b0;		
							next_state = Sending_data_pc;		
						end
						else begin
							en_pipeline_reg = 1'b1;
							next_state = Step_mode;		
						end
					end	
				// Stop:
				// 	begin						
				// 		en_pipeline_reg = 1'b1;
				// 		en_read_mem = 1'b1;			
				// 	end	
				Continue:
					begin						
						en_pipeline_reg = 1'b1;
						en_read_mem = 1'b1;			
					end	
				Sending_data_pc:
					begin				
						// en_pipeline_reg = 1'b0;
						en_read_mem = 1'b0;
						en_send_data_pc = 1'b1;

						select_debug_or_wireA = 1'b1;
						select_debug_or_alu_result = 1'b1;

						if (all_data_sent) begin
							next_state = Wait_mode;
						end else begin
							next_state = Sending_data_pc;
						end		
					end	
				default:
					next_state = Iddle;					
			endcase
		end




   	//______________________ Tx ____________ //
    tx_uart mytx_uart(
        .s_tick(tick), 
        .tx(debug_out),							// bit salida hacia rx
        .read_tx(read_tx),					// habilitado para leer
        .tx_done_tick(tx_done),                                     // 1 cuando termino de enviar o no esta enviando
        .tx_start(tx_start),												// 1 cuando comienza a transmitir
        .din(data_to_send),						
        .clock(clock_i),
        .reset(reset_i)
    );

    // ____________________ Rx   ____________________ //
    rx_uart myrx_uart(
        .s_tick(tick), 
        .rx(tx_rx),
        .rx_done_tick(read_rx), 
        .dout(dout),
        .clock(clock_i),
        .rx_state(),
        .reset(reset_i)
    );

    // ______________________ BRG ____________ //
/*     BaudRateGenerator myBRG (
        .tick   (tick),
        .clock  (clock_i),
        .reset  (reset)
    ); */

endmodule

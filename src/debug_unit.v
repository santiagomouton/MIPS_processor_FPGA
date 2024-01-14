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
	input wire halt_signal,
	input wire tx_rx,
    
	output wire debug_out,
	output wire [NB_DATA-1:0] o_data_mem,
	output wire write_to_register,
	output wire [NB_ADDR-1:0] o_dir_wr_mem,
    output reg en_pipeline_o,
	output reg en_read_mem,


	output wire [N_BITS-1:0] data_to_send_paraver,
	
	// in/out para obtener datos de registros
	output reg select_debug_or_wireA,
	output reg [NB_REG-1:0] addr_reg_debug,
	input  wire [NB_DATA-1:0] data_registers_debug,
	// in/out para obtener datos de memoria
	output reg select_debug_or_alu_result,
	output reg [NB_ADDR-1:0] addr_mem_debug,
	input  wire [NB_DATA-1:0] data_mem_debug,

	input wire [6:0] data_pc_debug,

	output wire [NB_STATE-1:0] state_paraver,
	// output wire [5 - 1:0] state_paraver,
	output wire [2:0] count_paraver,
	output wire en_send_registers_paraver,
	output wire tx_done_paraver,
	output wire [2:0] count_send_bytes_paraver,
	output wire [31:0] instruction_decode
);

	localparam HALT = 32'b11111100000000000000000000000000;

    reg en_pipeline_reg;
	reg [2:0]count;
	reg [6:0]o_dir_wr_mem_next, o_dir_wr_mem_reg;
	// reg rcv_instr_complete;
	reg [NB_STATE-1:0] state;
	reg [NB_STATE-1:0] next_state;
	// reg en_rcv_instr;
	reg en_send_data_pc;

	wire read_rx;
	wire [7:0] dout;
	wire tx_done;
	wire tick;


	assign state_paraver = state;
	assign count_paraver = count;



	localparam 	[NB_STATE-1:0]   Iddle			    		=  12'b000000000001
								,Receive_Instruction    	=  12'b000000000010
								,Write_Instruction  		=  12'b000000000100
								,Step_mode          		=  12'b000000001000
								,Continue    				=  12'b000000010000
								,Tx_data_to_computer    	=  12'b000000100000 //32
								,Restart					=  12'b000001000000 //64
								,Flush   		   			=  12'b000010000000; //128
/*	
	localparam 	[NB_STATE-1:0]			Tx_data_to_computer1   	=  12'b000100000000; //256
	localparam 	[NB_STATE-1:0]			Sending_count_cyles 	=  12'b001000000000; //512
	localparam 	[NB_STATE-1:0]			Sending_data_registers	=  12'b010000000000; //1024
	localparam 	[NB_STATE-1:0]			Sending_data_mem		=  12'b100000000000; //2048 */


	reg [2:0] count_reg, count_next;
	reg [31:0] o_data_mem_reg, o_data_mem_next;
	reg write_to_register_reg;
    reg finish_rcv_reg, finish_rcv_next;

	always @(posedge clock_i) 
		begin			
			if (reset_i)
			  begin
				  state 			<= Iddle;					
				  en_pipeline_o 	<= 1'b0;						
				  o_dir_wr_mem_reg 	<= 7'b0000000;
				  count_reg 		<= 3'b000;
				  o_data_mem_reg	<= 8'b00000000;
				  finish_rcv_reg	<= 1'b0;
			  end						
			else
			  begin
				  state 			<= next_state;
				  en_pipeline_o 	<= en_pipeline_reg;
				  o_dir_wr_mem_reg 	<= o_dir_wr_mem_next;
				  count_reg 		<= count_next;
				  o_data_mem_reg	<= o_data_mem_next;
				  finish_rcv_reg	<= finish_rcv_next;
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

/* 
	always @(posedge clock_i ) begin
		if (reset_i) begin
			tx_start <= 0;
		end
		else begin 
			if(read_rx && tx_done)
				begin
					data_to_send <= dout;
					tx_start <= 1;
				end
			if(!tx_done)
				begin
					tx_start <= 0;
				end
		end
	end */

 
 /* 	always @(posedge clock_i)
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
 */
  /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

	reg aux, aux2;

	initial begin
		aux2 = 1;
	end
	always @(posedge clock_i ) begin
		if (reset_i) begin
			aux = 0;
		end
		else if(state == Continue)
			aux = 1;
		if(tx_done)
			begin
				if (aux) begin
					data_to_send <= instruction_decode[31:24];
					tx_start <= 1;
					aux <= 0;
				end
				if (aux2) begin
					data_to_send <= instruction_decode[31:24];
					tx_start <= 1;
					aux2 <= 0;
				end
			end
		else if(!tx_done)
			begin
				tx_start <= 0;
			end
	end


	always @(*) //logica de cambio de estado
		begin: next_state_logic		    
		    
			next_state = state;
			// en_rcv_instr = 1'b0;
			o_dir_wr_mem_next = o_dir_wr_mem_reg;
			finish_rcv_next = finish_rcv_reg;
			
			write_to_register_reg = 1'b0;
			en_pipeline_reg = 1'b0;
			en_read_mem = 1'b0;
			en_send_data_pc = 1'b0;

			select_debug_or_wireA = 1'b0;
			select_debug_or_alu_result = 1'b0;

			count_next 		= count_reg;
			o_data_mem_next = o_data_mem_reg;

			case (state)
				Iddle:
					begin
						finish_rcv_next		= 1'b0;
						o_dir_wr_mem_next 	= 7'b0000000;
						if(read_rx)
							begin
								case(dout)
									8'b00000001:next_state = Receive_Instruction;
									8'b00000010:next_state = Step_mode;
									8'b00000100:next_state = Continue;
									8'b00001000:next_state = Restart;
									8'b00010000:next_state = Flush;
/* 									"u":next_state = Receive_Instruction;
									"s":next_state = Step_mode;
									"c":next_state = Continue;
									"r":next_state = Restart;
									"f":next_state = Flush; */
								endcase
							end
					end

				Receive_Instruction:
					begin
						if (count_reg == 3'b100) 
							begin
								if (o_data_mem_reg == HALT) begin
									finish_rcv_next = 1'b1;
								end
								next_state = Write_Instruction;
								write_to_register_reg = 1'b1;											
							end
						else if (read_rx) 
							begin
								o_data_mem_next = {dout, o_data_mem_reg[NB_DATA    -1:8]};
								count_next = count_reg + 1;
							end					      
					end

				Write_Instruction:					
					begin
						write_to_register_reg = 1'b1;
						count_next = 3'b000;
						o_dir_wr_mem_next = o_dir_wr_mem_reg + 1;
						if (finish_rcv_reg)
							next_state = Iddle;												
						else
							next_state  = Receive_Instruction;	
					end

				Step_mode:
					begin						
						en_read_mem = 1'b1;
						if (halt_signal)
							begin
								en_pipeline_reg = 1'b0;
								en_send_data_pc = 1'b1;
							end	
						else 
							begin
								en_pipeline_reg = 1'b1;
							end
						next_state = Tx_data_to_computer;
					end

				Continue:
					begin						
						en_pipeline_reg = 1'b1;
						en_read_mem = 1'b1;
						// enable_mem_o = 1'b1;		// enable memData, en nuestro caso se activa con enable_pipeline				

						next_state = Continue;
						
						//read_reg = 1'b1;	//habilita lectura de memoria de instrucciones				
						//rw_reg = 1'b0; //tambien para escribir mem instrucciones, habilita escritura	
						//debug_unit_reg = 1'b0;  //para escribir en memoria de instrucciones, controla direccion		


						if (halt_signal)
							begin
								en_pipeline_reg = 1'b0;
								en_send_data_pc = 1'b1;
								next_state = Tx_data_to_computer;
							end
					end

				Tx_data_to_computer:
					begin				
						// en_pipeline_reg = 1'b0;
						en_read_mem = 1'b0;
						en_send_data_pc = 1'b1;

						select_debug_or_wireA = 1'b1;
						select_debug_or_alu_result = 1'b1;

						if (all_data_sent) begin
							next_state = Iddle;
						end else begin
							next_state = Tx_data_to_computer;
						end		
					end	

				Restart:
					begin				
						next_state = Iddle;
					end	

				Flush:
					begin				
						next_state = Iddle;
					end

				default:
					next_state = Iddle;					
			endcase
		end

	assign o_data_mem = o_data_mem_reg;
	assign o_dir_wr_mem = o_dir_wr_mem_reg;
	assign write_to_register = write_to_register_reg;


    // ______________________ BRG ____________ //
    BaudRateGenerator myBRG (
        .tick   (tick),
        .clock  (clock_i),
        .reset  (reset_i)
    );

   	//______________________ Tx ____________ //
    tx_uart mytx_uart(
        .s_tick(tick), 
        .tx(debug_out),							// bit salida hacia rx
        .tx_done_tick(tx_done),                                     // 1 cuando termino de enviar o no esta enviando
        .tx_start(tx_start),												// 1 cuando comienza a transmitir
        .din(data_to_send),						
        .clock(clock_i),
        .reset(reset_i)
    );

   	//______________________ Tx ____________ //
/*     tx_uart2 mytx_uart(
		.clk(clock_i),
		.reset(reset_i),
		.tx_start(tx_start), 
		.s_tick(tick),
		.din(data_to_send),
		.tx_done_tick(tx_done),
		.tx(debug_out)
    ); */


    // ____________________ Rx   ____________________ //
	rx_uart myrx_uart(
		.s_tick(tick), 
        .rx(tx_rx),
        .rx_done_tick(read_rx), 
        .dout(dout),
        .clock(clock_i),
        .reset(reset_i)
    ); 
     // ____________________ Rx   ____________________ //
/*     rx_uart2 myrx_uart(
	.clk(clock_i), 
 	.reset(reset_i),
    .rx(tx_rx),
	.s_tick(tick),
    .rx_done_tick(read_rx),
    .dout(dout)
    );  */

endmodule

`timescale 1ns / 1ps

module debug_unit
#(
    parameter NB_DATA    = 32,
    parameter NB_ADDR_REG = 5,
    parameter N_BITS     = 8,
    parameter N_BYTES    = 4,		
    parameter NB_STATE   = 12,
    parameter N_REGISTER = 32,
    parameter N_MEMORY_DATA = 128,
    parameter NB_ADDR = 7
) 
(
    input wire clock_i,
    input wire reset_i,
	input wire halt_signal,
	input wire tx_rx,
    
	output wire debug_out,
	output wire [NB_DATA-1:0] o_data_mem,
	output wire write_to_register,
	output wire [NB_DATA-1:0] o_dir_wr_mem,
    output reg en_pipeline_o,
	output reg en_read_mem,

	
	// in/out para obtener datos de registros
	output wire select_debug_or_wireA,
	output wire [NB_ADDR_REG-1:0] addr_reg_debug,
	input  wire [NB_DATA-1:0] data_registers_debug,
	// in/out para obtener datos de memoria
	output reg select_debug_or_alu_result,
	// output reg [NB_ADDR-1:0] addr_mem_debug,
	output wire [NB_ADDR-1:0] addr_mem_debug,
	input  wire [NB_DATA-1:0] data_mem_debug,

	input wire [NB_DATA-1:0] data_pc_debug,

	output wire [NB_STATE-1:0] state_paraver,
	// output wire [5 - 1:0] state_paraver,
	input wire [NB_DATA-1:0] alu_result_o_mem_test,


	input wire [31:0] wire_inmediate_paraver
);

	localparam HALT = 32'b11111100000000000000000000000000;

    reg en_pipeline_reg;
	reg [2:0]count;
	reg [NB_DATA-1:0]o_dir_wr_mem_next, o_dir_wr_mem_reg;
	// reg rcv_instr_complete;
	reg [NB_STATE-1:0] state, next_state;
	// reg en_rcv_instr;
	// reg en_send_data_pc;

	wire read_rx;
	wire [7:0] dout;
	wire tx_done;
	wire tick;


	assign state_paraver = state;


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
	reg [NB_DATA-1:0] o_data_mem_reg, o_data_mem_next;
	reg write_to_register_reg, write_to_register_next;
    reg finish_rcv_reg, finish_rcv_next;


reg [N_BITS-1:0] data_to_send, data_to_send_next;

	reg tx_start, tx_start_next;
	reg [2:0] count_send_bytes, count_send_bytes_next;
	reg [NB_ADDR_REG-1:0] addr_reg_debug_next, addr_reg_debug_reg; 
	reg select_debug_or_wireA_reg, select_debug_or_wireA_next;
	reg [NB_ADDR-1:0] addr_mem_debug_next, addr_mem_debug_reg; 
	reg	en_send_registers_reg, en_send_registers_next;
	reg	en_send_memory_reg, en_send_memory_next;
	reg	en_send_pc_reg, en_send_pc_next;
	reg	all_data_sent_reg, all_data_sent_next;

	always @(posedge clock_i) 
		begin			
			if (reset_i)
			  begin
				  state 				<= Iddle;					
				  en_pipeline_o 		<= 1'b0;						
				  o_dir_wr_mem_reg 		<= 0;
				  count_reg 			<= 3'b000;
				  o_data_mem_reg		<= 0;
				  finish_rcv_reg		<= 1'b0;

				//   tx_start				<= 1'b0;
				  count_send_bytes  	<= 3'b000;
				//   addr_reg_debug_reg	<= 5'b00000;
				  addr_reg_debug_reg	<= 0;
				  select_debug_or_wireA_reg <= 1'b0;
				  addr_mem_debug_reg	<= {NB_ADDR{1'b0}};
				  en_send_registers_reg <= 1'b0;
				  en_send_memory_reg	<= 1'b0;
				  en_send_pc_reg		<= 1'b0;
				  all_data_sent_reg		<= 1'b0;
				//   data_to_send			<= 8'b00000000;
				  write_to_register_reg <= 1'b0;
			  end						
			else
			  begin
				  state 				<= next_state;
				  en_pipeline_o 		<= en_pipeline_reg;
				  o_dir_wr_mem_reg 		<= o_dir_wr_mem_next;
				  count_reg 			<= count_next;
				  o_data_mem_reg		<= o_data_mem_next;
				  finish_rcv_reg		<= finish_rcv_next;

				//   tx_start		 		<= tx_start_next;
				  count_send_bytes  	<= count_send_bytes_next;
				  addr_reg_debug_reg	<= addr_reg_debug_next;
				  select_debug_or_wireA_reg <= select_debug_or_wireA_next;
				  addr_mem_debug_reg	<= addr_mem_debug_next;
				  en_send_registers_reg	<= en_send_registers_next;
				  en_send_memory_reg	<= en_send_memory_next;
				  en_send_pc_reg		<= en_send_pc_next;
				  all_data_sent_reg		<= all_data_sent_next;
				//   data_to_send			<= data_to_send_next;
				  write_to_register_reg <= write_to_register_next;
              end
		end


  /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

	always @(*) //logica de cambio de estado
		begin: next_state_logic		    
		    
			next_state = state;
			// en_rcv_instr = 1'b0;
			o_dir_wr_mem_next = o_dir_wr_mem_reg;
			finish_rcv_next = finish_rcv_reg;
			
			write_to_register_next = 1'b0;
			en_pipeline_reg = 1'b0;
			en_read_mem = 1'b0;
			// en_send_data_pc = 1'b0;

			select_debug_or_wireA_next = select_debug_or_wireA_reg;
			select_debug_or_alu_result = 1'b0;

			count_next 		= count_reg;
			o_data_mem_next = o_data_mem_reg;

			tx_start_next = 1'b0;
			tx_start = 1'b0;
			count_send_bytes_next 	= count_send_bytes;
			addr_reg_debug_next 	= addr_reg_debug_reg;
			addr_mem_debug_next 	= addr_mem_debug_reg;
			en_send_registers_next 	= en_send_registers_reg;
			en_send_memory_next 	= en_send_memory_reg;
			en_send_pc_next 		= en_send_pc_reg;
			all_data_sent_next 		= all_data_sent_reg;
			// data_to_send_next 		= data_to_send;
			data_to_send			= 8'b00000000;

			case (state)
				Iddle:
					begin
						finish_rcv_next		= 1'b0;
						o_dir_wr_mem_next 	= 32'b0;
						all_data_sent_next 	= 1'b0;
						if(read_rx)
							// tx_start = 1'b1;
							// data_to_send = dout;
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
									default:	next_state = Iddle;
								endcase
							end
					end

				Receive_Instruction:
					begin
						/* if (tx_done) begin
							tx_start = 1'b0;
						end */

						if (count_reg == 3'b100) 
							begin
								if (o_data_mem_reg == HALT) begin
									finish_rcv_next = 1'b1;
								end
								next_state = Write_Instruction;
								write_to_register_next = 1'b1;											
							end
						else if (read_rx) 
							begin
								// o_data_mem_next = {dout, o_data_mem_reg[NB_DATA-1:8]};
								// o_data_mem_next[((count_reg+1)*7)+:] = dout;
								// o_data_mem_next[count_reg*(N_BITS)+:(N_BITS-1)] = dout;
								case (count_reg)
									3'b000: begin 
										o_data_mem_next[7:0]   = dout;  // Byte 0
										
										// data_to_send = o_data_mem_reg[31:24];
										// tx_start = 1'b1;
									end
									3'b001: begin
										o_data_mem_next[15:8]  = dout;  // Byte 1
										// data_to_send = o_data_mem_reg[7:0];
										// tx_start = 1'b1;
									end
									3'b010: begin
										o_data_mem_next[23:16] = dout;  // Byte 2
										// data_to_send = o_data_mem_reg[15:8];
										// tx_start = 1'b1;
									end
									3'b011: begin
										o_data_mem_next[31:24] = dout;  // Byte 3
										// data_to_send = o_data_mem_reg[23:16];
										// tx_start = 1'b1;
									end
								endcase
								// data_to_send = o_data_mem_reg[count_reg*(N_BITS)+:(N_BITS-1)];

								
								
								count_next = count_reg + 1;
							end
					end

				Write_Instruction:					
					begin
						write_to_register_next = 1'b1;
						count_next = 3'b000;
						o_dir_wr_mem_next = o_dir_wr_mem_reg + 1;
						// o_data_mem_next = 32'h00000000;
						if (finish_rcv_reg)
							next_state = Iddle;												
						else begin
							next_state  = Receive_Instruction;
						end	
					end

				Step_mode:
					begin						
						en_read_mem = 1'b1;
						if (halt_signal)
							begin
								en_pipeline_reg = 1'b0;
								// en_send_data_pc = 1'b1;
							end	
						else 
							begin
								en_pipeline_reg = 1'b1;
							end
						next_state = Tx_data_to_computer;
						en_send_registers_next = 1'b1;
						select_debug_or_wireA_next = 1'b1;
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
								// en_send_data_pc = 1'b1;
								en_send_registers_next = 1'b1;
								next_state = Tx_data_to_computer;
								select_debug_or_wireA_next = 1'b1;
							end
					end

				Tx_data_to_computer:
					begin				
						// en_pipeline_reg = 1'b0;
						en_read_mem = 1'b0;
						// en_send_data_pc = 1'b1;
						select_debug_or_wireA_next = 1'b1;
						select_debug_or_alu_result = 1'b1;

						if (en_send_registers_reg) begin
							if (tx_done) begin
								if (count_send_bytes == (N_BYTES)) begin
									count_send_bytes_next = 3'b000;
									// tx_start = 1'b0;
									if (addr_reg_debug_reg == (N_REGISTER-1)) begin
										addr_reg_debug_next = 5'b00000;
										en_send_registers_next = 1'b0;
										en_send_memory_next = 1'b1;
										// all_data_sent_next = 1'b1;
									end
									else begin
										addr_reg_debug_next = addr_reg_debug_reg + 1;
									end
								end else begin
									// tx_start_next = 1'b1;
									tx_start = 1'b1;
									// data_to_send = {8'b0};
									data_to_send = data_registers_debug[count_send_bytes*(N_BITS)+:(N_BITS)];
									// data_to_send_next = data_registers_debug[count_send_bytes*(N_BITS)+:(N_BITS-1)];
									// data_to_send = alu_result_o_mem_test[count_send_bytes*(N_BITS)+:(N_BITS-1)];
									count_send_bytes_next = count_send_bytes + 1;
								end
							end
						end

 						else if (en_send_memory_reg) begin
							if (tx_done) begin
								if (count_send_bytes == (N_BYTES)) begin
									count_send_bytes_next = 3'b000;
									// tx_start = 1'b0;
									if (addr_mem_debug_reg == (N_MEMORY_DATA-1)) begin
										addr_mem_debug_next = {NB_ADDR{1'b0}};
										en_send_memory_next = 1'b0;
										en_send_pc_next = 1'b1;

										// all_data_sent_next = 1'b1;
									end 
									else begin
										addr_mem_debug_next = addr_mem_debug_reg + 1;
									end
								end else begin
									tx_start = 1'b1;
									// data_to_send_next = data_mem_debug[count_send_bytes*(N_BITS)+:(N_BITS-1)];
									
									data_to_send = data_mem_debug[count_send_bytes*(N_BITS)+:(N_BITS)];
									count_send_bytes_next = count_send_bytes + 1;
								end
							end
						end

 						else if (en_send_pc_reg) begin
							if (tx_done) begin
								if (count_send_bytes == (N_BYTES)) begin
									count_send_bytes_next = 3'b000;
									en_send_pc_next = 1'b0;
									all_data_sent_next = 1'b1;
								end else begin
									tx_start = 1'b1;
									data_to_send = wire_inmediate_paraver[count_send_bytes*(N_BITS)+:(N_BITS)];
									count_send_bytes_next = count_send_bytes + 1;
								end
							end
						end

/* 						else if (en_send_pc_reg) begin
							if (tx_done) begin
								if (count_send_bytes == (N_BYTES)) begin
									count_send_bytes_next = 3'b000;
									all_data_sent_next = 1'b1;
									en_send_pc_next = 1'b0;

								end else begin
									tx_start = 1'b1;
									data_to_send = wire_inmediate_paraver[count_send_bytes*(N_BITS)+:(N_BITS-1)];
									
									count_send_bytes_next = count_send_bytes + 1;
								end
							end
						end */

						if (all_data_sent_reg)
						begin
							next_state = Iddle;
							select_debug_or_wireA_next = 1'b0;
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

	assign addr_reg_debug = addr_reg_debug_reg;

	assign select_debug_or_wireA = select_debug_or_wireA_reg;

	assign addr_mem_debug = addr_mem_debug_reg;
	

    // ______________________ BRG ____________ //
    BaudRateGenerator myBRG (
        .tick(tick),
        .clock(clock_i),
        .reset_i(reset_i)
    );
// wire tx_start_next_wire;
// assign tx_start_next_wire = tx_start;
   	//______________________ Tx ____________ //
    tx_uart mytx_uart(
        .s_tick(tick), 
        .tx(debug_out),							// bit salida hacia rx
        .tx_done_tick(tx_done),                                     // 1 cuando termino de enviar o no esta enviando
        .tx_start(tx_start),												// 1 cuando comienza a transmitir
        .din(data_to_send),						
        .clock(clock_i),
        .reset_i(reset_i),
		.state()
    );

    // ____________________ Rx   ____________________ //
	rx_uart myrx_uart(
		.s_tick(tick), 
        .rx(tx_rx),
        .rx_done_tick(read_rx), 
        .dout(dout),
        .clock(clock_i),
        .reset_i(reset_i)
    );

endmodule

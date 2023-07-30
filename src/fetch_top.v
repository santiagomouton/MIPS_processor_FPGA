`include "parameters.vh"

`define OP_CODE 31:26


module fetch_top
	#
	(
		parameter NB_DATA = 32
	)
	(
		input wire clock_i,
		input wire reset_i,		
		input wire enable_i,		
		// input wire debug_unit_i,
		// input wire [1:0] pc_src_i,		
		
		input wire en_read_i, 
		input wire en_write_i,
        input wire [6:0] addr_i_write,
        input wire [NB_DATA-1:0] data_i,

/* 		input wire [`ADDRWIDTH-1:0] addr_register_i,
		input wire [`ADDRWIDTH-1:0] addr_branch_i,
		input wire [`ADDRWIDTH-1:0] addr_jump_i,
		input wire jump_or_branch_i, */

		// input wire [`ADDRWIDTH-1:0] wr_addr_i, // enviado por debug_unit para cargar instruccion 			
		// input wire [NB_DATA-1:0] inst_load_i, //instruccion a cargar en la memoria por debug_unit

		output wire [6:0] pc_o,		
		output wire [NB_DATA-1:0] instruction_o

		/* DEBUG */
		/*output wire [`ADDRWIDTH-1:0] pc_i_mem_o,
		output wire [1:0] pc_src_o
		*/

	);

	wire [6:0] next_addr_plus_four_o;
	wire [6:0] next_addr_o;
	
	assign pc_o = next_addr_plus_four_o;

/* 	wire [`ADDRWIDTH-1:0] conex_address_debug;
	wire [`ADDRWIDTH-1:0] conex_address_jump_pc;
	wire [`ADDRWIDTH-1:0] conex_input_pc;
	wire [NB_DATA-1:0] conex_instr;

	/*
	assign pc_i_mem_o = conex_address_debug;
	assign pc_src_o  = pc_src_i;
	*/
/* 	Mux2_1#(.NB_DATA(`ADDRWIDTH)) mux_address_mem //mux para direccion de memoria, en modo escritura o lectura
	(
		.inA(wr_addr_i),
		.inB(conex_pc_adder),
		.sel(debug_unit_i),
		.out(conex_address_debug)
	); */
	pc pc
	(
		.clock(clock_i),
		.reset(reset_i),
		.enable(enable_i),				
		.next_addr_i(6'b0), //por ahora para que solo lea la primera instruccion
		.next_addr_o(next_addr_o),
		.next_addr_plus_four_o(next_addr_plus_four_o)
	);
/* 	pc_adder#(.NB_DATA(`ADDRWIDTH)) pc_adder // PC + 1
	(
		.next_addr_i(conex_pc_adder),
		.next_addr_o(conex_pc_1)
	); */
/* 	Mux3_1 #(.NB_DATA(`ADDRWIDTH)) mux_addr_branch_jump
	(
		.op1_i(addr_register_i), //00
		.op2_i(addr_branch_i), //01
		.op3_i(addr_jump_i), //10
		.sel_i(pc_src_i),
		.data_o(conex_address_jump_pc)
	); */
	/*
	Mux4_1#(.NB_DATA(`ADDRWIDTH)) mux_src_pc
	(
		.op1_i(conex_pc),
		.op2_i(addr_register_i),
		.op3_i(addr_branch_i),
		.op4_i(addr_jump_i),
		.sel_i(pc_src_i),
		.data_o(conex_input_pc)
	);*/	
	
/* 	Mux2_1#(.NB_DATA(`ADDRWIDTH)) mux_src_PC
	(
		.inA(conex_address_jump_pc),
		.inB(conex_pc_1),
		.sel(jump_or_branch_i),
		.out(conex_input_pc)
	); */

	INSTmem mem_instruction
	(
		.clock_i(clock_i),				
		.addr_i_write(addr_i_write),
		.addr_i_read(next_addr_o),
		.en_write_i(en_write_i),
		.en_read_i(en_read_i),
		.data_i(data_i),
		.data_o(instruction_o)
	);

	// Mux2_1#(.NB_DATA(NB_DATA)) mux_input_reg_IF_ID
  	// (
  	// 	.inA(32'hF8000000),
  	// 	.inB(conex_instr),
  	// 	.sel(jump_or_branch_i),
  	// 	.out(instruction_o)
  	// );


endmodule 
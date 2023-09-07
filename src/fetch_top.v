
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
		
		input wire en_read_i, 
		input wire en_write_i,
        input wire [6:0] addr_i_write,
        input wire [NB_DATA-1:0] data_i,

		output wire [6:0] pc_o,		
		output wire [NB_DATA-1:0] instruction_o


	);

	wire [6:0] next_addr_plus_four_o;
	wire [6:0] next_addr_o;
	
	assign pc_o = next_addr_plus_four_o;

	pc pc
	(
		.clock(clock_i),
		.reset(reset_i),
		.enable(enable_i),				
		.next_addr_i(next_addr_plus_four_o), //por ahora para que solo lea la primera instruccion
		.next_addr_o(next_addr_o),
		.next_addr_plus_four_o(next_addr_plus_four_o)
	);

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


endmodule 
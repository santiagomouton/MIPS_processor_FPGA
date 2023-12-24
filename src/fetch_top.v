
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
		input wire pc_branch_or_jump,
		input wire [7-1:0] address_jump,
		input wire [7-1:0] address_branch,
		input wire [7-1:0] address_register,
		input wire [1:0]pc_src,

		output wire [6:0] pc_o,		
		output wire [NB_DATA-1:0] instruction_o


	);

	wire [6:0] next_addr_plus_four_o;
	wire [6:0] next_addr_o;

	wire [6:0] pc_src_entry_addr;
	wire [6:0] pc_addr_in;
	
	assign pc_o = next_addr_plus_four_o;

	multiplexor_3_in#(.NB_DATA(7)) pc_src_entry
	(
		.op1_i(address_register),
		.op2_i(address_jump),
		.op3_i(address_branch),		
		.sel_i(pc_src),
		.data_o(pc_src_entry_addr)
	); 

	multiplexor_2_in#(.NB_DATA(7)) jump_or_not
	(
		.op1_i(next_addr_plus_four_o),
		.op2_i(pc_src_entry_addr),
		.sel_i(pc_branch_or_jump),
		.data_o(pc_addr_in)
	);

	pc pc
	(
		.clock(clock_i),
		.reset(reset_i),
		.enable(enable_i),				
		.next_addr_i(pc_addr_in), 
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
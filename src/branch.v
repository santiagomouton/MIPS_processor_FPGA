`timescale 1ns / 1ps

module branch
	#(
		parameter NB_DATA = 32		
	)
	(
		input wire [NB_DATA-1:0] pc,
		input wire [NB_DATA-1:0] inmediate,
		input wire [NB_DATA-1:0] data_ra_branch,
		input wire [NB_DATA-1:0] data_rb_branch,

		output wire is_equal,
		output wire [NB_DATA-1:0] branch_address_o

	);

	assign is_equal = (data_ra_branch == data_rb_branch) ? 1'b1 : 1'b0;
	assign branch_address_o = pc + inmediate;	

endmodule

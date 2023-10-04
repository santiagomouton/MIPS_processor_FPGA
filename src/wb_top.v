
module wb_top
	#(
		parameter NB_DATA = 32
	)
	(
		input wire [NB_DATA-1:0] mem_data_i,
		input wire [NB_DATA-1:0] alu_result_i,
		input wire [6:0] pc_i,
		// input wire [NB_DATA-1:0] inm_ext_i, // LUI

		input wire [2-1:0] mem_to_reg_i,

		output wire [NB_DATA-1:0] data_write_to_reg
	);


    multiplexor_4_in mux_wb
    (
		.op1_i(mem_data_i),
		.op2_i(alu_result_i),
		.op3_i({{25'b0}, pc_i}),
		.op4_i(32'b0),
		.sel_i(mem_to_reg_i),
		.data_o(data_write_to_reg)
    );

endmodule
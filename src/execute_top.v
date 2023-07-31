
module execute_top
	#(
		parameter NB_DATA     = 32,
		parameter NB_REG      = 5
	)
	(
		input wire [5:0] funct_i,		
		input wire [5:0] opcode_i,		
		input wire [NB_DATA-1:0] data_ra_i,
		input wire [NB_DATA-1:0] data_rb_i,
		input wire [NB_DATA-1:0] inmediate_i,
		input wire tipeI_i,
		// input wire [NB_REG-1:0]	shamt_i,
		input wire [NB_REG-1:0]	wire_RW, wire_B,
		input wire [2-1:0] regDest_signal_i,
		
		output wire [NB_DATA-1:0] data_rb_o,
		output wire [NB_REG-1:0] writeReg_o,
        output wire [NB_DATA-1:0] alu_result_o
	);
	

	assign data_rb_o = data_rb_i;

	wire [NB_DATA-1:0] o_B_to_alu;
	wire [6-1:0] funct_for_alu;

    alu alu
    (
        .i_a(data_ra_i), //input a 
        .i_b(o_B_to_alu), //input b 
        .i_op(funct_for_alu),	
        .o_o(alu_result_o)
    );

	interfaceALU interfaceALU
	(
		.funct(funct_i),
		.opcode(opcode_i),
		.funct_for_alu(funct_for_alu)
	);

	inmediate_or_dataB inmediate_or_dataB
	(
		.tipeI(tipeI_i),
		.inmediate(inmediate_i),
		.dataB(data_rb_i),
		.o_B_to_alu(o_B_to_alu)
	);

    mux_write_reg#(.NB_DATA(NB_REG)) mux_write_reg
    (
		.op1_i(wire_B),
		.op2_i(wire_RW),
		.op3_i(5'd31),		
		.sel_i(regDest_signal_i),          
		.data_o(writeReg_o)
    );

	/* este mux es manejado por la unidad de forward*/
/* 	Mux3_1 mux_forwardA
	(
		.op1_i(data_ra_i), //00
		.op2_i(EX_MEM_result_alu_i), //01
		.op3_i(MEM_WB_data_i), //10
		.sel_i(src_forwardA),
		.data_o(out_mux_forwardA)
	);
	Mux3_1 mux_forwardB
	(
		.op1_i(data_rb_i),
		.op2_i(EX_MEM_result_alu_i),
		.op3_i(MEM_WB_data_i),
		.sel_i(src_forwardB),
		.data_o(out_mux_forwardB)
	); */

/* 	Mux2_1 #(.NB_DATA(32)) mux_alu_src_A	
	(
		.inA({{27'b0},shamt_i}), // sel = 1
		.inB(out_mux_forwardA), 
		.sel(EX_control_i[6]),
		.out(conex_input_alu_A)
	);

	Mux2_1 #(.NB_DATA(32)) mux_alu_src_B	
	(
		.inA(out_mux_forwardB), // sel = 1
		.inB(data_inm_i),
		.sel(EX_control_i[5]),
		.out(conex_input_alu_B)
	)

 	unit_forward unit_forward
	(
		.ID_EX_rs_i(rs_i),
		.ID_EX_rt_i(rt_i),

		.EX_MEM_write_reg_i(EX_MEM_write_reg_i),
		.MEM_WB_write_reg_i(MEM_WB_write_reg_i),
		.EX_MEM_reg_write_i(EX_MEM_reg_write_i),
		.MEM_WB_reg_write_i(MEM_WB_reg_write_i),

		.forward_A_o(src_forwardA),
		.forward_B_o(src_forwardB) 
	); */

endmodule

module decode_top
	#(
		parameter NB_DATA   = 32,		
		parameter NB_OPCODE = 6,
		parameter NB_REG    = 5				
	)
	(
		input wire clock_i,
		input wire reset_i,    
		//input wire enable_i,
		input wire reg_write_i,		
		
		input wire [NB_DATA-1:0] instruction_i,		
		input wire [NB_REG-1:0] write_register_i,
		input wire [NB_DATA-1:0] data_rw_i,

		// output wire [NB_REG-1:0] shamt_o,
		output wire [NB_REG-1:0] wireA_o, wireB_o, wireRW_o,

		output wire [5:0]mem_signals, 
		output wire [2:0]wb_signals,
        output wire [1:0]regDest_signal,
        output wire tipeI_signal,

        output wire [NB_OPCODE-1:0] opcode_o,
        output wire [5:0] funct_o,
        output wire [NB_DATA-1:0] wire_inmediate_o,
        output wire [NB_DATA-1:0] data_ra_o,
        output wire [NB_DATA-1:0] data_rb_o
		
	);

	wire [NB_REG-1:0] addr_A_out;

	// Conexion distribuidor, banco de registros y control unit
	wire [5:0]operation;
	wire [5:0]funct;
	wire regDest;
	wire branch;

	//distributor
	wire [NB_REG-1:0] wire_A;
	wire [NB_REG-1:0] wire_B;
	wire [26-1:0] wire_direction;
	wire [16-1:0] wire_inmediate;

    assign wireA_o = wire_A;
    assign wireB_o = wire_B;
    assign funct_o = funct;

/* 	assign EX_control_o = (conex_stall) ? {NB_EX_CTRL{1'b0}} : conex_EX_control;
	assign M_control_o = (conex_stall) ? {NB_MEM_CTRL{1'b0}} : conex_M_control;
	assign WB_control_o = (conex_stall) ? {NB_WB_CTRL{1'b0}} : conex_WB_control; */
/* 
	hazard_detection hazard_detection
	(
		.ID_rs_i(instruction_i[`RS_BIT]),
		.ID_rt_i(instruction_i[`RT_BIT]),
		.EX_reg_write_i(EX_reg_write_i),
		//.beq_i(conex_beq),
		//.bne_i(conex_bne),
		//.op_code_i(instruction_i[`OP_CODE]),
		.EX_write_register_i(EX_write_register_i),
		.EX_rt_i(EX_rt_i),
		.ID_EX_mem_read_i(ID_EX_mem_read_i),		
		.halt_i(conex_halt_detected),
		.stall_o(conex_stall),
		.pc_write_o(pc_write_o),
		.IF_ID_write_o(IF_ID_write_o)
	); */

/* 	unit_branch unit_branch
	(
		.pc_i(pc_i),
		.inm_ext_i(reg_inm_ext[`ADDRWIDTH-1:0]),

		.data_ra_i(data_ra_branch),
		.data_rb_i(data_rb_branch),

		.is_equal_o(is_equal),
		.branch_address_o(addr_branch_o)
	);	 */
 	multiplexor_2_in #(.NB_DATA(NB_REG)) addr_debug_or_wireA
	(
		.op1_i(wire_A),
		.op2_i(addr_debug_i),
		.sel_i(addr_debug_or_wireA),
		.data_o(addr_A_out)
	);

	bank_registers bank_registers
	(
		.clock_i(clock_i),
		.reset_i(reset_i),
		.rw_i(reg_write_i), 
		.addr_ra_i(addr_A_out),
		.addr_rb_i(wire_B),
		.addr_rw_i(write_register_i),
		.data_rw_i(data_rw_i),
		.data_ra_o(data_ra_o),
		.data_rb_o(data_rb_o)		
	);
	
	distributor distributor
	(
		.instruction(instruction_i),
		.regDst(1'b0),
		.operation(operation),
		.funct(funct),
		.inmediate(wire_inmediate),
		.wire_A(wire_A),
		.wire_B(wire_B),
		.direction(wire_direction),
		.wire_dest(wireRW_o)
	);

	control_unit control_unit
	(
		.clock(clock_i),
        .reset(reset_i),
        .opcode(operation),
        .funct(funct),
        .regDest(regDest),
        .wb_signals(wb_signals),
        .branch(branch),
		.tipeI(tipeI_signal),
        .regDest_signal(regDest_signal),
		.opcode_o(opcode_o),
        .mem_signals(mem_signals)
	);

	sign_extension sign_extension
	(
		.unextend_i(wire_inmediate),
        .extended_o(wire_inmediate_o) 
	);	

/* 	Mux2_1#(.NB_DATA(NB_DATA)) mux_reg_A
	(
		.inA(data_forward_EX_MEM_i), //1
		.inB(reg_data_ra),
		.sel(forward_A_i),
		.out(data_ra_branch)
	);
 */
/* 	Mux2_1#(.NB_DATA(NB_DATA)) mux_reg_B
	(
		.inA(data_forward_EX_MEM_i), //1
		.inB(reg_data_rb),
		.sel(forward_B_i),
		.out(data_rb_branch)
	); */
	/*
	Mux2_1#(.NB_DATA(NB_DATA)) mux_signal_control //WB, MEM, EX = 0 cuando hay una burbuja.
	(
		.inA(data_forward_EX_MEM_i), //1
		.inB(reg_data_rb),
		.sel(forward_B_i),
		.out(data_rb_branch)
	);
*/
endmodule



module decode_top
	#(
		parameter NB_DATA   = 32,		
		parameter NB_OPCODE = 6,
		parameter NB_REG    = 5				
	)
	(
		input wire clock_i,
		input wire reset_i,
		input wire [7-1:0] pc_decode,
		//input wire enable_i,
		input wire reg_write_i,
		input wire select_debug_or_wireA,	
		input wire [NB_REG-1:0] addr_reg_debug,	
		
		input wire [NB_DATA-1:0] instruction_i,		
		input wire [NB_REG-1:0] write_register_i,
		input wire [NB_DATA-1:0] data_rw_i,

		input wire decode_forward_A, 
        input wire decode_forward_B,
		input wire [NB_DATA-1:0] alu_result,

		input wire stall,

		// output wire [NB_REG-1:0] shamt_o,
		output wire [NB_REG-1:0] wireA_o, wireB_o, wireRW_o,

		output wire [5:0]mem_signals, 
		output wire [2:0]wb_signals,
        output wire [1:0]regDest_signal,
        output wire tipeI_signal,
        output wire shamt_signal,

        output wire [NB_OPCODE-1:0] opcode_o,
        output wire [5:0] funct_o,
        output wire [NB_DATA-1:0] wire_inmediate_sign_o,
        output wire [NB_DATA-1:0] data_ra_o,
        output wire [NB_DATA-1:0] data_rb_o,

		output wire [7-1:0] address_jump,
		output wire [7-1:0] address_branch
	);

	wire [NB_REG-1:0] addr_A_out;

	// Conexion distribuidor, banco de registros y control unit
	wire [5:0]operation;
	wire [5:0]funct;
	// wire regDest;
	wire branch;

	//distributor
	wire [NB_REG-1:0] wire_A;
	wire [NB_REG-1:0] wire_B;
	wire [26-1:0] wire_direction;
	wire [16-1:0] wire_inmediate;

	// control_unit
	wire [5:0]mem_signals_ctr; 
	wire [2:0]wb_signals_ctr;
	wire [1:0]regDest_signal_ctr;
	wire tipeI_signal_ctr;
	wire shamt_signal_ctr;
	wire [NB_OPCODE-1:0] opcode_ctr;

	wire [NB_DATA-1:0] data_ra, data_rb, data_ra_branch, data_rb_branch;

	wire [NB_DATA-1:0] wire_inmediate_sign;

	assign data_ra_o = data_ra;
	assign data_rb_o = data_rb;

    assign wireA_o = wire_A;
    assign wireB_o = wire_B;
    // assign funct_o = funct;
	assign wire_inmediate_sign_o = wire_inmediate_sign;

	assign address_jump = pc_decode + wire_direction;

    assign mem_signals = (stall) ? {6{1'b0}} : mem_signals_ctr;
	assign wb_signals = (stall) ? {3{1'b0}} : wb_signals_ctr;
	assign regDest_signal = (stall) ? {2{1'b0}} : regDest_signal_ctr;
	assign opcode_o = (stall) ? {6{1'b0}} : opcode_ctr;
	assign funct_o = (stall) ? {6{1'b0}} : funct;
	assign tipeI_signal = (stall) ? (1'b1) : tipeI_signal_ctr;
	assign shamt_signal = (stall) ? (1'b0) : shamt_signal_ctr;
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

	branch branch
	(
		.pc(pc_decode),
		.inmediate(wire_inmediate_sign),
		.data_ra_branch(data_ra_branch),
		.data_rb_branch(data_rb_branch),

		.is_equal(),
		.branch_address_o()
	);

 	multiplexor_2_in #(.NB_DATA(NB_REG)) addr_debug_or_wireA
	(
		.op1_i(wire_A),
		.op2_i(addr_reg_debug),
		.sel_i(select_debug_or_wireA),
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
		.data_ra_o(data_ra),
		.data_rb_o(data_rb)		
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
        // .funct(funct),
        // .regDest(regDest),
        .wb_signals(wb_signals_ctr),
        .branch(branch),
		.tipeI(tipeI_signal_ctr),
		
		.shamt(shamt_signal_ctr),

        .regDest_signal(regDest_signal_ctr),
		.opcode_o(opcode_o),
        .mem_signals(mem_signals_ctr)
	);

	sign_extension sign_extension
	(
		.unextend_i(wire_inmediate),
        .extended_o(wire_inmediate_sign) 
	);	


 	multiplexor_2_in#(.NB_DATA(NB_DATA)) forward_or_reg_A
	(
		.inA(alu_result), //1
		.inB(data_ra),
		.sel(decode_forward_A),
		.out(data_ra_branch)
	);
    multiplexor_2_in#(.NB_DATA(NB_DATA)) forward_or_reg_B
	(
		.inA(alu_result), //1
		.inB(data_rb),
		.sel(decode_forward_B),
		.out(data_rb_branch)
	);

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


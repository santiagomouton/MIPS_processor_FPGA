`timescale 1ns / 1ps

module decode_top
	#(
		parameter NB_DATA   = 32,		
		parameter NB_OPCODE = 6,
		parameter NB_REG    = 5				
	)
	(
		input wire clock_i,
		input wire reset_i,
		input wire [NB_DATA-1:0] pc_decode,
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

		output wire [5:0]mem_signals_o, 
		output wire [2:0]wb_signals_o,
        output wire [1:0]regDest_signal_o,
        output wire tipeI_signal_o,

        output wire shamt_signal_o,
        output wire [NB_OPCODE-1:0] opcode_o,
        output wire [5:0] funct_o,
        output wire [NB_DATA-1:0] wire_inmediate_sign_o,
        output wire [NB_DATA-1:0] data_ra_o,
        output wire [NB_DATA-1:0] data_rb_o,

		output wire pc_branch_or_jump_o,
		output wire [NB_DATA-1:0] address_jump_o,
		output wire [NB_DATA-1:0] address_branch_o,
		output wire [NB_DATA-1:0] address_register_o,
		output wire [1:0] pc_src_o,
		output wire halt_signal_o,
		output wire [31:0] wire_inmediate_paraver
	);

	wire [NB_REG-1:0] addr_A_out;

	// Conexion distribuidor, banco de registros y control unit
	wire [5:0]operation;
	wire [5:0]funct;
	wire is_equal;

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
	wire beq, bne, jump;
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

	// wire branch_taken = ((is_equal && beq) | (!is_equal && bne) | jump);
	wire branch_taken = (is_equal && beq) | (!is_equal && bne);
	assign pc_branch_or_jump_o = branch_taken | jump;

	assign address_jump_o 	 = pc_decode + {6'b0, wire_direction};
	assign address_register_o  = data_ra;

    assign mem_signals_o   	= (stall) ? {6'b0} : mem_signals_ctr;
	assign wb_signals_o     = (stall) ? {3'b0} : wb_signals_ctr;
	assign regDest_signal_o = (stall) ? {2'b0} : regDest_signal_ctr;
	assign opcode_o 	  	= (stall) ? {6'b0} : opcode_ctr;
	assign funct_o 		  	= (stall) ? {6'b0} : funct;
	assign tipeI_signal_o   = (stall) ? (1'b1) : tipeI_signal_ctr;
	assign shamt_signal_o   = (stall) ? (1'b0) : shamt_signal_ctr;


	branch branch
	(
		.pc(pc_decode),
		.inmediate(wire_inmediate_sign),
		.data_ra_branch(data_ra_branch),
		.data_rb_branch(data_rb_branch),

		.is_equal(is_equal),
		.branch_address_o(address_branch_o)
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
		// .regDst(1'b0),
		.operation(operation),
		.funct(funct),
		.inmediate(wire_inmediate),
		.wire_A(wire_A),
		.wire_B(wire_B),
		.direction(wire_direction),
		.wire_dest(wireRW_o)
	);
	assign wire_inmediate_paraver = {16'b0, wire_inmediate};

	control_unit control_unit
	(
        .opcode_i(operation),
        // .funct(funct),
		
		.tipeI_o(tipeI_signal_ctr),
 		.shamt_o(shamt_signal_ctr),
        .beq_o(beq),
		.bne_o(bne),
		.jump_o(jump),
		.pc_src_o(pc_src_o),

        .regDest_signal_o(regDest_signal_ctr),
        .wb_signals_o(wb_signals_ctr),
        .mem_signals_o(mem_signals_ctr),
		// .control_signals_o(control_signals_o),
		.opcode_o(opcode_ctr),
		.halt_signal_o(halt_signal_o)
	);

	sign_extension sign_extension
	(
		.unextend_i(wire_inmediate),
        .extended_o(wire_inmediate_sign) 
	);	

 //OJO CON ESTO, SELECCION QUIZAS INCORRECTA
 	multiplexor_2_in#(.NB_DATA(NB_DATA)) forward_or_reg_A
	(
		.op1_i(data_ra),
		.op2_i(alu_result), //1
		.sel_i(decode_forward_A),
		.data_o(data_ra_branch)
	);
    multiplexor_2_in#(.NB_DATA(NB_DATA)) forward_or_reg_B
	(
		.op1_i(data_rb),
		.op2_i(alu_result),
		.sel_i(decode_forward_B),
		.data_o(data_rb_branch)
	);

endmodule


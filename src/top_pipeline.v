`timescale 1ns / 1ps

module top_pipeline
	#(		
		parameter NB_DATA = 32,
		parameter NB_OPCODE = 6,
		parameter NB_FUNCTION = 6,
		parameter NB_REG  = 5,
		parameter NB_EX_CTRL  = 7,
		parameter NB_MEM_CTRL = 6,
		parameter NB_WB_CTRL  = 3,
		parameter N_REGISTER = 32,
		parameter N_BYTES    = 4,
		parameter N_BITS = 8,
        parameter NB_ADDR = 7		
	)
	(
		input wire clock,
		input wire reset,

        input wire select_debug_or_wireA,
        input wire [NB_REG-1:0] addr_reg_debug,
        output wire [NB_DATA-1:0] data_registers_debug,

        input wire [7-1:0] addr_mem_debug,
        input wire select_debug_or_alu_result,
        output wire [NB_DATA-1:0] data_mem_debug,

        output wire [NB_DATA-1:0] data_pc_debug,

        input wire [NB_DATA-1:0]data_inst_to_write,
        input wire ready_instr_to_write,
        input wire [NB_DATA-1:0]o_dir_mem_write,

        input wire en_pipeline,
        input wire en_read_inst,

        output wire halt_signal_o_wb,
        output wire halt_signal_decode_debug,

        output wire [NB_DATA-1:0] alu_result_o_mem_test,

        output wire [124:0] decode_signals_o,
        output wire [136:0] execute_signals_o,
        output wire [78:0] mem_signals_o,
        output wire [33:0] wb_signals_o,

        output wire [31:0] wire_inmediate_paraver

	);
    

	// wire [6:0]o_dir_mem_read;

    wire [NB_DATA-1:0] pc_fetch, pc_decode;
    wire [NB_DATA-1:0] instruction_fetch, instruction_decode;
    
	wire [5-1:0] wire_A_o_decode, wire_B_o_decode, wire_RW_o_decode;
	wire [NB_DATA-1:0] wire_inmediate_o_decode;
    wire [NB_OPCODE-1:0] opcode_o_decode;
    wire [5:0] funct_o_decode;
    wire [1:0] regDest_signal_decode;
    wire [NB_DATA-1:0] data_ra_o_decode, data_rb_o_decode;
    wire [5:0]mem_signals_decode;
    wire [2:0]wb_signals_decode;
    wire tipeI_signal_decode;
    wire halt_signal_decode;

    wire pc_branch_or_jump;
    wire [NB_DATA-1:0] address_jump, address_branch, address_register;
    wire [1:0]pc_src;
    wire bne, beq;

    //decode_execute_stage
    wire [NB_DATA-1:0] data_ra_o_execute, data_rb_o_execute;
    wire [NB_DATA-1:0] inmediate_o_execute;
    wire [NB_DATA-1:0] pc_o_execute;
    wire [5:0] funct_o_execute;
	wire [5:0]operation_o_execute;
	wire tipeI_o_execute;
    wire [5-1:0] wire_A_o_execute, wire_B_o_execute, wire_RW_o_execute;
    wire [1:0]regDest_signal_o_execute;
    wire [5:0]mem_signals_o_execute;
    wire [2:0]wb_signals_o_execute;
    wire halt_signal_o_execute;

    //execute_mem_stage
    wire [NB_DATA-1:0] pc_o_mem;
    wire [NB_DATA-1:0] data_wr_to_mem_o_mem;
    wire [NB_DATA-1:0] alu_result_execute;
    wire [NB_DATA-1:0] alu_result_o_mem;
    wire [NB_REG-1:0] writeReg_execute;
    wire [NB_REG-1:0] writeReg_o_mem;
    wire [5:0] mem_signals_o_mem;
    wire [2:0] wb_signals_o_mem;
    wire [NB_DATA-1:0] data_rb_o;
    wire halt_signal_o_mem;

    // mem_wb_stage
    wire [NB_DATA-1:0] data_read_interface_o;
    wire [NB_REG-1:0] writeReg_o_wb;
    wire [NB_DATA-1:0] mem_data_read_o_wb;
	wire [NB_DATA-1:0] alu_result_o_wb;
	wire [NB_DATA-1:0] pc_o_wb;
    wire [1:0] mem_to_reg_o_wb;
    wire reg_write_o_wb;
	wire [NB_DATA-1:0] data_write_to_reg;

    // forward_unit
    wire [1:0] forward_signal_regA, forward_signal_regB;

    // hazard_unit
    wire stall, pc_write_o, if_dec_write_o;

    // decode_forward
    wire [1:0] decode_forward_A, decode_forward_B;


    assign data_registers_debug = data_ra_o_decode;
    assign data_mem_debug = data_read_interface_o;
    assign data_pc_debug = pc_decode;
    // assign data_pc_debug = pc_fetch;

    // wire [NB_DATA-1:0] data_ra_branch_paraver, data_rb_branch_paraver;
    assign decode_signals_o = {1'b0, opcode_o_decode, funct_o_decode, pc_branch_or_jump, 
                                address_jump, address_branch, address_register, pc_src,
                                halt_signal_decode, tipeI_signal_decode, regDest_signal_decode,
                                mem_signals_decode, wb_signals_decode
                            };
    wire [NB_DATA-1:0] data_ra_paraver;
    assign execute_signals_o = {forward_signal_regA, forward_signal_regB, alu_result_o_mem,
                                // data_write_to_reg, 
                                data_ra_paraver, 
                                data_rb_o, 
                                writeReg_execute, 
                                alu_result_execute
                            };
    wire [NB_DATA-1:0] data_wr_to_mem_interface_o_paraver;
    assign mem_signals_o = {data_read_interface_o,
                            alu_result_o_mem,
                            writeReg_o_mem,
                            wb_signals_o_mem, 
                            halt_signal_o_mem,
                            mem_signals_o_mem
                            };

    assign wb_signals_o = {data_write_to_reg, mem_to_reg_o_wb};


    decode_forward decode_forward
    (
        .wire_A_dec_i(wire_A_o_decode),
		.wire_B_dec_i(wire_B_o_decode),
		.writeReg_mem_i(writeReg_o_mem),
		.ex_mem_reg_write_i(wb_signals_o_mem[2]),	
		.writeReg_wb_i(writeReg_o_wb),
		.mem_wb_reg_write_i(reg_write_o_wb),

		.decode_forward_A(decode_forward_A), 
        .decode_forward_B(decode_forward_B)        
    );

    hazard_unit hazard_unit
    (
		.execute_stage_mem_read_i(mem_signals_o_execute[4]),
		.memory_stage_mem_read_i(mem_signals_o_mem[4]),
        .execute_stage_reg_write_i(wb_signals_o_execute[2]),
		.branch_or_jr_i(bne|beq),
		.wire_A_decode_i(wire_A_o_decode),
		.wire_B_decode_i(wire_B_o_decode),
		// .dec_ex_register_write_i(wire_B_o_execute),
		.dec_ex_register_write_i(writeReg_execute),
		.ex_mem_register_write_i(writeReg_o_mem),
		.halt_signal_i(halt_signal_decode),

        .stall_o(stall),
		.pc_write_o(pc_write_o), //detiene cargar la sig direccion
		.if_dec_write_o(if_dec_write_o) //detiene cargar la instruccion en el registro IF_ID
    );

    forward_unit forward_unit
    (
		.register_a_i(wire_A_o_execute),
		.register_b_i(wire_B_o_execute),
		.ex_mem_writeReg_i(writeReg_o_mem),
		.mem_wb_writeReg_i(writeReg_o_wb),
		.ex_mem_reg_write_i(wb_signals_o_mem[2]),
		.mem_wb_reg_write_i(reg_write_o_wb),
		.forward_signal_regA(forward_signal_regA),
		.forward_signal_regB(forward_signal_regB)
    );

    wb_top wb_top
    (
		.mem_data_i(mem_data_read_o_wb),
		.alu_result_i(alu_result_o_wb),
		.pc_i(pc_o_wb),
		// input wire [NB_DATA-1:0] inm_ext_i, // LUI
		.mem_to_reg_i(mem_to_reg_o_wb),
		.data_write_to_reg_o(data_write_to_reg)
    );

    mem_wb_stage mem_wb_stage
    (
		.clock_i(clock),
		.reset_i(reset),
		.enable_pipe_i(en_pipeline),
		.mem_data_read_i(data_read_interface_o),
		.alu_result_i(alu_result_o_mem),
		.write_register_i(writeReg_o_mem),
        .wb_signals_i(wb_signals_o_mem),
        .halt_signal_i(halt_signal_o_mem),

		.pc_i(pc_o_mem),
		.write_register_o(writeReg_o_wb),
		.mem_data_read_o(mem_data_read_o_wb),
		.alu_result_o(alu_result_o_wb),
		.pc_o(pc_o_wb),
        .reg_write_o(reg_write_o_wb),
        .mem_to_reg_o(mem_to_reg_o_wb),
        .halt_signal_o(halt_signal_o_wb)
    );

    mem_top mem_top
    (
		.clock_i(clock),
		.reset_i(reset),
		.en_pipeline(en_pipeline),
		.alu_result_i(alu_result_o_mem[6:0]), // Resultado de alu como direccion de memoria
		.addr_mem_debug(addr_mem_debug),
		.select_debug_or_alu_result(select_debug_or_alu_result),
		.data_wr_to_mem(data_wr_to_mem_o_mem),
		.mem_signals_i(mem_signals_o_mem),
		.data_read_interface_o(data_read_interface_o),
		.data_wr_to_mem_interface_o_paraver(data_wr_to_mem_interface_o_paraver)
    );

    // assign alu_result_o_mem_test = {25'b0, mem_signals_o_mem};
    // assign alu_result_o_mem_test = instruction_fetch;

    ex_mem_stage ex_mem_stage
    (
		.clock(clock),   
		.reset_i(reset),
		.en_pipeline(en_pipeline),
		.data_wr_to_mem_i(data_rb_o),
		.alu_result_i(alu_result_execute),
		.writeReg_i(writeReg_execute),
        .pc_i(pc_o_execute),
        .mem_signals_i(mem_signals_o_execute), 
        .wb_signals_i(wb_signals_o_execute), 
        .halt_signal_i(halt_signal_o_execute),

		.data_wr_to_mem_o(data_wr_to_mem_o_mem),
        .alu_result_o(alu_result_o_mem),
        .writeReg_o(writeReg_o_mem),  
        .pc_o(pc_o_mem),
        .mem_signals_o(mem_signals_o_mem),
        .wb_signals_o(wb_signals_o_mem),
        .halt_signal_o(halt_signal_o_mem)
    );

    execute_top execute_top
    (
        .funct_i(funct_o_execute),		
		.opcode_i(operation_o_execute),		
		.data_ra_i(data_ra_o_execute),
		.data_rb_i(data_rb_o_execute),
		.inmediate_i(inmediate_o_execute),
		.tipeI_i(tipeI_o_execute),
		// input wire [NB_REG-1:0]	shamt_i,
		.wire_RW_i(wire_RW_o_execute),
        .wire_B_i(wire_B_o_execute),
		.regDest_signal_i(regDest_signal_o_execute),

        .forward_signal_regA_i(forward_signal_regA),
        .forward_signal_regB_i(forward_signal_regB),
        .ex_mem_data_i(alu_result_o_mem), // Resultado de la alu del ciclo anterior, para calculo de forward
        .mem_wb_data_i(data_write_to_reg),

		.data_rb_o(data_rb_o),
		.writeReg_o(writeReg_execute),
        .alu_result_o(alu_result_execute),

        //test
        .data_ra_paraver(data_ra_paraver)
    );

    decode_execute_stage decode_execute_stage
    (
		.clock(clock),   
		.reset_i(reset),
		.en_pipeline(en_pipeline),
		.pc_i(pc_decode),
		.function_i(funct_o_decode),
		.regDest_signal_i(regDest_signal_decode),
		.opcode(opcode_o_decode),
		.data_ra_i(data_ra_o_decode),
		.data_rb_i(data_rb_o_decode),
		.inm_ext_i(wire_inmediate_o_decode),
		.tipeI(tipeI_signal_decode),
        
        .register_a_i(wire_A_o_decode), 
        .register_b_i(wire_B_o_decode),
        .register_rw_i(wire_RW_o_decode),

        .mem_signals_i(mem_signals_decode),
        .wb_signals_i(wb_signals_decode),
        .halt_signal_i(halt_signal_decode),

		.data_ra_o(data_ra_o_execute),
		.data_rb_o(data_rb_o_execute),
		.inm_ext_o(inmediate_o_execute),
		.pc_o(pc_o_execute),
		.function_o(funct_o_execute),
		.regDest_signal_o(regDest_signal_o_execute),
		.opcode_o(operation_o_execute),
		.tipeI_o(tipeI_o_execute),
        .register_a_o(wire_A_o_execute), 
        .register_b_o(wire_B_o_execute),
        .register_rw_o(wire_RW_o_execute),
        .mem_signals_o(mem_signals_o_execute),
        .wb_signals_o(wb_signals_o_execute),
        .halt_signal_o(halt_signal_o_execute)
    );

    decode_top decode_top
    (
		.clock_i(clock),
		.reset_i(reset),
        .pc_decode(pc_decode), 
		//.enable_i,
		.reg_write_i(reg_write_o_wb),		
		.select_debug_or_wireA(select_debug_or_wireA),
		.addr_reg_debug(addr_reg_debug),
		.instruction_i(instruction_decode),		
		.write_register_i(writeReg_o_wb),
		.data_rw_i(data_write_to_reg),

        .stall(stall), //

		// output wire [NB_REG-1:0] shamt_o,
		.wireA_o(wire_A_o_decode), 
        .wireB_o(wire_B_o_decode),
        .wireRW_o(wire_RW_o_decode),
        .wire_inmediate_sign_o(wire_inmediate_o_decode),
		.mem_signals_o(mem_signals_decode), 
		.wb_signals_o(wb_signals_decode),
        .regDest_signal_o(regDest_signal_decode),
        .tipeI_signal_o(tipeI_signal_decode),

        .decode_forward_A_i(decode_forward_A), 
        .decode_forward_B_i(decode_forward_B),
        .alu_result_mem_i(alu_result_o_mem),

        .shamt_signal_o(), // vacio por ahora
        
        .opcode_o(opcode_o_decode),
        .funct_o(funct_o_decode),
        .data_ra_o(data_ra_o_decode),
        .data_rb_o(data_rb_o_decode),

        .pc_branch_or_jump_o(pc_branch_or_jump),
		.address_jump_o(address_jump),
		.address_branch_o(address_branch),
		.address_register_o(address_register),
		.pc_src_o(pc_src),
        .halt_signal_o(halt_signal_decode),
        .bne_o(bne),
        .beq_o(beq),
        .wire_inmediate_paraver(),
        // .data_ra_branch_paraver(data_ra_branch_paraver),
        // .data_rb_branch_paraver(data_rb_branch_paraver)
        .data_ra_branch_paraver(),
        .data_rb_branch_paraver()
    );

	fetch_decode_stage fetch_decode_stage
	(
		.clock_i(clock), 
		.reset_i(reset), 
		.en_pipeline(en_pipeline && if_dec_write_o),	
		.pc_i(pc_fetch),
		.pc_o(pc_decode),
		.instruction_i(instruction_fetch),
		.instruction_o(instruction_decode)	
	);

	fetch_top fetch_top
	(
		.clock_i(clock),
		.reset_i(reset),		
		.enable_i(en_pipeline && pc_write_o),
		.en_read_i(en_read_inst), 
		.en_write_i(ready_instr_to_write),
        .addr_i_write(o_dir_mem_write),
        .data_i(data_inst_to_write),
        .pc_branch_or_jump(pc_branch_or_jump),
		.address_jump(address_jump),
		.address_branch(address_branch),
        .address_register(address_register),
		.pc_src(pc_src),
        .pc_o(pc_fetch),
		.instruction_o(instruction_fetch)
	);

    assign wire_inmediate_paraver = instruction_decode;

    assign halt_signal_decode_debug = halt_signal_decode;

endmodule


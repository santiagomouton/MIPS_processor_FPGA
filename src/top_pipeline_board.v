`timescale 1ns / 1ps

module top_pipeline_board
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
		input wire clk_in,
		input wire reset,
        input wire receiving,
        output wire debug_out,

/*         output wire [12-1:0] state_paraver,
        output wire [N_BITS-1:0] data_to_send_paraver,
        output wire [7-1:0]o_dir_wr_mem_paraver,
        output wire [NB_DATA-1:0] o_B_to_alu_paraver,
        output wire [6-1:0] funct_for_alu_paraver */

        output wire state_Iddle,
        output wire state_Receive_Instruction,
        output reg state_Tx_data_to_computer,
        output wire state_Continue

	);


	wire [7:0]  dout;
	wire read_rx;
	// wire [5 - 1:0]rx_state;

    wire en_pipeline;
	wire finish_rcv; 
    wire ready_data_mem;
	wire [NB_DATA-1:0]o_data_mem;
	wire [6:0]o_dir_mem_write;
	wire [6:0]o_dir_mem_read;

    wire [6:0] pc_fetch;
    wire [NB_DATA-1:0] instruction_fetch;
    
    wire [6:0] pc_decode;
    wire [NB_DATA-1:0] instruction_decode;
	wire [5-1:0] wire_A_o_decode;
	wire [5-1:0] wire_B_o_decode;
	wire [5-1:0] wire_RW_o_decode;
	wire [NB_DATA-1:0] wire_inmediate_o_decode;
    wire [NB_OPCODE-1:0] opcode_o_decode;
    wire [5:0] funct_o_decode;
    wire [1:0]regDest_signal_decode;
    wire [NB_DATA-1:0] data_ra_o_decode;
    wire [NB_DATA-1:0] data_rb_o_decode;
    wire [5:0]mem_signals_decode;
    wire [2:0]wb_signals_decode;
    wire tipeI_signal_decode;
    wire halt_signal_decode;

    wire pc_branch_or_jump;
    wire [7-1:0] address_jump;
    wire [7-1:0] address_branch;
    wire [7-1:0] address_register;
    wire [1:0]pc_src;

    //decode_execute_stage
    wire [NB_DATA-1:0] data_ra_o_execute;
    wire [NB_DATA-1:0] data_rb_o_execute;
    wire [NB_DATA-1:0] inmediate_o_execute;
    wire [7-1:0] pc_o_execute;
    wire [5:0] funct_o_execute;
	wire [5:0]operation_o_execute;
	wire tipeI_o_execute;
    wire [5-1:0] wire_A_o_execute;
    wire [5-1:0] wire_B_o_execute;
    wire [5-1:0] wire_RW_o_execute;
    wire [1:0]regDest_signal_o_execute;
    wire [5:0]mem_signals_o_execute;
    wire [2:0]wb_signals_o_execute;
    wire halt_signal_o_execute;

    //execute_mem_stage
    wire [7-1:0] pc_o_mem;
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
	wire [6:0] pc_o_wb;
    wire [1:0] mem_to_reg_o_wb;
    wire reg_write_o_wb;
	wire [NB_DATA-1:0] data_write_to_reg;
    wire halt_signal_o_wb;

    // debug_unit
    wire select_debug_or_wireA;
    wire [NB_REG-1:0] addr_reg_debug;
    wire [NB_DATA-1:0] data_registers_debug;
    wire [7-1:0] addr_mem_debug;
	wire select_debug_or_alu_result;
	wire [NB_DATA-1:0] data_mem_debug;
    wire [6:0] data_pc_debug;

    // forward_unit
    wire [1:0] forward_signal_regA;
    wire [1:0] forward_signal_regB;

    // hazard_unit
    wire stall;
    wire pc_write_o;
    wire if_dec_write_o;

    // decode_forward
    wire decode_forward_A;
    wire decode_forward_B;

    wire en_read_i;

    assign data_registers_debug = data_ra_o_decode;
    assign data_mem_debug = data_read_interface_o;
    assign data_pc_debug = pc_decode;

    wire clk_wiz_out;
    wire locked;
    wire clock;

    clk_wiz_0 clock_wizard
    (
        // Clock out ports
        .clk_out1(clk_wiz_out),     // output clk_out1
        // Status and control signals
        .reset(reset),          // input reset
        .locked(locked),        // output locked
        // Clock in ports
        .clk_in1(clk_in)       // input clk_in1
    );
    assign clock = clk_wiz_out & locked;
 


    wire [12-1:0] state_paraver;
    assign state_Iddle               = state_paraver[0];
    assign state_Receive_Instruction = state_paraver[1];
    // assign state_Tx_data_to_computer = state_paraver[5];
    assign state_Continue            = state_paraver[4];

    always @(posedge clock) begin
        if (reset) begin
            state_Tx_data_to_computer <= 1'b0;
        end
        if (halt_signal_decode) begin
            state_Tx_data_to_computer <= 1'b1;
        end
    end

    decode_forward decode_forward
    (
        .wire_A_dec(wire_A_o_decode),
		.wire_B_dec(wire_B_o_decode),
		.writeReg(writeReg_o_mem),
		.ex_mem_reg_write(wb_signals_o_mem[2]),	

		.decode_forward_A(decode_forward_A), 
        .decode_forward_B(decode_forward_B)        
    );

    hazard_unit hazard_unit
    (
		.dec_ex_mem_read(mem_signals_o_execute[5]),
		.wire_A_decode(wire_A_o_decode),
		.wire_B_decode(wire_B_o_decode),
		.dec_ex_register_b(wire_B_o_execute),
		// .[NB_REG-1:0] writeReg_execute,
		.halt_signal(halt_signal_decode),

		.EX_reg_write_i(1'b0), //vacio por ahora
		.EX_write_register_i(1'b0), //vacio por ahora

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
		.data_write_to_reg(data_write_to_reg)
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
		.alu_result_i(alu_result_o_mem[6:0]),
		.addr_mem_debug(addr_mem_debug),
		.select_debug_or_alu_result(select_debug_or_alu_result),
		.data_wr_to_mem(data_wr_to_mem_o_mem),
		.mem_signals_i(mem_signals_o_mem),
		.data_read_interface_o(data_read_interface_o)
    );

    ex_mem_stage ex_mem_stage
    (
		.clock(clock),   
		.reset(reset),
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
		.wire_RW(wire_RW_o_execute),
        .wire_B(wire_B_o_execute),
		.regDest_signal_i(regDest_signal_o_execute),
		.data_rb_o(data_rb_o),
		.writeReg_o(writeReg_execute),
        .alu_result_o(alu_result_execute),

        .forward_signal_regA(forward_signal_regA),
        .forward_signal_regB(forward_signal_regB),
        .ex_mem_data(alu_result_o_mem),
        .mem_wb_data(data_write_to_reg),

        //test
        .o_B_to_alu_paraver(),
        .funct_for_alu_paraver()
    );

    decode_execute_stage decode_execute_stage
    (
		.clock(clock),   
		.reset(reset),
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
		.mem_signals(mem_signals_decode), 
		.wb_signals(wb_signals_decode),
        .regDest_signal(regDest_signal_decode),
        .tipeI_signal(tipeI_signal_decode),

        .decode_forward_A(decode_forward_A), 
        .decode_forward_B(decode_forward_B),
        .alu_result(alu_result_o_mem),

        .shamt_signal(), // vacio por ahora
        
        .opcode_o(opcode_o_decode),
        .funct_o(funct_o_decode),
        .data_ra_o(data_ra_o_decode),
        .data_rb_o(data_rb_o_decode),

        .pc_branch_or_jump(pc_branch_or_jump),
		.address_jump(address_jump),
		.address_branch(address_branch),
		.address_register(address_register),
		.pc_src(pc_src),
        .halt_signal(halt_signal_decode)
    );

	fetch_decode_stage fetch_decode_stage
	(
		.clock_i(clock),  
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
		.en_read_i(en_read_i), 
		.en_write_i(ready_data_mem),
        .addr_i_write(o_dir_mem_write),
        .data_i(o_data_mem),
        .pc_branch_or_jump(pc_branch_or_jump),
		.address_jump(address_jump),
		.address_branch(address_branch),
        .address_register(address_register),
		.pc_src(pc_src),
        .pc_o(pc_fetch),
		.instruction_o(instruction_fetch)
	);

	debug_unit debug_unit
	(
        .clock_i(clock),
        .reset_i(reset),
        .halt_signal(halt_signal_o_wb),
	    .tx_rx(receiving),
	    .select_debug_or_wireA(select_debug_or_wireA),
	    .addr_reg_debug(addr_reg_debug),
	    .data_registers_debug(data_registers_debug),

        .addr_mem_debug(addr_mem_debug),
	    .select_debug_or_alu_result(select_debug_or_alu_result),
	    .data_mem_debug(data_mem_debug),

        .data_pc_debug(data_pc_debug),
    
        .state_paraver(state_paraver),
        .count_paraver(),
        .data_to_send_paraver(), 
        .en_send_registers_paraver(), 
        .tx_done_paraver(), 
        .count_send_bytes_paraver(),

        .debug_out(debug_out), 
	    .o_data_mem(o_data_mem),
	    .write_to_register(ready_data_mem),
	    .o_dir_wr_mem(o_dir_mem_write),
        .en_pipeline_o(en_pipeline),
        .en_read_mem(en_read_i),
        
        .instruction_decode(instruction_decode)
	);
    

    // assign o_data_mem_paraver = o_data_mem;
    // assign o_dir_wr_mem_paraver = o_dir_mem_write;

endmodule


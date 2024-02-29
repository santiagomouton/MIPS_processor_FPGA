`timescale 1ns / 1ps

module top_board_no_test
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

        output wire state_Iddle,
        output wire state_Receive_Instruction,
        output wire state_Tx_data_to_computer,
        output wire state_Continue
    );
    
    wire clock;
    // wire clk_wiz_out;
    wire locked;


    clk_wiz_0 clock_wizard
    (
        // Clock out ports
        .clk_out1(clock),     // output clk_out1
        // Status and control signals
        .reset(reset),          // input reset
        .locked(locked),        // output locked
        // Clock in ports
        .clk_in1(clk_in)       // input clk_in1
    );
    // assign clock = clk_wiz_out & locked;

    // assign clock = (locked)? clk_wiz_out:1'b0;


    wire [12-1:0] state_paraver;
    assign state_Iddle               = state_paraver[0];
    assign state_Receive_Instruction = state_paraver[1];
    assign state_Tx_data_to_computer = state_paraver[5];
    assign state_Continue            = state_paraver[4];

    wire halt_signal_decode;
/*     always @(posedge clock) begin
        if (reset) begin
            state_Tx_data_to_computer <= 1'b0;
        end
        else if (halt_signal_decode) begin
            state_Tx_data_to_computer <= 1'b1;
        end
    end */


    wire select_debug_or_wireA;
    wire select_debug_or_alu_result;
    wire [NB_REG-1:0] addr_reg_debug;
    wire [7-1:0] addr_mem_debug;

    //cambiar por modulo uart
    wire [NB_DATA-1:0] data_registers_debug, alu_result_o_mem_test;
    wire [NB_DATA-1:0] data_mem_debug;
    wire [7-1:0] data_pc_debug;

    wire [NB_DATA-1:0] data_inst_to_write;
    wire ready_instr_to_write;
    wire [6:0] o_dir_mem_write;
    
    wire en_pipeline;
    wire en_read_inst;

    wire halt_signal_o_wb;

    top_pipeline mips(
		.clock(clock),
		.reset(reset),

        .select_debug_or_wireA(select_debug_or_wireA),
        .addr_reg_debug(addr_reg_debug),
        .data_registers_debug(data_registers_debug),

        .addr_mem_debug(addr_mem_debug),
        .select_debug_or_alu_result(select_debug_or_alu_result),
        .data_mem_debug(data_mem_debug),

        .data_pc_debug(data_pc_debug),

        .data_inst_to_write(data_inst_to_write),
        .ready_instr_to_write(ready_instr_to_write),
        .o_dir_mem_write(o_dir_mem_write),

        .en_pipeline(en_pipeline),
        .en_read_inst(en_read_inst),
        
        /*      
        output wire [NB_DATA-1:0] o_B_to_alu_paraver,
        output wire [6-1:0] funct_for_alu_paraver */

        .halt_signal_o_wb(halt_signal_o_wb),
        .halt_signal_decode_debug(halt_signal_decode),

        .alu_result_o_mem_test(alu_result_o_mem_test)
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

        .debug_out(debug_out), 
	    .o_data_mem(data_inst_to_write),
	    .write_to_register(ready_instr_to_write),
	    .o_dir_wr_mem(o_dir_mem_write),
        .en_pipeline_o(en_pipeline),
        .en_read_mem(en_read_inst),

        .alu_result_o_mem_test(alu_result_o_mem_test)
	);


endmodule
`timescale 1ns / 1ps

module mem_top
	#(
		parameter NB_DATA = 32,
		parameter NB_ADDR = 7
	)
	(
		input wire clock_i,
		input wire reset_i,
		input wire en_pipeline,
		input wire [NB_ADDR-1:0] alu_result_i,
		input wire [NB_ADDR-1:0] addr_mem_debug,
		input wire select_debug_or_alu_result,
		input wire [NB_DATA-1:0] data_wr_to_mem,
		input wire [6-1:0] mem_signals_i,

		output wire [NB_DATA-1:0] data_read_interface_o,
		output wire [NB_DATA-1:0] data_wr_to_mem_interface_o_paraver
	);		
    
    wire [NB_DATA-1:0] DATAmem_o;
    wire [NB_DATA-1:0] data_wr_to_mem_interface_o;
	wire [NB_ADDR-1:0] addr_mem;
	wire [6-1:0] mem_signals;


	multiplexor_2_in#(.NB_DATA(NB_ADDR)) mem_addr_alu_or_debug
	(
		.op1_i(alu_result_i),
		.op2_i(addr_mem_debug),
		.sel_i(select_debug_or_alu_result),
		.data_o(addr_mem)	
	);

	multiplexor_2_in#(.NB_DATA(6)) mem_signals_debug_or_not
	(
		.op1_i(mem_signals_i),
		.op2_i(6'b110100),
		.sel_i(select_debug_or_alu_result),
		.data_o(mem_signals)	
	);

    DATAmem DATAmem
    (
        .clock_i(clock_i),
        .reset_i(reset_i),
        .enable_mem_i(en_pipeline), 
        .addr_i(addr_mem),
        // .addr_i(6'b000011),
        .data_write_i(data_wr_to_mem_interface_o),
        // .data_write_i(data_wr_to_mem),
        .mem_read_i(mem_signals[4]),    //señales para lectura 
        .mem_write_i(mem_signals[3]),   // o escritura
        .data_o(DATAmem_o)
    );

    interfaceDataMEM interfaceDataMEM
    (
		.data_write_i(data_wr_to_mem),
		.data_read_i(DATAmem_o),
   		.mem_signals_i(mem_signals),
   		.data_write_o(data_wr_to_mem_interface_o),
   		.data_read_o(data_read_interface_o)
    );
	assign data_wr_to_mem_interface_o_paraver = data_wr_to_mem_interface_o;

endmodule
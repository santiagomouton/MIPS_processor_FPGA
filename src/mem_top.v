
`define MEM_READ 5
`define MEM_WRITE 4

module mem_top
	#(
		parameter NB_DATA = 32
	)
	(
		input wire clock_i,
		input wire reset_i,
		input wire en_pipeline,
		input wire [6:0] alu_result_i,
		input wire [NB_DATA-1:0] data_wr_to_mem,
		input wire [6-1:0] mem_signals_i,

		output wire [NB_DATA-1:0] data_read_interface_o
	);		
    
    wire [NB_DATA-1:0] DATAmem_o;
    wire [NB_DATA-1:0] data_wr_to_mem_interface_o;


    DATAmem DATAmem
    (
        .clock_i(clock_i),
        .enable_mem_i(en_pipeline), 
        .addr_i(alu_result_i),
        .data_write_i(data_wr_to_mem_interface_o),
        .mem_read_i(mem_signals_i[4]),    //señales para escritura o lectura
        .mem_write_i(mem_signals_i[3]),   //
        .data_o(DATAmem_o)
    );

    interfaceDataMEM interfaceDataMEM
    (
		.data_write_i(data_wr_to_mem),
		.data_read_i(DATAmem_o),
   		.mem_signals_i(mem_signals_i),
   		.data_write_o(data_wr_to_mem_interface_o),
   		.data_read_o(data_read_interface_o)
    );


endmodule
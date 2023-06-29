//`include "parameters.vh"

module top_mem_instr
	#(	
		parameter CLK         = 30E6,
		parameter BAUD_RATE  = 203400,	
		parameter NB_DATA = 32,	
		parameter NB_REG  = 5,
		parameter N_BITS  = 8				
	)
	(
		//TX
		input   wire  [N_BITS - 1:0]   din,
		output wire read_tx,

		// BAUDRATE
		input wire clock,
		input wire reset,


		input wire en_read_i,		

		input wire empty,
		// input wire en_write_i,
		// input wire [`ADDRWIDTH-1:0] wr_addr_i, // enviado por debug_unit para cargar instruccion 			
		// input wire [NB_DATA-1:0] inst_load_i, //instruccion a cargar en la memoria por debug_unit
			
		//output wire [`ADDRWIDTH-1:0] pc_o,		
		output wire [NB_DATA-1:0] instruction_o,
		output wire [N_BITS-1:0] salida_de_rx,
		output wire conexion_tx_rx,
		output wire finish_recieve,
		output wire [4:0]rx_state_o,
		output wire finish_send,
		output wire [31:0]intMem_data_o,
		output wire intMem_ready
	);

	wire [7:0]  dout;
	wire tx_rx;
	wire tick;
	wire read_rx; 
	
    // wire    [NB_DATA - 1:0] o_tx;
    wire tx_done_tick;

	wire ready_data_mem;
	wire [NB_DATA-1:0]o_data_mem;
	wire [6:0]o_dir_mem;

	wire [5 - 1:0]rx_state;

	assign finish_send = tx_done_tick;
	
	/* datos de rx uart */
	assign rx_state_o = rx_state;
	assign salida_de_rx = dout;
	assign finish_recieve = read_rx;
	assign conexion_tx_rx = tx_rx;

	/* salida interface a memoria*/
	assign intMem_data_o = o_data_mem;
	assign intMem_ready = ready_data_mem;

	INSTmem mem_instruction
	(
		.clock_i(clock),				
		.addr_i(o_dir_mem),
		.en_write_i(ready_data_mem),
		.en_read_i(en_read_i),
		.data_i(o_data_mem),
		.data_o(instruction_o)
	);
	interfaceMEM interface_mem
	(
		.reset(reset),
		.wr(read_rx),
		.in_rx(dout),          // Se presenta los bit provistos por rx uart
		.o_data_mem(o_data_mem),
		.o_dir_mem(o_dir_mem),
		.ready(ready_data_mem),
		.clock(clock)		
	);
    // ______________________ BRG ____________ //
    BaudRateGenerator myBRG (
        .tick   (tick),
        .clock  (clock),
        .reset  (reset)
    );
    // ____________________ Rx   ____________________ //
    rx_uart myrx_uart(
        .s_tick(tick), 
        .rx(tx_rx),
        .rx_done_tick(read_rx), 
        .dout(dout),
        .clock(clock),
        .rx_state(rx_state),
        .reset(reset)
    );
   // ______________________ Tx ____________ //
    tx_uart mytx_uart(
        .s_tick(tick), 
        .tx(tx_rx),							// bit salida hacia rx
        .read_tx(read_tx),					// habilitado para leer
        .tx_done_tick(tx_done_tick),                                     // 1 cuando termino de enviar
        .tx_start(empty),												// 1 cuando comienza a transmitir
        .din(din),							// dato a leer
        .clock(clock),
        .reset(reset)
    );


endmodule
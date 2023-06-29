//`include "parameters.vh"

module top_from_mem_to_execute
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

		//PC
		input wire enable,


		input wire en_read_i,
		input wire [7-1:0]next_addr_i,
		input wire empty,
		// input wire en_write_i,
		// input wire [`ADDRWIDTH-1:0] wr_addr_i, // enviado por debug_unit para cargar instruccion 			
		// input wire [NB_DATA-1:0] inst_load_i, //instruccion a cargar en la memoria por debug_unit
			
		output wire [7-1:0] pc_o,		
		output wire [NB_DATA-1:0] instruction_o,
		output wire [N_BITS-1:0] salida_de_rx,
		output wire conexion_tx_rx,
		output wire finish_recieve,
		output wire [4:0]rx_state_o,
		output wire finish_send,
		output wire [31:0]intMem_data_o,
		output wire [NB_DATA-1:0]data_o_fetch,
		output wire intMem_ready,
		output wire [NB_DATA-1:0]operation_o,
		output wire [NB_DATA-1:0]inmediate_o_paraver,
		output wire tipeI_paraver
	);

	wire [7:0]  dout;
	wire tx_rx;
	wire tick;
	wire read_rx; 
	
    // wire    [NB_DATA - 1:0] o_tx;
    wire tx_done_tick;

	wire ready_data_mem;
	wire [NB_DATA-1:0]o_data_mem;
	wire [6:0]o_dir_mem_write;
	wire [6:0]o_dir_mem_read;

	wire [5 - 1:0]rx_state;

	wire [NB_DATA-1:0]data_o;
	wire finish_rcv;
	wire en_pipeline;

	// Conexion distribuidor, banco de registros y control unit
	wire [5:0]operation;
	wire [5:0]funct;
	wire regDest;
	wire regWrite;
	wire branch;
    wire [NB_DATA-1:0] data_ra_register;
    wire [NB_DATA-1:0] data_rb_register;

	//distributor
	wire [5-1:0] wire_A;
	wire [5-1:0] wire_B;
	wire [5-1:0] wire_RW;
	wire [26-1:0] wire_direction;
	wire [16-1:0] wire_inmediate;

	//sign extension
	wire [31:0] wire_inmediate_o;

    //decode_execute_stage
    wire [NB_DATA-1:0] data_ra_o;
    wire [NB_DATA-1:0] data_rb_o;
    wire [NB_DATA-1:0] inmediate_o;
    wire [7-1:0] pc_o_ex_stage;
    wire [5:0] funct_o_ex_stage;
	wire [5:0]operation_dec_ex_stage;
	wire [5:0]operation_dec_ex_stage_o;
	wire tipeI_dec_ex_stage;
	wire tipeI_dec_ex_stage_o;

	//inmediate_or_dataB
	wire [NB_DATA-1:0] o_B_to_alu;

	//alu interface
    wire [5:0] funct_for_alu;

	// data para escribir en registro
	reg [NB_DATA-1:0] write_data_reg = 1;

	assign finish_recieve = finish_rcv; 

	assign finish_send = tx_done_tick;
	
	/* datos de rx uart */
	assign rx_state_o = rx_state;
	assign salida_de_rx = dout;
	assign conexion_tx_rx = tx_rx;

	/* salida interface a memoria*/
	assign intMem_data_o = o_data_mem;
	assign intMem_ready = ready_data_mem;

	/* salida memoria a fetch stage */
	assign data_o_fetch = data_o;

    /* salida de decode_execute_stage */
	assign inmediate_o_paraver = o_B_to_alu;
	assign tipeI_paraver = tipeI_dec_ex_stage;


    alu alu
    (
        .i_a(data_ra_o), //input a 
        .i_b(o_B_to_alu), //input b 
        .i_op(funct_for_alu),
        .o_o(operation_o)
    );

	interfaceALU interfaceALU
	(
		.funct(funct_o_ex_stage),
		.opcode(operation_dec_ex_stage_o),
		.funct_for_alu(funct_for_alu)
	);

	inmediate_or_dataB inmediate_or_dataB
	(
		.tipeI(tipeI_dec_ex_stage_o),
		.inmediate(inmediate_o),
		.dataB(data_rb_o),
		.o_B_to_alu(o_B_to_alu)

	);

    decode_execute_stage decode_execute_stage
    (
		.clock(clock),   
		.reset(reset),
		.en_pipeline(en_pipeline),
		.pc_i(pc_o),
		.function_i(funct),
		.opcode(operation_dec_ex_stage),
		.data_ra_i(data_ra_register),
		.data_rb_i(data_rb_register),
		.inm_ext_i(wire_inmediate_o),
		.tipeI(tipeI_dec_ex_stage),
		//.input wire [NB_EX_CTRL-1:0] EX_control_i,
		.data_ra_o(data_ra_o),
		.data_rb_o(data_rb_o),
		.inm_ext_o(inmediate_o),
		.pc_o(pc_o_ex_stage),
		.function_o(funct_o_ex_stage),
		.opcode_o(operation_dec_ex_stage_o),
		.tipeI_o(tipeI_dec_ex_stage_o)
		//output wire [NB_EX_CTRL-1:0] EX_control_o,
    );

	sign_extension sign_extension
	(
		.unextend_i(wire_inmediate),
        .extended_o(wire_inmediate_o) 
	);

	control_unit control_unit
	(
		.clock(clock),
        .reset(reset),
        .opcode(operation),
        .funct(funct),
        .regDest(regDest),
        .regWrite(regWrite),
        .branch(branch),
		.tipeI(tipeI_dec_ex_stage),
		.opcode_o(operation_dec_ex_stage)
	);

	bank_registers bank_registers
	(
		.clock_i(clock),
		.reset_i(reset),
		.rw_i(regWrite), 
		.addr_ra_i(wire_A),
		.addr_rb_i(wire_B),
		.addr_rw_i(wire_RW),
		.data_rw_i(write_data_reg),
		.data_ra_o(data_ra_register),
		.data_rb_o(data_rb_register)		
	);

	distributor distributor
	(
		.instruction(instruction_o),
		.regDst(regDest),
		.operation(operation),
		.funct(funct),
		.inmediate(wire_inmediate),
		.wire_A(wire_A),
		.wire_B(wire_B),
		.direction(wire_direction),
		.wire_dest(wire_RW)
	);

	fetch_decode_stage fetch_decode_stage
	(
		.clock_i(clock),  
		.en_pipeline(en_pipeline),		
		.pc_i(o_dir_mem_read),
		.pc_o(pc_o),
		.instruction_i(data_o),
		.instruction_o(instruction_o)	
	);

	debug_unit debug_unit
	(
		.clock(clock),
		.finish_rcv(finish_rcv),
		.en_pipeline_o(en_pipeline)	
	);

	INSTmem mem_instruction
	(
		.clock_i(clock),				
		.addr_i_write(o_dir_mem_write),
		.addr_i_read(o_dir_mem_read),
		.en_write_i(ready_data_mem),
		.en_read_i(en_read_i),
		.data_i(o_data_mem),
		.data_o(data_o)
	);

	pc pc
	(
		.clock(clock),				
		.reset(reset),	
		.enable(enable),				
		.next_addr_i(next_addr_i),
		.next_addr_o(o_dir_mem_read)
	);

	interfaceMEM interface_mem
	(
		.reset(reset),
		.wr(read_rx),
		.in_rx(dout),          // Se presenta los bit provistos por rx uart
		.o_data_mem(o_data_mem),
		.o_dir_mem(o_dir_mem_write),
		.ready(ready_data_mem),
		.finish_rcv(finish_rcv),
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
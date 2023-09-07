//`include "parameters.vh"

module top_pc_to_data_mem
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
		// output wire [NB_DATA-1:0] instruction_o,
		output wire [N_BITS-1:0] salida_de_rx,
		output wire conexion_tx_rx,
		output wire finish_recieve,
		output wire [4:0]rx_state_o,
		output wire finish_send,
		output wire [31:0]intMem_data_o,
		output wire [NB_DATA-1:0]data_o_fetch,
		output wire intMem_ready,
		output wire [NB_DATA-1:0]operation_o_paraver,
		output wire [NB_DATA-1:0]inmediate_o_paraver,
		output wire [NB_DATA-1:0]data_a_o_paraver,
		output wire [NB_DATA-1:0]dataInterfaceMEM_o_paraver,
		output wire [NB_DATA-1:0]dataWr_ex_mem_stage_o_paraver,
		output wire [6-1:0]mem_signals_o_paraver,
        output wire [4:0] wire_A_paraver,
        output wire [1:0] mem_to_reg_signal_paraver
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
	wire [6:0]next_addr_plus_four_o;

	wire [5 - 1:0]rx_state;

	wire [NB_DATA-1:0]data_o;
	wire finish_rcv;
	wire en_pipeline;

	// Conexion distribuidor, banco de registros y control unit
	wire [5:0]operation;
	wire [5:0]funct;
	wire regDest;
	wire [2:0]wb_signals;
	wire branch;
    wire [NB_DATA-1:0] data_ra_register;
    wire [NB_DATA-1:0] data_rb_register;
	wire [NB_DATA-1:0] instruction_o;
    wire [1:0]regDest_signal;
    wire [5:0]mem_signals;

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
    wire [5-1:0] wire_A_dec_ex_stage_o;
    wire [5-1:0] wire_B_dec_ex_stage_o;
    wire [5-1:0] wire_RW_dec_ex_stage_o;
    wire [1:0]regDest_signal_dec_ex_stage_o;
    wire [5:0]mem_signals_dec_ex_stage_o;
    wire [2:0]wb_signals_dec_ex_stage_o;

    //multiplexor_3_in
    wire [NB_REG-1:0] writeReg_dec_ex;

	//inmediate_or_dataB
	wire [NB_DATA-1:0] o_B_to_alu;

	//alu interface
    wire [5:0] funct_for_alu;

    //ex_mem_stage
    wire [7-1:0] pc_ex_mem_stage_o;
    wire [NB_DATA-1:0] data_wr_to_mem_ex_mem_stage_o;
    wire [NB_DATA-1:0] alu_result_i;
    wire [NB_DATA-1:0] alu_result_ex_mem_o;
    wire [NB_REG-1:0] writeReg_ex_mem;
    wire [5:0] mem_signals_ex_mem_o;
    wire [2:0]wb_signals_ex_mem_stage_o;

    //interfaceDataMEM
    wire [NB_DATA-1:0] data_wr_to_mem_interface_o;
    wire [NB_DATA-1:0] data_read_interface_o;

    //DATAmem
    wire [NB_DATA-1:0] DATAmem_o; 

    // mem_wb_stage
    wire [NB_DATA-1:0] alu_result_mem_wb_o;
    wire [NB_DATA-1:0] mem_data_read_mem_wb_stage_o;
    wire [NB_REG-1:0] writeReg_mem_wb_stage_o;
    wire [7-1:0] pc_mem_wb_stage_o;
    wire reg_write_wb_stage_o;
    wire [2-1:0] mem_to_reg_mem_wb_stage_o;

	// data para escribir en registro
	wire [NB_DATA-1:0] data_write_to_reg;

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

    /* señales paraver */
	assign inmediate_o_paraver = o_B_to_alu;
	assign data_a_o_paraver = data_ra_register;
    assign dataInterfaceMEM_o_paraver = data_write_to_reg;
    assign dataWr_ex_mem_stage_o_paraver = data_read_interface_o;
    assign mem_signals_o_paraver = mem_signals_ex_mem_o;
    assign mem_to_reg_signal_paraver = mem_to_reg_mem_wb_stage_o;
    assign operation_o_paraver = alu_result_i;
    assign wire_A_paraver = wire_A;


    multiplexor_4_in multiplexor_4_in
    (
		.op1_i(mem_data_read_mem_wb_stage_o),
		.op2_i(alu_result_mem_wb_o),
		.op3_i({{25'b0}, pc_mem_wb_stage_o}),
		.op4_i(32'b0),
		.sel_i(mem_to_reg_mem_wb_stage_o),
		.data_o(data_write_to_reg)
    );

    mem_wb_stage mem_wb_stage
    (
		.clock_i(clock),
		.reset_i(reset),
		.enable_pipe_i(en_pipeline),
		.mem_data_read_i(data_read_interface_o),
		.alu_result_i(alu_result_ex_mem_o),
		.write_register_i(writeReg_ex_mem),
        .wb_signals_i(wb_signals_ex_mem_stage_o),
		.pc_i(pc_ex_mem_stage_o),
		.write_register_o(writeReg_mem_wb_stage_o),
		.mem_data_read_o(mem_data_read_mem_wb_stage_o),
		.alu_result_o(alu_result_mem_wb_o),
		.pc_o(pc_mem_wb_stage_o),
        .reg_write_o(reg_write_wb_stage_o),
        .mem_to_reg_o(mem_to_reg_mem_wb_stage_o)
    );

    DATAmem DATAmem
    (
        .clock_i(clock),
        .enable_mem_i(en_pipeline), 
        .addr_i(alu_result_ex_mem_o[7-1:0]),
        .data_write_i(data_wr_to_mem_interface_o),
        .mem_read_i(mem_signals_ex_mem_o[4]),    //señales para escritura o lectura
        .mem_write_i(mem_signals_ex_mem_o[3]),   //
        .data_o(DATAmem_o)
    );

    interfaceDataMEM interfaceDataMEM
    (
		.data_write_i(data_wr_to_mem_ex_mem_stage_o),
		.data_read_i(DATAmem_o),
   		.mem_signals_i(mem_signals_ex_mem_o),
   		.data_write_o(data_wr_to_mem_interface_o),
   		.data_read_o(data_read_interface_o)
    );

    ex_mem_stage ex_mem_stage
    (
		.clock(clock),   
		.reset(reset),
		.en_pipeline(en_pipeline),
		.data_wr_to_mem_i(data_rb_o),
		.alu_result_i(alu_result_i),
		.writeReg_i(writeReg_dec_ex),
        .pc_i(pc_o_ex_stage),
        .mem_signals_i(mem_signals_dec_ex_stage_o), 
        .wb_signals_i(wb_signals_dec_ex_stage_o), 
		.data_wr_to_mem_o(data_wr_to_mem_ex_mem_stage_o),
        .alu_result_o(alu_result_ex_mem_o),
        .writeReg_o(writeReg_ex_mem),  
        .pc_o(pc_ex_mem_stage_o),
        .mem_signals_o(mem_signals_ex_mem_o),
        .wb_signals_o(wb_signals_ex_mem_stage_o)
    );

    alu alu
    (
        .i_a(data_ra_o), //input a 
        .i_b(o_B_to_alu), //input b 
        .i_op(funct_for_alu),	
        .o_o(alu_result_i)
    );

	interfaceALU interfaceALU
	(
		.funct(funct_o_ex_stage),
		.opcode(operation_dec_ex_stage_o),
		.funct_for_alu(funct_for_alu)
	);

	multiplexor_2_in multiplexor_2_in
	(
		.op1_i(data_rb_i),
		.op2_i(inmediate_i),
		.sel_i(tipeI_i),
		.data_o(o_B_to_alu)		
	);

    multiplexor_3_in#(.NB_DATA(NB_REG)) multiplexor_3_in
    (
		.op1_i(wire_B_dec_ex_stage_o),
		.op2_i(wire_RW_dec_ex_stage_o),
		.op3_i(5'd31),		
		.sel_i(regDest_signal_dec_ex_stage_o),          
		.data_o(writeReg_dec_ex)
    );

    decode_execute_stage decode_execute_stage
    (
		.clock(clock),   
		.reset(reset),
		.en_pipeline(en_pipeline),
		.pc_i(pc_o),
		.function_i(funct),
		.regDest_signal_i(regDest_signal),
		.opcode(operation_dec_ex_stage),
		.data_ra_i(data_ra_register),
		.data_rb_i(data_rb_register),
		.inm_ext_i(wire_inmediate_o),
		.tipeI(tipeI_dec_ex_stage),
        .register_a_i(wire_A), 
        .register_b_i(wire_B),
        .register_rw_i(wire_RW),
        .mem_signals_i(mem_signals),
        .wb_signals_i(wb_signals),
		//.input wire [NB_EX_CTRL-1:0] EX_control_i,
		.data_ra_o(data_ra_o),
		.data_rb_o(data_rb_o),
		.inm_ext_o(inmediate_o),
		.pc_o(pc_o_ex_stage),
		.function_o(funct_o_ex_stage),
		.regDest_signal_o(regDest_signal_dec_ex_stage_o),
		.opcode_o(operation_dec_ex_stage_o),
		.tipeI_o(tipeI_dec_ex_stage_o),
        .register_a_o(wire_A_dec_ex_stage_o), 
        .register_b_o(wire_B_dec_ex_stage_o),
        .register_rw_o(wire_RW_dec_ex_stage_o),
        .mem_signals_o(mem_signals_dec_ex_stage_o),
        .wb_signals_o(wb_signals_dec_ex_stage_o)
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
        .wb_signals(wb_signals),
        .branch(branch),
		.tipeI(tipeI_dec_ex_stage),
        .regDest_signal(regDest_signal),
		.opcode_o(operation_dec_ex_stage),
        .mem_signals(mem_signals)
	);

	bank_registers bank_registers
	(
		.clock_i(clock),
		.reset_i(reset),
		.rw_i(reg_write_wb_stage_o), 
		.addr_ra_i(wire_A),
		.addr_rb_i(wire_B),
		.addr_rw_i(writeReg_mem_wb_stage_o),
		.data_rw_i(data_write_to_reg),
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
		.pc_i(next_addr_plus_four_o),
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
		.next_addr_i(next_addr_plus_four_o),
		.next_addr_o(o_dir_mem_read),
        .next_addr_plus_four_o(next_addr_plus_four_o)
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
`timescale 1ns / 1ps


module test_pipeline;
    parameter           PERIOD  = 40; // debe dar 50 Mh
    parameter           N_CLOCK = 163;
//    parameter           CHANGE_RX = (N_CLOCK*3)/4; // 122
    parameter           N_DATA = 8;
    
    parameter           NB_DATA = 32;
    
    reg     clock;
    reg    reset;

    reg  [N_DATA - 1:0] din;
    wire read_tx;
    // reg en_read_i;

    reg  empty;

    // reg enable_i;
    wire finish_send;

    wire [NB_DATA-1:0] operation_o_paraver;

    wire [NB_DATA-1:0]inmediate_o_paraver;

    wire [NB_DATA-1:0]data_a_o_paraver;

    // wire [NB_DATA-1:0]dataInterfaceMEM_o_paraver;

    // wire [NB_DATA-1:0]dataWr_ex_mem_stage_o_paraver;

    // wire [6-1:0]mem_signals_o_paraver;

    wire [5-1:0]wire_A_paraver;

    // wire [2-1:0]mem_to_reg_signal_paraver;

    wire [12-1:0] state_paraver;
    wire wrote_paraver;

    wire [2:0] count_paraver;

    wire [NB_DATA-1:0]o_data_mem_paraver;

    wire [7-1:0]o_dir_wr_mem_paraver;

    wire [NB_DATA-1:0]instruction_paraver;

    wire debug_out;

    wire [8-1:0] data_to_send_paraver;
    wire en_send_registers_paraver;
    wire select_debug_or_wireA_paraver;
    wire [7-1:0] addr_mem_debug_paraver;
    wire tx_done_paraver;
    wire [2:0] count_send_bytes_paraver;
    // reg en_pipeline;
    wire en_pipeline_paraver;

    top_pipeline top_pipeline
    (
		.clock(clock),
		.reset(reset),
		.din(din),
		.read_tx(read_tx),
        .empty(empty),
        //.en_pipeline(en_pipeline),
		// .en_read_i(en_read_i),
        .finish_send(finish_send),
        .debug_out(debug_out),
        // .enable_i(enable_i),
        .operation_o_paraver(operation_o_paraver),
        .inmediate_o_paraver(inmediate_o_paraver),
        .data_a_o_paraver(data_a_o_paraver),
        // .dataInterfaceMEM_o_paraver(dataInterfaceMEM_o_paraver),
        // .dataWr_ex_mem_stage_o_paraver(dataWr_ex_mem_stage_o_paraver),
        // .mem_signals_o_paraver(mem_signals_o_paraver),
        .wire_A_paraver(wire_A_paraver),
        // .mem_to_reg_signal_paraver(mem_to_reg_signal_paraver),
        .state_paraver(state_paraver),
        .wrote_paraver(wrote_paraver),
        .count_paraver(count_paraver),
        .o_data_mem_paraver(o_data_mem_paraver),
        .o_dir_wr_mem_paraver(o_dir_wr_mem_paraver),
        .instruction_paraver(instruction_paraver),
        .data_to_send_paraver(data_to_send_paraver),
        .en_send_registers_paraver(en_send_registers_paraver),
        .select_debug_or_wireA_paraver(select_debug_or_wireA_paraver),
        .addr_mem_debug_paraver(addr_mem_debug_paraver),
        .tx_done_paraver(tx_done_paraver),
        .count_send_bytes_paraver(count_send_bytes_paraver),
        .en_pipeline_paraver(en_pipeline_paraver)
    );
        
    initial
        begin
//            D_Op_sw [0] = 8'b00100000;
//            D_Op_sw [1] = 8'b00100010;
//            D_Op_sw [2] = 8'b00100100;
//            D_Op_sw [3] = 8'b00100101;
//            D_Op_sw [4] = 8'b00100110;
//            D_Op_sw [5] = 8'b00000011;
//            D_Op_sw [6] = 8'b00000010;
//            D_Op_sw [7] = 8'b00100111;
            empty       = 1;
            clock       = 0; 
            reset       = 1;
            din = 8'b00000000;
            #PERIOD reset = 0;
            #(PERIOD*4) empty = 1;
            #(PERIOD*4) empty = 0;
            wait( finish_send == 1'b1);
            din = 8'b00000000;
            #(PERIOD*4) empty = 1;
            #(PERIOD*4) empty = 0;
            wait( finish_send == 1'b1);
            din = 8'b00100011;   //load en el registro 3
            #(PERIOD*4) empty = 1;
            #(PERIOD*4) empty = 0;
            wait( finish_send == 1'b1);
            din = 8'b10000000; //lb   (registro1+0)
            #(PERIOD*4) empty = 1;
            #(PERIOD*4) empty = 0;
            wait( finish_send == 1'b1);


            din = 8'b00100001;
            // #PERIOD reset = 0;
            #(PERIOD*4) empty = 1;
            #(PERIOD*4) empty = 0;
            wait( finish_send == 1'b1);
            din = 8'b00011000;
            #(PERIOD*4) empty = 1;
            #(PERIOD*4) empty = 0;
            wait( finish_send == 1'b1);
            din = 8'b11100010;   //
            #(PERIOD*4) empty = 1;
            #(PERIOD*4) empty = 0;
            wait( finish_send == 1'b1);
            din = 8'b00000000; //add r2+r7=r4
            #(PERIOD*4) empty = 1;
            #(PERIOD*4) empty = 0;
            wait( finish_send == 1'b1);


            din = 8'b00100001;
            // #PERIOD reset = 0;
            #(PERIOD*4) empty = 1;
            #(PERIOD*4) empty = 0;
            wait( finish_send == 1'b1);
            din = 8'b00101000;
            #(PERIOD*4) empty = 1;
            #(PERIOD*4) empty = 0;
            wait( finish_send == 1'b1);
            din = 8'b00000110;   //
            #(PERIOD*4) empty = 1;
            #(PERIOD*4) empty = 0;
            wait( finish_send == 1'b1);
            din = 8'b00000001; //add r8+r6=r5
            #(PERIOD*4) empty = 1;
            #(PERIOD*4) empty = 0;
            wait( finish_send == 1'b1);

/* 
            din = 8'b00000000;
            #(PERIOD*4) empty = 0;
            #(PERIOD*4) empty = 1;
            wait( finish_send == 1'b1);
            din = 8'b00000000;
            #(PERIOD*4) empty = 0;
            #(PERIOD*4) empty = 1;
            wait( finish_send == 1'b1);
            din = 8'b00100100;   //load en el registro 4
            #(PERIOD*4) empty = 0;
            #(PERIOD*4) empty = 1;
            wait( finish_send == 1'b1);
            din = 8'b10000000;
            #(PERIOD*4) empty = 0;
            #(PERIOD*4) empty = 1;
            wait( finish_send == 1'b1);

            din = 8'b00000000;
            #(PERIOD*4) empty = 0;
            #(PERIOD*4) empty = 1;
            wait( finish_send == 1'b1);
            din = 8'b00000000;
            #(PERIOD*4) empty = 0;
            #(PERIOD*4) empty = 1;
            wait( finish_send == 1'b1);
            din = 8'b00100101;   //load en el registro 5
            #(PERIOD*4) empty = 0;
            #(PERIOD*4) empty = 1;
            wait( finish_send == 1'b1);
            din = 8'b10000000;
            #(PERIOD*4) empty = 0;
            #(PERIOD*4) empty = 1;
            wait( finish_send == 1'b1);

            din = 8'b00000000;
            #(PERIOD*4) empty = 0;
            #(PERIOD*4) empty = 1;
            wait( finish_send == 1'b1);
            din = 8'b00000000;
            #(PERIOD*4) empty = 0;
            #(PERIOD*4) empty = 1;
            wait( finish_send == 1'b1);
            din = 8'b00100101;   //add en el registro 6
            #(PERIOD*4) empty = 0;
            #(PERIOD*4) empty = 1;
            wait( finish_send == 1'b1);
            din = 8'b10000000;
            #(PERIOD*4) empty = 0;
            #(PERIOD*4) empty = 1;
            wait( finish_send == 1'b1); */

            din = 8'b11111111;
            #(PERIOD*4) empty = 1;
            #(PERIOD*4) empty = 0;
            wait( finish_send == 1'b1);
            din = 8'b11111111;
            #(PERIOD*4) empty = 1;
            #(PERIOD*4) empty = 0;
            wait( finish_send == 1'b1);
            din = 8'b11111111;
            #(PERIOD*4) empty = 1;
            #(PERIOD*4) empty = 0;
            wait( finish_send == 1'b1);
            din = 8'b11111111;
            #(PERIOD*4) empty = 1;
            #(PERIOD*4) empty = 0;
            wait( finish_send == 1'b1);

            din = 8'b00000001; // selecciono modo
            #(PERIOD*4) empty = 1;
            #(PERIOD*4) empty = 0;
            wait( state_paraver == 12'b000000001000);


            din = 8'b00000001; // selecciono modo
            #(PERIOD*4) empty = 1;
            #(PERIOD*4) empty = 0;
            wait( finish_send == 1'b1);

            // #(PERIOD*5)
            // en_read_i = 1'b1;
            

        end
    
    always begin
        #(PERIOD/2) clock = ~clock;
        #(PERIOD/2);
    end
       
    /* 
    always @(posedge clock) begin
        if (en_pipeline == 1'b1) begin
            en_pipeline <= 1'b0;
            en_read_i <= 1'b0;
        end
        else if(en_read_i == 1'b1)begin
            en_pipeline <= 1'b1;
        end
    end
 */

/*     always @(posedge tick) begin
        if(count_data == 2'b00 && start)begin
            o_tx    <= 8'b01010101;
            empty   <= 0;
            #(PERIOD*3);
            empty   <= 1'b1;
            count_data <= count_data + 1;
        end  
    end
    
    always @(posedge tx_done_tick) begin
        #(PERIOD*4);
        if (count_data <= 2'b10) begin
            o_tx    <= 8'b00100000;
            empty   <= 0;
            #(PERIOD*3);
            empty   <= 1'b1;
            count_data <= count_data + 1; 
        end 
    end */
    
endmodule 



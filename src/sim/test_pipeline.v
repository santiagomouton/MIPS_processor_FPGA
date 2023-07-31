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
    reg en_read_i;

    reg  empty;

    reg enable_i;
    wire finish_send;

    wire [NB_DATA-1:0] operation_o_paraver;

    wire [NB_DATA-1:0]inmediate_o_paraver;

    wire [NB_DATA-1:0]data_a_o_paraver;

    wire [NB_DATA-1:0]dataInterfaceMEM_o_paraver;

    wire [NB_DATA-1:0]dataWr_ex_mem_stage_o_paraver;

    wire [6-1:0]mem_signals_o_paraver;

    wire [5-1:0]wire_A_paraver;

    wire [2-1:0]mem_to_reg_signal_paraver;

    pipeline pipeline
    (
		.clock(clock),
		.reset(reset),
		.din(din),
		.read_tx(read_tx),
        .empty(empty),
		.en_read_i(en_read_i),
        .finish_send(finish_send),
        .enable_i(enable_i),
        .operation_o_paraver(operation_o_paraver),
        .inmediate_o_paraver(inmediate_o_paraver),
        .data_a_o_paraver(data_a_o_paraver),
        .dataInterfaceMEM_o_paraver(dataInterfaceMEM_o_paraver),
        .dataWr_ex_mem_stage_o_paraver(dataWr_ex_mem_stage_o_paraver),
        .mem_signals_o_paraver(mem_signals_o_paraver),
        .wire_A_paraver(wire_A_paraver),
        .mem_to_reg_signal_paraver(mem_to_reg_signal_paraver)
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
            #PERIOD empty = 0;
            #PERIOD empty = 1;
            wait( finish_send == 1'b1);
            din = 8'b00000000;
            #(PERIOD*2) empty = 0;
            #(PERIOD*2) empty = 1;
            wait( finish_send == 1'b1);
            din = 8'b00100011;   //load en el registro 3
            #(PERIOD*2) empty = 0;
            #(PERIOD*2) empty = 1;
            wait( finish_send == 1'b1);
            din = 8'b10000000; //lb   (registro1+0)
            #(PERIOD*2) empty = 0;
            #(PERIOD*2) empty = 1;
            wait( finish_send == 1'b1);
/* 
            din = 8'b00000000;
            #(PERIOD*2) empty = 0;
            #(PERIOD*2) empty = 1;
            wait( finish_send == 1'b1);
            din = 8'b00000000;
            #(PERIOD*2) empty = 0;
            #(PERIOD*2) empty = 1;
            wait( finish_send == 1'b1);
            din = 8'b00100100;   //load en el registro 4
            #(PERIOD*2) empty = 0;
            #(PERIOD*2) empty = 1;
            wait( finish_send == 1'b1);
            din = 8'b10000000;
            #(PERIOD*2) empty = 0;
            #(PERIOD*2) empty = 1;
            wait( finish_send == 1'b1);

            din = 8'b00000000;
            #(PERIOD*2) empty = 0;
            #(PERIOD*2) empty = 1;
            wait( finish_send == 1'b1);
            din = 8'b00000000;
            #(PERIOD*2) empty = 0;
            #(PERIOD*2) empty = 1;
            wait( finish_send == 1'b1);
            din = 8'b00100101;   //load en el registro 5
            #(PERIOD*2) empty = 0;
            #(PERIOD*2) empty = 1;
            wait( finish_send == 1'b1);
            din = 8'b10000000;
            #(PERIOD*2) empty = 0;
            #(PERIOD*2) empty = 1;
            wait( finish_send == 1'b1);

            din = 8'b00000000;
            #(PERIOD*2) empty = 0;
            #(PERIOD*2) empty = 1;
            wait( finish_send == 1'b1);
            din = 8'b00000000;
            #(PERIOD*2) empty = 0;
            #(PERIOD*2) empty = 1;
            wait( finish_send == 1'b1);
            din = 8'b00100101;   //add en el registro 6
            #(PERIOD*2) empty = 0;
            #(PERIOD*2) empty = 1;
            wait( finish_send == 1'b1);
            din = 8'b10000000;
            #(PERIOD*2) empty = 0;
            #(PERIOD*2) empty = 1;
            wait( finish_send == 1'b1); */

            din = 8'b11111111;
            #(PERIOD*2) empty = 0;
            #(PERIOD*2) empty = 1;
            wait( finish_send == 1'b1);
            din = 8'b11111111;
            #(PERIOD*2) empty = 0;
            #(PERIOD*2) empty = 1;
            wait( finish_send == 1'b1);
            din = 8'b11111111;
            #(PERIOD*2) empty = 0;
            #(PERIOD*2) empty = 1;
            wait( finish_send == 1'b1);
            din = 8'b11111111;
            #(PERIOD*2) empty = 0;
            #(PERIOD*2) empty = 1;
            wait( finish_send == 1'b1);

            #(PERIOD*5)
            enable_i = 1'b1;
            en_read_i = 1'b1;

        end
    
    always begin
        #(PERIOD/2) clock = ~clock;
        #(PERIOD/2);
    end
       
    


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
        #(PERIOD*2);
        if (count_data <= 2'b10) begin
            o_tx    <= 8'b00100000;
            empty   <= 0;
            #(PERIOD*3);
            empty   <= 1'b1;
            count_data <= count_data + 1; 
        end 
    end */
    
endmodule 



`timescale 1ns / 1ps


module test_decode_ex;
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
    wire [NB_DATA-1:0] instruction_o;

    reg  empty;

    reg enable;
    //reg  [NB_DATA - 1:0] o_tx; //nose para que es
    //wire  tx_done_tick;
    wire finish_send;
    wire finish_recieve;

    wire [N_DATA - 1:0]salida_de_rx;
    wire conexion_tx_rx;
    wire [5 - 1:0]rx_state_o;

    wire [NB_DATA-1:0]intMem_data_o;
    wire intMem_ready;

    wire [NB_DATA-1:0]data_o_fetch;

    wire [7-1:0] pc_o;

    reg [7-1:0]next_addr_i;

    wire [NB_DATA-1:0] operation_o;

    wire [NB_DATA-1:0]inmediate_o_paraver;

    wire tipeI_paraver;

    top_from_mem_to_execute mytop
    (
		.clock(clock),
		.reset(reset),
		.din(din),
		.read_tx(read_tx),
        .empty(empty),
        .pc_o(pc_o),
		.en_read_i(en_read_i),
		.instruction_o(instruction_o),
        .finish_send(finish_send),
        .finish_recieve(finish_recieve),
        .salida_de_rx(salida_de_rx),
        .rx_state_o(rx_state_o),
        .conexion_tx_rx(conexion_tx_rx),
        .intMem_ready(intMem_ready),
        .intMem_data_o(intMem_data_o),
        .data_o_fetch(data_o_fetch),
        .enable(enable),
        .next_addr_i(next_addr_i),
        .operation_o(operation_o),
        .inmediate_o_paraver(inmediate_o_paraver),
		.tipeI_paraver(tipeI_paraver)
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
            din = 8'b00000001;
            #PERIOD reset = 0;
            #PERIOD empty = 0;
            #PERIOD empty = 1;
            wait( finish_send == 1'b1);
            din = 8'b00000000;
            #(PERIOD*2) empty = 0;
            #(PERIOD*2) empty = 1;
            wait( finish_send == 1'b1);
            din = 8'b00000001;
            #(PERIOD*2) empty = 0;
            #(PERIOD*2) empty = 1;
            wait( finish_send == 1'b1);
            din = 8'b00100000; //addi
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
            din = 8'b11111111;
            #(PERIOD*2) empty = 0;
            #(PERIOD*2) empty = 1;
            wait( finish_send == 1'b1);


            #(PERIOD*5)
            enable = 1'b1;
            next_addr_i = 7'b0000000;
            en_read_i = 1'b1;
            #(PERIOD*2)
            $display("data [%b][%h]", instruction_o, instruction_o);

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



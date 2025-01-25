`timescale 1ns / 1ps

module testTop_pipeline_board;
    reg clk;
    reg reset;
    wire tx_done_tick;
    reg tx_start;
    reg [7:0]din;
    localparam CLK_PERIOD = 40;       // 10 --> 100mhz



    // top
    wire state_Iddle;
    wire state_Receive_Instruction;
    wire state_Tx_data_to_computer;
    wire state_Continue;
    // rx
    // wire rx_done_tick;
    wire [7:0] dout;

/* wire tick;
BaudRateGenerator BaudRateGenerator_sim
(
    .tick(tick),
    .clock(clk),
    .reset(reset)
); */

    always #(CLK_PERIOD/2) clk =~clk;

    initial begin
        #0          
        clk  = 0;
        reset = 1;
        #(CLK_PERIOD*4);
        reset<=0;
        #(CLK_PERIOD*2);
        
        din <= 8'h01;
        tx_start <= 1'b1;
        #(CLK_PERIOD*4);
        tx_start <= 1'b0;
        wait( state_tx_paraver == 4'b0001);
        #(CLK_PERIOD*2)

        din <= 8'h00;
        tx_start <= 1'b1;
        #(CLK_PERIOD*4);
        tx_start <= 1'b0;
        wait( state_tx_paraver == 4'b0001);
        #(CLK_PERIOD)

        din <= 8'h00;
        tx_start <= 1'b1;
        #(CLK_PERIOD*4);
        tx_start <= 1'b0;
        wait( state_tx_paraver == 4'b0001);
        #(CLK_PERIOD)

        din <= 8'h00;
        tx_start <= 1'b1;
        #(CLK_PERIOD*4);
        tx_start <= 1'b0;
        wait( state_tx_paraver == 4'b0001);
        #(CLK_PERIOD)

        din <= 8'hfc;
        tx_start <= 1'b1;
        #(CLK_PERIOD*4);
        tx_start <= 1'b0;
        wait( state_tx_paraver == 4'b0001);
        #(CLK_PERIOD*2)

        din <= 8'h04;
        tx_start <= 1'b1;
        #(CLK_PERIOD*4);
        tx_start <= 1'b0;
        wait( state_tx_paraver == 4'b0001);
        #(CLK_PERIOD)
        


        $finish(2);
    end

    wire receiving_paraver;
    wire tick_out;
    wire [3:0] state_tx_paraver;
    wire read_rx_paraver;
    top_de_prueba top_de_prueba
    (
        .clk(clk),
        .reset(reset),

        .din(din),
        .tx_start(tx_start),
        .tx_done_tick(tx_done_tick),


        // top
        .state_Iddle(state_Iddle),
        .state_Receive_Instruction(state_Receive_Instruction),
        .state_Tx_data_to_computer(state_Tx_data_to_computer),
        .state_Continue(state_Continue),
        
        // rx
        // .rx_done_tick(rx_done_tick),
        .dout(dout),
        .receiving_paraver(receiving_paraver),
        .tick_out(tick_out),

        .state_tx_paraver(state_tx_paraver),
        .read_rx_paraver(read_rx_paraver)
    );


endmodule
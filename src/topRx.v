`timescale 1ns / 1ps

module topRx

#(
    parameter   NB_DATA = 8
)
(
    input                   rx,
    input                   clock,
    input                   reset,
    input                   s_tick,
    output                  rx_done_tick,
    output [NB_DATA-1:0]    dout
    );

    rx_uart rx_uart_top(
        .reset(reset),                  
        .clock(clock),
        .rx(rx),
        .dout(dout),
        .s_tick(s_tick),
        .rx_done_tick(rx_done_tick)
    );
endmodule

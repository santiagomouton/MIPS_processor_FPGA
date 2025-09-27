`timescale 1ns / 1ps

module topTx
#(
    parameter   NB_DATA = 8
)
(
    input [NB_DATA-1:0] din,
    input               s_tick,
    input               tx_start,
    input               clock,
    input               reset,
    
    output              read_tx,
    output              tx_done_tick,
    output              tx  
);
    
    tx_uart tx_uart_top(
        .reset(reset),                  .clock(clock),
        .din(din),                      .s_tick(s_tick), 
        .tx_start(tx_start),            .read_tx(read_tx),
        .tx_done_tick(tx_done_tick),    .tx(tx)
    );
    
endmodule

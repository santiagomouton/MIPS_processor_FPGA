`timescale 1ns / 1ps

module topBrgTx
#(
    parameter   NB_DATA = 8
)
(
    input [NB_DATA-1:0] din,
    input               tx_start,
    input               clock,
    input               reset,
    
    output              read_tx,
    output              tx_done_tick,
    output              tx  
);
    wire               s_tick;
    
    BaudRateGenerator BRG_Tx_top (
        .clock(clock),  .reset(reset),
        .tick(s_tick)
    );
    tx_uart tx_uart_brg(
        .reset(reset),                  .clock(clock),
        .din(din),                      .s_tick(s_tick), 
        .tx_start(tx_start),            .read_tx(read_tx),
        .tx_done_tick(tx_done_tick),    .tx(tx)
    );
    
endmodule
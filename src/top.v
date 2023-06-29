`timescale 1ns / 1ps

module top
#(
    parameter   NB_STATE        = 5,    // estados de la FSM
    parameter   NB_DATA          = 8,    // cantidad de datos a recibir
    parameter   START_VALUE     = 0,    // Bit de start
    parameter   STOP_VALUE      = 1,     // Bit de stop
    parameter   DATA_TICKS      = 15    // cantidad de bit para colcarse al centro del bit de dato // agrege
)
(
//output wire [ 5 : 0 ] salida_operacion,
//output wire [ NB_DATA - 1 : 0 ] salida_A,
//output wire [ NB_DATA - 1 : 0 ] salida_B,
//output wire [ 4 : 0 ] VER_ESTADOS,
    output  wire    tx,
    input   wire    rx,
//    input   wire            wr,  
//    input   wire    [7:0]   din, 
//    output  wire    [NB_DATA - 1:0] o_alu, 
//    input   wire    rx_done_tick,             
    input   wire    clock,
    input   wire    reset
    
//    output  wire [7:0] CHECK_ENTRADA_TX
//    output wire    [NB_DATA - 1:0] o_tx
);
    wire                    empty;
    wire                    tick;
    wire    [NB_DATA - 1:0] dout;
    wire    [NB_DATA - 1:0] o_tx;
    wire                    read_tx;
    wire                    tx_done_tick; 
    wire                    rx_done_tick; 
    
    wire    [NB_DATA -1 : 0] 
             o_data_A, 
             o_data_B; 
    wire    [NB_DATA - 3 : 0]  o_data_Op;
    wire    [NB_DATA - 1:0] o_alu;
             
    // ______________________ BRG ____________ //
    BaudRateGenerator myBRG (
        .tick   (tick),
        .clock  (clock),
        .reset  (reset)
    );
    // ____________________ Rx   ____________________ //
    rx_uart myrx_uart(
        .s_tick(tick), 
        .rx(rx),
        .rx_done_tick(rx_done_tick), 
        .dout(dout),
        .clock(clock),
        .reset(reset)
    );
    // ______________________ interface  ____________ //
    interface_uart myinterface_uart (
        .in_rx      (dout), 
        .wr         (rx_done_tick), 
        .clock      (clock), 
        .in_alu     (o_alu),
        .o_data_A   (o_data_A), 
        .o_data_B   (o_data_B), 
        .o_data_Op  (o_data_Op),
        .o_tx       (o_tx),
        .empty      (empty),
        .rd         (tx_done_tick),
        .read_tx    (read_tx),
        .reset      (reset)//, .VER_ESTADOS(VER_ESTADOS)
    );
    // ______________________ alu   ____________ //
    alu myAlu (.i_a(o_data_A), .i_b(o_data_B), .i_op(o_data_Op[5:0]), .o_o(o_alu));//, .salida_operacion(salida_operacion), .salida_A(salida_A), .salida_B(salida_B));
    
    // ______________________ Tx ____________ //
    tx_uart mytx_uart(
        .s_tick(tick), 
        .tx(tx),
        .tx_done_tick(tx_done_tick), 
        .tx_start(empty),
        .read_tx(read_tx),
        .din(o_tx),
        .clock(clock),
        .reset(reset)
//        .CHECK_ENTRADA_TX(CHECK_ENTRADA_TX)
    );
    
endmodule

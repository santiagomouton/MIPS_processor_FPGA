`timescale 1ns / 1ps

module topBRG
(
    output  wire    tick,              
    input   wire    clock,
    input   wire    reset
);
    // ______________________ BRG ____________ //
    BaudRateGenerator myBRG (
        .tick(tick),
        .clock (clock),
        .reset(reset)
    );
    
endmodule


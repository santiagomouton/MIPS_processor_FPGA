// Code your design here
`timescale 1ns / 1ps

module BaudRateGenerator
#(
    parameter   CLOCK_FREQ       = 50000000,                        //50Mhz
    parameter   BAUD_RATE        = 19200,                           //19,2Khz
    parameter   DIVISION         = 16,
    parameter   N_CLOCKS         = CLOCK_FREQ/(BAUD_RATE*DIVISION)  // 163 tick
)
(
    // OUTPUTS
    output reg tick,
    // INPUTS
    input wire clock,
    input wire reset
);    
    // counter ticks
    reg [7: 0]  counTicks;
    
    /**
    * Lista de Sensibilidades : 
        clock - posedge
    * Accion :
        Icrementamos en uno cuando aun no se llega 
        al valor de N_CLOCKS.
        Cuando se cumple la igualdad, seteamos en uno 
        a tick
    **/
    always @(posedge clock) begin
        if (reset) begin
            tick        <= 1'b0;
            counTicks   <= 1'b0;
        end
        else begin
            counTicks  <= counTicks + 1'b1;
            if (counTicks == N_CLOCKS) begin
                tick        <= 1'b1;
                counTicks   <= 1'b0;
            end
            else begin
                tick <= 1'b0;
            end
        end
    end

endmodule



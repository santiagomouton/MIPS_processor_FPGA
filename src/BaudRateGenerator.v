// Code your design here
`timescale 1ns / 1ps

module BaudRateGenerator
#(
    parameter   CLOCK_FREQ       = 25000000,                        //25Mhz
    // parameter   BAUD_RATE        = 19200,                           //19,2Khz
    parameter   BAUD_RATE        = 9600,                           //9,6Khz
    parameter   DIVISION         = 16,
    parameter   N_CLOCKS         = CLOCK_FREQ/(BAUD_RATE*DIVISION)  // clock/tick 163
)
(
    // OUTPUTS
    output wire tick,
    // INPUTS
    input wire clock,
    input wire reset
);    
    // counter ticks
    reg [8: 0]  counTicks;
    
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
            counTicks   <= 8'b0;
        end
        else begin
            if (counTicks == (N_CLOCKS-1))
                counTicks   <= 8'b0;
            else
                counTicks  <= counTicks + 1;
        end
    end

    assign tick = (counTicks == (N_CLOCKS-1))? 1'b1: 1'b0;

endmodule



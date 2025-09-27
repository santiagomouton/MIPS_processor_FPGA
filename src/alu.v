`timescale 1ns / 1ps

module alu
#
(
    parameter N_BITS = 32
)
(
    input  wire [ N_BITS - 1 : 0 ] i_a, //input a 
    input  wire [ N_BITS - 1 : 0 ] i_b, //input b 
    input  wire [ 5 : 0 ] i_op, //input operation
    output reg  [ N_BITS - 1 : 0 ] o_o//output operation
);
    
    always @(*) begin //CIRCUITO CONBINACIONAL
        o_o = 32'bxxxxxxxx_xxxxxxxx_xxxxxxxx_xxxxxxxx; //valor por DEFAULT
        case (i_op)
            /* ADD */
            6'b100000: begin
                o_o = i_a + i_b;
            end
            /* SUB */
            6'b100010: begin
                o_o = i_a - i_b;
            end
            /* AND */
            6'b100100: begin
                o_o = i_a & i_b;
            end
            /* OR */
            6'b100101: begin
                o_o = i_a | i_b;
            end

            /* XOR */
            6'b100110: begin
                o_o = i_a ^ i_b;
            end
            /* SRA */
            6'b000011: begin
                o_o = i_a >>> i_b;
            end
            /* SRL */
            6'b000010: begin
                o_o = i_a >> i_b;
            end
            /* SLLV */
            6'b000100: begin
                o_o = i_a << i_b;
            end
            /* NOR */
            6'b100111: begin
                o_o = ~(i_a | i_b);
            end
            /* SLT */
            6'b101010: begin
                o_o = i_a < i_b;
            end
            /* LUI */
            6'b001111: begin
                o_o = i_b << 16;
            end

            default : o_o = 32'b0;
        endcase
    end

endmodule
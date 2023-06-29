`timescale 1ns / 1ps

module UT_Interface;
    parameter           NB_DATA = 8;
    parameter           PERIOD  = 20; // debe dar 50 Mh
    parameter           [NB_DATA-1 : 0] da  = 8'b00000011;
    parameter           [NB_DATA-1 : 0] db  = 8'b00000010;
    parameter           [NB_DATA-1 : 0] dop = 8'b00100000;
    parameter           [NB_DATA-1 : 0] dop1 = 8'b00100100;
    
    reg                  [NB_DATA-1 : 0] DATO;
    wire                 [NB_DATA-1 : 0] o_data_A ;
    wire                 [NB_DATA-1 : 0] o_data_B ;
    wire                 [NB_DATA-1 : 0] o_data_Op;
    reg                                 wr;
    reg                                 clock;
    reg                                 reset;
    
    reg                  [4:0]          count;
    reg                                 flags;
    
    topInterface mytopInterface (
        .din(DATO),         .wr(wr),
        .o_a(o_data_A),     .o_b(o_data_B),
        .o_op(o_data_Op),   
        .clock (clock),     .reset(reset)
    );
    
    initial
        begin
            clock   = 0;
            wr      = 0;
            count   = 0;
            DATO    = 0;
            flags   = 0;
            reset   = 1;
            #PERIOD reset = 0;
        end
        
    always begin
        #(PERIOD/2) clock = ~clock;
        #(PERIOD/2);
    end
    
    always @(posedge clock)
    begin
        case (count)
            3'b000:
            begin
                count   <= count +1;
            end
            3'b001:
            begin
                count   <= count +1;
            end
            3'b010:
            begin
                DATO    <= da;
                wr      <= 1;
                count   <= count +1;
            end
            3'b011:
            begin
                wr      <= 0;
                count   <= count +1;
            end
            3'b100:
            begin
                DATO    <= db;
                wr      <= 1;
                count   <= count +1;
            end
            3'b101:
            begin
                wr      <= 0;
                count   <= count +1;
            end
            3'b110:
            begin
                if (flags) begin
                    DATO    <= dop;
                    flags   <= 0;
                end
                else begin
                    DATO    <= dop1;
                    flags   <= 1;
                end
                wr      <= 1;
                count   <= count +1;
            end
            3'b111:
            begin
                wr      <= 0;
                count   <= 0;
            end
            default: count <= count +1;
        endcase
    
    end
endmodule

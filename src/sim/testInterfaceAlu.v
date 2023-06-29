`timescale 1ns / 1ps


module testInterfaceAlu;
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
    wire                 [NB_DATA-1 : 0] o_alu;
    wire                 [NB_DATA-1 : 0] o_tx;
    wire                                 empty;
    reg                                 wr;
    reg                                 CLOCK;
    reg                  [4:0]          count;
    reg                                 flags;
    
    interface_uart myinterface_uart (.in_rx(DATO), .wr(wr), .CLOCK(CLOCK),
                            .o_data_A(o_data_A), .o_data_B(o_data_B),
                            .o_data_Op(o_data_Op) , .in_alu(o_alu), 
                            .o_tx(o_tx), .empty(empty));
                            
    alu myAlu (.i_a(o_data_A), .i_b(o_data_B), .i_op(o_data_Op[5:0]), .o_o(o_alu));
    initial
        begin
            CLOCK   = 0;
            wr      = 0;
            count   = 0;
            DATO    = 8'b00000011;
            flags   = 0;
        end
        
    always begin
        #(PERIOD/2) CLOCK = ~CLOCK;
        #(PERIOD/2);
    end
    
    always @(posedge CLOCK)
    begin
        case (count)
            2'b00:
            begin
                DATO    <= da;
                wr      <= 1;
                count   <= count +1;
            end
            2'b01:
            begin
                wr      <= 0;
                DATO    <= db;
                wr      <= 1;
                count   <= count +1;
            end
            2'b10:
            begin
                wr      <= 0;
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
            2'b11:
            begin
                wr      <= 0;
                count   <= 0;
            end
            default: count <= count +1;
        endcase
    
    end
    
    
endmodule



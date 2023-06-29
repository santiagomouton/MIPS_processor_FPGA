`timescale 1ns / 1ps

module IT_InterAluTx;
    parameter           NB_DATA = 8;
    parameter           PERIOD  = 20; // debe dar 50 Mh
    parameter           TOTAL_TICKS  = 15 * 11; 
    parameter           BR      = 163; 
    parameter           [NB_DATA-1 : 0] da  = 8'b00000011;
    parameter           [NB_DATA-1 : 0] db  = 8'b00000010;
    parameter           [NB_DATA-1 : 0] dop = 8'b00100000;
    parameter           [NB_DATA-1 : 0] dop1 = 8'b00100100;
    
    reg                                 flags;
    reg                                 wr_flag;
    //____________________TOP_____________________________________// 
    reg                  [NB_DATA-1 : 0] DATO;
    wire                 [NB_DATA-1 : 0] o_alu;
    wire                                 tx;
    reg                                  wr;
    reg                                  clock;
    reg                  [7:0]           count_tick;
    reg                  [7:0]           count_clk;
    reg                  [5:0]           count;
    reg                                  reset;
//    wire [NB_DATA - 1:0] o_tx;
wire [7:0] CHECK_ENTRADA_TX;
    
    wire [ 5 : 0 ] salida_operacion;
    wire [ 7 : 0 ] salida_A;
    wire [ 7 : 0 ] salida_B;
    wire [ 4 : 0 ] VER_ESTADOS;
    top topInterfaceAluTx (
        .din(DATO),     .wr(wr),
        .clock(clock),  .reset(reset),
        .tx(tx), .o_alu(o_alu), .salida_operacion(salida_operacion), .VER_ESTADOS(VER_ESTADOS), .salida_A(salida_A), .salida_B(salida_B)
        ,.CHECK_ENTRADA_TX(CHECK_ENTRADA_TX)
    );
    //____________________________________________________________// 
    
    initial
        begin
            clock   = 0;
            wr      = 0;
            count   = 0;
            count_tick = 0;
            count_clk = 0;
            DATO    = 0;
            flags   = 0;
            reset   = 1;
            wr_flag = 0;
            #PERIOD  reset   = 0;
        end
        
    always begin
        #(PERIOD/2) clock = ~clock;
        #(PERIOD/2);
    end
    
    always @(posedge clock)
    begin
        wr <= 0;
        if(wr_flag) begin
            wr      <= 1'b1;
            wr_flag <= 1'b0;
        end
        case (count_clk) 
            BR: begin
                case (count_tick)
                    TOTAL_TICKS: begin
                        case (count)
                            5'b00000: begin
                                DATO    <= da;
                                wr_flag <= 1'b1;
                                count   <= count +1;   
                            end
                            5'b00001: begin
                                DATO    <= db;
                                wr_flag <= 1'b1;
                                count   <= count +1;   
                            end 
                            5'b00010: begin
                                DATO    <= dop;
                                wr_flag <= 1'b1;
                                count   <= count + 1;   
                            end      
//                            default: count <= count +1;
                        endcase
                        count_tick <= 0;
                    end
                    default: count_tick = count_tick + 1;
                endcase
            count_clk <= 0;
            end
            default: count_clk = count_clk + 1;
        endcase
    end
    
    
endmodule

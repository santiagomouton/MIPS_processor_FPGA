`timescale 1ns / 1ps


module UT_Tx;
    parameter           PERIOD  = 20; // debe dar 50 Mh
    parameter           NB_DATA  = 8; // debe dar 50 Mh

    reg                  [4:0]          count;
    reg                                 flags;
    //______________ TOP _________________________//
    reg [NB_DATA-1:0] din;
    reg               tx_start;
    reg               clock;
    reg               reset;
    
    wire              s_tick;
    wire              read_tx;
    wire              tx_done_tick;
    wire              tx; 
    
    BaudRateGenerator BRG_Tx (
        .clock(clock),  .reset(reset),
        .tick(s_tick)
    );
    
    topTx  topTx (
        .reset(reset),                  .clock(clock),
        .din(din),                      .s_tick(s_tick), 
        .tx_start(tx_start),            .read_tx(read_tx),
        .tx_done_tick(tx_done_tick),    .tx(tx)
    );
    //___________________________________________//
    
    initial
    begin
        din         = 8'b10101011;
        clock       = 0;
        tx_start    = 1;
        flags       = 0;
        count       = 0;
        reset       = 1;
        #PERIOD     reset = 0;
    end
    
    always begin
        #(PERIOD/2) clock = ~clock;
        #(PERIOD/2);
    end
    
    always @(posedge clock) begin
        case (count)
            4'b0000: begin
                count = count + 1;     
            end
            4'b0001: begin
                count = count + 1;     
            end
            4'b0010: begin
                din         = 8'b10101011;
                tx_start    = 0;
                
                case (tx_done_tick) 
                    1'b0: begin
                        count = count;
                    end 
                    1'b1: begin
                        count = count + 1;   
                    end  
                endcase  
            end
            4'b0011: begin   
            end
        
        endcase
    end
    
endmodule

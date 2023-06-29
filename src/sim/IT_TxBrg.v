`timescale 1ns / 1ps


module IT_TxBrg;

    parameter           PERIOD  = 20; // debe dar 50 Mh
    parameter           NB_DATA  = 8; // debe dar 50 Mh

    reg                  [4:0]          count;
    reg                                 flags;
    //______________ TOP _________________________//
    reg [NB_DATA-1:0] din;
    reg               tx_start;
    reg               clock;
    reg               reset;
    
    wire              read_tx;
    wire              tx_done_tick;
    wire              tx; 
        
    topBrgTx   topTxBrg (
        .reset(reset),          .clock(clock),
        .din(din),              .tx_done_tick(tx_done_tick),    
        .tx_start(tx_start),    .read_tx(read_tx),
        .tx(tx)
    );
    //___________________________________________//
    
    initial
    begin
        din         = 0;
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
    
//        always @(posedge clock) begin
//        count_clocks = count_clocks + 1;
//        if(count_clocks == N_CLOCKS) begin
//            count_ticks = count_ticks + 1;
//            if(count_ticks == N_TICKS) begin
//                count_clocks = 0;
//                count_ticks = 0;
//            end
//        end
//    end
    
endmodule

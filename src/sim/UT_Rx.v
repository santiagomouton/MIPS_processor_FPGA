`timescale 1ns / 1ps


module UT_Rx;
    parameter           PERIOD  = 20; // debe dar 50 Mh
    parameter           NB_DATA  = 8; // debe dar 50 Mh
    parameter           CH_DATA  = 15; // debe dar 50 Mh
    parameter   [NB_DATA-1:0]  data_rx          = 8'b00001010;
    parameter   [NB_DATA-1:0]  data_rx_b        = 8'b00000001;
    parameter   [NB_DATA-1:0]  data_rx_op      = 8'b00100000;
    parameter   bit_start               = 1'b0;
    parameter   bit_stop                = 1'b1;
    parameter   bit_par                 = 1'b1;
    reg         [7:0]   counter;
    reg         [7:0]   ch_data;
    // __________________________________________________________ //
    reg                   rx;
    reg                   clock;
    reg                   reset;
    wire                   s_tick;
    wire                  rx_done_tick;
    wire [NB_DATA-1:0]    dout;

    BaudRateGenerator BRG_Tx (
        .clock(clock),  .reset(reset),
        .tick(s_tick)
    );
    
    topRx   mytopRx (
        .reset(reset),                  .clock(clock),
        .rx(rx),                        .s_tick(s_tick), 
        .rx_done_tick(rx_done_tick),    .dout(dout)
    );
    
    initial
    begin
        counter = 0;
        ch_data = 0;
        clock   = 0;
        rx      = 1;
        reset   = 1;
        #PERIOD reset = 0;
    end
    
    always begin
        #(PERIOD/2) clock = ~clock;
        #(PERIOD/2);
    end
    
    always @(posedge s_tick) begin
        case (ch_data)
            CH_DATA: begin
                ch_data <= 0;
                case (counter)
                    8'b00000000: begin
                        rx      <= bit_start;
                        counter <= counter + 1;
                    end
                    8'b00000001: begin
                        rx      <= data_rx[0];
                        counter <= counter + 1;
                    end
                    8'b00000010: begin
                        rx      <= data_rx[1];
                        counter <= counter + 1;
                    end
                    8'b00000011: begin
                        rx      <= data_rx[2];
                        counter <= counter + 1;
                    end
                    8'b00000100: begin
                        rx      <= data_rx[3];
                        counter <= counter + 1;
                    end
                    8'b00000101: begin
                        rx      <= data_rx[4];
                        counter <= counter + 1;
                    end
                    8'b00000110: begin
                        rx      <= data_rx[5];
                        counter <= counter + 1;
                    end
                    8'b00000111: begin
                        rx      <= data_rx[6];
                        counter <= counter + 1;
                    end
                    8'b00001000: begin
                        rx      <= data_rx[7];
                        counter <= counter + 1;
                    end
                    8'b00001001: begin
                        rx      <= bit_par;
                        counter <= counter + 1;
                    end
                    8'b00001010: begin
                        rx      <= bit_stop;
                        counter <= 0;
                    end
                endcase
              end
            default: ch_data <= ch_data + 1;
        endcase     
    end
endmodule

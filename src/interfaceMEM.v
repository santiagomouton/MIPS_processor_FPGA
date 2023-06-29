`timescale 1ns / 1ps

`define N_ELEMENTS 128
`define ADDRWIDTH $clog2(`N_ELEMENTS)

module interfaceMEM
#(
    /** numero de bits - datos*/
    parameter NB_DATA   = 32,                        // cantidad de bits de la trama
    parameter RX_DATA   = 8,                        // input bits rx
    parameter NB_STATE  = 5                         // catnidad de estados de la interface
)
(
    /* DATO */
    input   wire reset,
    input   wire clock,                                // clock que alimenta el sistema,
    input   wire                    wr,
    input   wire  [RX_DATA - 1:0] in_rx,          // Se presenta los bit provistos por rx uart
    /* SALIDA*/
    output  reg   [NB_DATA - 1:0] o_data_mem,
    output  reg   [`ADDRWIDTH - 1:0] o_dir_mem,
    output  reg                   ready,
    output  reg                   finish_rcv
    
//    output reg [NB_STATE-1 :0] VER_ESTADOS
);

    reg [2:0]count;

    always @(posedge clock)
    begin
        if (reset) begin
            count <= 3'b000;
            ready <= 0;
            o_dir_mem <= 0;
            finish_rcv <= 0;
        end
    end

    always @(posedge clock) 
    begin
        if (count == 3'b101) begin
            count <= 3'b000;
            ready <= 0;
            o_dir_mem <= o_dir_mem + 1;
            o_data_mem <= 32'b0;
            finish_rcv <= 1'b0;
        end
        else if (count == 3'b100) begin
            /* Si recivo 32 bits en 1 logicos significa que termino la recepcion de instrucciones */
            if (o_data_mem == 32'b11111111111111111111111111111111)
            begin
                finish_rcv <= 1'b1;
                o_dir_mem <= 7'bxxxxxxx;
                count <= 3'b000;
            end
            else begin
                ready <= 1;
                count <= count + 1;
            end
        end
        else if (wr) begin
            o_data_mem <= {in_rx, o_data_mem[NB_DATA    -1:8]};
            count <= count + 1;
        end
        else begin
            ready <= 0;
        end
    end
   
//    assign o_tx = o_tx_reg;
   
endmodule
`timescale 1ns / 1ps

module DATAmem
    #(
        parameter NB_DATA   = 32,
        parameter N_ELEMENTS= 128
    )
    (
        input wire clock_i,
        input wire enable_mem_i, 

        input wire [7-1:0] addr_i,
        input wire [NB_DATA-1:0] data_write_i,

        input wire mem_read_i,
        input wire mem_write_i,
    
        output wire [NB_DATA-1:0] data_o
    );

    reg [NB_DATA-1:0] RAM[N_ELEMENTS-1:0];
    reg [NB_DATA-1:0] data_reg = {NB_DATA{1'b0}}; 

    assign data_o = data_reg;    

    initial
    begin
/* 
        RAM[0] <= 32'b0000_0000_1111_0000_0000_1100_0000_0001; // Data 0
        RAM[1] <= 32'b0000_0000_1111_0000_0000_0011_0000_0001; // Data 1
        RAM[2] <= 32'b0000_0000_1111_0000_0001_1100_0001_0000; // Data 2
        RAM[3] <= 32'b0000_0000_1111_0000_0000_0000_0000_0011; // Data 3
        RAM[4] <= 32'b0000_0000_0000_0000_0000_0000_0000_0100; // Data 4
        RAM[5] <= 32'b0000_0000_0000_0000_0000_0000_0000_0101; // Data 5
         */
        RAM[0] <= 32'b1000_0000_0000_0000_0000_0000_0000_0101;
        RAM[1] <= 32'b0000_0000_1111_0000_0000_0011_0000_0001; // Data 1
        RAM[2] <= 32'b0000_0000_1111_0000_0001_1100_0001_0000; // Data 2

    end
    
    always @(negedge clock_i)
    begin
        if (enable_mem_i)
            begin
                if (mem_write_i)
                    RAM[addr_i] <= data_write_i;
            end
        else
            RAM[addr_i] <= RAM[addr_i];
    end

    always @(negedge clock_i)
    begin
        if (enable_mem_i)
            begin          
                if (mem_read_i)
                    data_reg <= RAM[addr_i];
            else
                data_reg <= 32'bz;
            end
    end

endmodule
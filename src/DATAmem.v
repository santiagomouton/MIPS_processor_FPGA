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
    reg [NB_DATA-1:0] data_reg = 32'b0;//{NB_DATA{1'b0}}; 

    assign data_o = data_reg;
    
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
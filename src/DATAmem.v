`timescale 1ns / 1ps

module DATAmem
    #(
        parameter NB_DATA   = 32,
        parameter N_ELEMENTS= 128
    )
    (
        input wire clock_i,
        input wire reset_i,
        input wire enable_mem_i, 

        input wire [7-1:0] addr_i,
        input wire [NB_DATA-1:0] data_write_i,

        input wire mem_read_i,
        input wire mem_write_i,
    
        output wire [NB_DATA-1:0] data_o
    );  


    reg [NB_DATA-1:0] RAM[N_ELEMENTS-1:0];
    reg [NB_DATA-1:0] data_reg; 

    assign data_o = data_reg;
    
    integer i;
    
    always @(negedge clock_i)
    begin
        if (reset_i) begin
            for(i=0; i < N_ELEMENTS; i = i+1) begin
                RAM[i] <= 32'b0;
            end
            data_reg <= 32'b0;
        end else begin
            if (enable_mem_i)
                begin
                    if (mem_write_i)
                        RAM[addr_i] <= data_write_i;
                end
            if (mem_read_i)
                data_reg <= RAM[addr_i];
            // else
            //     data_reg <= 32'bz;
        end
    end


/*         else
            RAM[addr_i] <= RAM[addr_i]; */


//     reg [NB_DATA-1:0] RAM[N_ELEMENTS-1:0];
//     reg [NB_DATA-1:0] data_reg = 32'b0;//{NB_DATA{1'b0}}; 
    
//     always @(negedge clock_i)
//     begin
//         if (enable_mem_i)
//             begin
//                 if (mem_write_i)
//                 begin
//                     RAM[addr_i] <= data_write_i;
//                 end
//                 else begin
//                     if (mem_read_i)
//                     begin
//                         data_reg <= RAM[addr_i];
//                     end
//                 end
//             end
//         else begin
//             data_reg <= 32'b0;
//         end
// /*         else
//             RAM[addr_i] <= RAM[addr_i]; */
//     end

//     // Asignación de la salida
//     always @(negedge clock_i) begin
//         if (enable_mem_i) begin
//             data_o <= data_reg;  // Salida tomada del registro de salida
//         end else begin
//             data_o <= 32'b0;  // Resetear la salida
//         end
//     end


endmodule

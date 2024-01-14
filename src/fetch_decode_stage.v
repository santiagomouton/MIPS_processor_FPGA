`timescale 1ns / 1ps

module fetch_decode_stage
	#(
		parameter NB_DATA = 32		
	)
	(
		input wire clock_i,  
		input wire en_pipeline,
		input wire [7-1:0] pc_i,
		input wire [NB_DATA-1:0] instruction_i,

		output reg [7-1:0] pc_o,
		output reg [NB_DATA-1:0] instruction_o			
	);
	
	always @(negedge clock_i)
		begin
			if (en_pipeline)
				begin					
					pc_o          <= pc_i;
					instruction_o <= instruction_i;		
				end
				
			else
				begin
					pc_o 		  <= pc_o;
					instruction_o <= instruction_o;
				end
				
								
		end		
endmodule 
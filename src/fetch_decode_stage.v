`timescale 1ns / 1ps

module fetch_decode_stage
	#(
		parameter NB_DATA = 32		
	)
	(
		input wire clock_i,
		input wire reset_i,
		input wire en_pipeline,
		input wire [NB_DATA-1:0] pc_i,
		input wire [NB_DATA-1:0] instruction_i,

		output wire [NB_DATA-1:0] pc_o,
		output wire [NB_DATA-1:0] instruction_o			
	);

	reg [NB_DATA-1:0] pc_reg;
	reg [NB_DATA-1:0] instruction_reg;			
	
	always @(negedge clock_i)
		begin
			if (reset_i) begin
				pc_reg          <= 0;
				instruction_reg <= 0;					
			end else begin
				if (en_pipeline)
					begin					
						pc_reg          <= pc_i;
						instruction_reg <= instruction_i;		
					end
				else
					begin
						pc_reg 		  	<= pc_reg;
						instruction_reg <= instruction_reg;
					end
			end
		end

	assign pc_o = pc_reg;	
	assign instruction_o = instruction_reg;	

endmodule 
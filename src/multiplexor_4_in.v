`timescale 1ns / 1ps

module multiplexor_4_in
	#(
		parameter NB_DATA = 32
	)
	(
		input wire [NB_DATA-1:0] op1_i,
		input wire [NB_DATA-1:0] op2_i,
		input wire [NB_DATA-1:0] op3_i,
		input wire [NB_DATA-1:0] op4_i,
		input wire [1:0] sel_i,

		output wire [NB_DATA-1:0] data_o	
	);

	reg [NB_DATA-1:0] data_reg;

	always @(*)
		begin
			case (sel_i)
				2'b00:
					data_reg = op1_i;
				2'b01:
					data_reg = op2_i;
				2'b10:
					data_reg = op3_i;
				2'b11:
					data_reg = op4_i;

				default:
					data_reg = op1_i;
					
			endcase

		end
	assign data_o = data_reg;

endmodule
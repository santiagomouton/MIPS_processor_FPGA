module multiplexor_2_in
	#(
		parameter NB_DATA = 32
	)
	(
		input wire [NB_DATA-1:0] op1_i,
		input wire [NB_DATA-1:0] op2_i,
		input wire sel_i,

		output wire [NB_DATA-1:0] data_o	
	);

	reg [NB_DATA-1:0] data_reg;

	always @(*)
		begin
			case (sel_i)
				1'b0:
					data_reg = op1_i;
				1'b1:
					data_reg = op2_i;

				default:
					data_reg = op1_i;
					
			endcase

		end
	assign data_o = data_reg;

endmodule
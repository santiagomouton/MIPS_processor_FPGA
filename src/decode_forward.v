module decode_forward
	#(
		parameter NB_DATA = 32,
		parameter NB_REG  = 5
	)

	(
		input wire [NB_REG-1:0] wire_A_dec,
		input wire [NB_REG-1:0] wire_B_dec,
		
		input wire [NB_REG-1:0] writeReg,
		input wire ex_mem_reg_write,	

		output reg decode_forward_A, decode_forward_B
	);

	initial 
		begin
			decode_forward_A = 0;
			decode_forward_B = 0;
		end

	always @(*)
		begin
			if ((ex_mem_reg_write == 1'b1) && (wire_A_dec == EX_MEM_write_reg_i))
				decode_forward_A = 1'b1;//viene de la etapa MEM		
			else
				decode_forward_A = 1'b0;

			if ((ex_mem_reg_write == 1'b1) && (wire_B_dec == EX_MEM_write_reg_i))
				decode_forward_B = 1'b1;//viene de la etapa MEM			
			else
				decode_forward_B = 1'b0;

		end

endmodule
`timescale 1ns / 1ps

module decode_forward
	#(
		parameter NB_DATA = 32,
		parameter NB_REG  = 5
	)

	(
		input wire [NB_REG-1:0] wire_A_dec_i,
		input wire [NB_REG-1:0] wire_B_dec_i,
		
		input wire [NB_REG-1:0] writeReg_mem_i,
		input wire ex_mem_reg_write_i,

		input wire [NB_REG-1:0] writeReg_wb_i,
		input wire mem_wb_reg_write_i,

		output reg[1:0] decode_forward_A, decode_forward_B
	);

	initial 
		begin
			decode_forward_A = 2'b00;
			decode_forward_B = 2'b00;
		end

	always @(*)
		begin
			if ((ex_mem_reg_write_i == 1'b1) && (wire_A_dec_i == writeReg_mem_i))
				decode_forward_A = 2'b01;	//viene de la etapa MEM		
			else if ((mem_wb_reg_write_i == 1'b1) && (wire_A_dec_i == writeReg_wb_i))
				decode_forward_A = 2'b10;	//viene de la etapa WB		
			else
				decode_forward_A = 2'b00;

			if ((ex_mem_reg_write_i == 1'b1) && (wire_B_dec_i == writeReg_mem_i))
				decode_forward_B = 2'b01;	//viene de la etapa MEM	
			else if ((mem_wb_reg_write_i == 1'b1) && (wire_B_dec_i == writeReg_wb_i))
				decode_forward_B = 2'b10;	//viene de la etapa WB
			else
				decode_forward_B = 2'b00;
		end

endmodule
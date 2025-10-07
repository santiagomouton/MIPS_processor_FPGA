`timescale 1ns / 1ps

module forward_unit
	#(
		parameter NB_DATA = 32,
		parameter NB_REG  = 5
	)

	(
		input wire [NB_REG-1:0] register_a_i,
		input wire [NB_REG-1:0] register_b_i,
		
		input wire [NB_REG-1:0] ex_mem_writeReg_i,
		input wire [NB_REG-1:0] mem_wb_writeReg_i,

		input wire ex_mem_reg_write_i,
		input wire mem_wb_reg_write_i,

		output reg [1:0] forward_signal_regA,
		output reg [1:0] forward_signal_regB
	);

	always @(*)
		begin
			if ((ex_mem_reg_write_i == 1'b1) && (register_a_i == ex_mem_writeReg_i))
				forward_signal_regA = 2'b01;    // señal para tomar el valor desde la etapa de memoria
			else if ((mem_wb_reg_write_i == 1'b1) && (register_a_i == mem_wb_writeReg_i))
				forward_signal_regA = 2'b10;    // señal para tomar el valor desde la etapa de writeback
			else
				forward_signal_regA = 2'b00;

            // se repite la logica para el valor B
			if ((ex_mem_reg_write_i == 1'b1) && (register_b_i == ex_mem_writeReg_i))
				forward_signal_regB = 2'b01;
			else if ((mem_wb_reg_write_i == 1'b1) && (register_b_i == mem_wb_writeReg_i))
				forward_signal_regB = 2'b10;
			else
				forward_signal_regB = 2'b00;
		end

endmodule
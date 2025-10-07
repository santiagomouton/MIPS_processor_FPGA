`timescale 1ns / 1ps

module hazard_unit
	#(
		parameter NB_OPCODE = 6,
		parameter NB_REG = 5
	)
	(

		input wire execute_stage_mem_read_i,
		input wire memory_stage_mem_read_i,
		input wire execute_stage_reg_write_i,
		input wire branch_or_jr_i,
		input wire [NB_REG-1:0] wire_A_decode_i,
		input wire [NB_REG-1:0] wire_B_decode_i,
		input wire [NB_REG-1:0] dec_ex_register_write_i,
		input wire [NB_REG-1:0] ex_mem_register_write_i,
		
		
		input wire halt_signal_i,

		output reg stall_o,
		output wire pc_write_o, //detiene cargar la sig direccion
		output wire if_dec_write_o //detiene cargar la instruccion en el registro IF_ID
	

	);

 	reg reg_pc_write, reg_if_dec_write;
	
	initial
		begin
			reg_pc_write     = 1'b1;
			reg_if_dec_write = 1'b1; 
			stall_o 		 = 1'b0; 
		end

	always @(*)
		begin
			// dependencia con Instruccion LOAD
			if (((execute_stage_mem_read_i == 1'b1) && ((dec_ex_register_write_i != 5'b0) && 
			((dec_ex_register_write_i == wire_A_decode_i) || (dec_ex_register_write_i == wire_B_decode_i)))) || halt_signal_i)                
				begin						
					reg_pc_write = 1'b0;
					reg_if_dec_write = 1'b0;
					stall_o = 1'b1;
				end	
			// instruccion de salto (branch, jump_register) depende de LOAD en stage memory
	 		else if (memory_stage_mem_read_i == 1'b1 && branch_or_jr_i == 1'b1 && 
			((ex_mem_register_write_i != 5'b0) && ((ex_mem_register_write_i == wire_A_decode_i) || (ex_mem_register_write_i == wire_B_decode_i))))
				begin					
					reg_pc_write = 1'b0;
					reg_if_dec_write = 1'b0;
					stall_o = 1'b1;
				end	
			// instruccion de salto depende de resultado de registro
	 		else if (execute_stage_reg_write_i == 1'b1 && branch_or_jr_i == 1'b1 &&
			((dec_ex_register_write_i != 5'b0) && ((dec_ex_register_write_i == wire_A_decode_i) || (dec_ex_register_write_i == wire_B_decode_i))))
				begin					
					reg_pc_write = 1'b0;
					reg_if_dec_write = 1'b0;
					stall_o = 1'b1;
				end	
			else
				begin
					reg_pc_write = 1'b1;
					reg_if_dec_write = 1'b1;
					stall_o = 1'b0; 
				end
		end

	assign pc_write_o = reg_pc_write;
	assign if_dec_write_o = reg_if_dec_write;
	
endmodule
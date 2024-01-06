
module hazard_unit
	#(
		parameter NB_OPCODE = 6,
		parameter NB_REG = 5
	)
	(

		input wire dec_ex_mem_read,
		input wire [NB_REG-1:0] wire_A_decode,
		input wire [NB_REG-1:0] wire_B_decode,
		input wire [NB_REG-1:0] dec_ex_register_b,
		// input wire [NB_REG-1:0] writeReg_execute,

		input wire EX_reg_write_i,
		input wire [NB_REG-1:0] EX_write_register_i,
		input wire halt_signal,

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
		begin // LOAD R|I|B + HALT
			if (((dec_ex_mem_read == 1'b1) && ((dec_ex_register_b != 5'b0) && 
			((dec_ex_register_b == wire_A_decode) || (dec_ex_register_b == wire_B_decode)))) || halt_signal)                
				begin						
					reg_pc_write = 1'b0;
					reg_if_dec_write = 1'b0;
					stall_o = 1'b1;
				end	
/* 			else if (EX_reg_write_i == 1'b1 && ((EX_write_register_i != 5'b0) && ((EX_write_register_i == ID_rs_i) || (EX_write_register_i == ID_rt_i))))
				begin					
					reg_pc_write = 1'b0;
					reg_if_dec_write = 1'b0;
					stall_o = 1'b1;
				end	 */	
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
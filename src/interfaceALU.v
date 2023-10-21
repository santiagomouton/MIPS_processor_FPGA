
module interfaceALU
	#(
		parameter NB_FUNCTION = 6,
		parameter NB_OP_ALU   = 6

	)
	(
		input wire [NB_FUNCTION-1:0] funct,
		input wire [NB_OP_ALU-1:0] opcode,

		output wire [NB_OP_ALU-1:0] funct_for_alu
	);

	reg [NB_OP_ALU-1:0] reg_alu_op;

	assign funct_for_alu = reg_alu_op;

	always @(*)
		begin
			case(opcode)
				6'd0://R-type
					begin
						case (funct)

							// `SLL_FUNCTION  : reg_alu_op  = `SLL; 
							6'b000010  : reg_alu_op  = 6'b000010; //SRL
							6'b000011  : reg_alu_op  = 6'b000011; //SRA
							// `SRLV_FUNCTION : reg_alu_op  = `SRL;
							// `SRAV_FUNCTION : reg_alu_op  = `SRA; 
							6'b100001  : reg_alu_op  = 6'b100000; //ADDU
							// `SLLV_FUNCTION : reg_alu_op  = `SLL;
							// `SUBU_FUNCTION  : reg_alu_op = `SUB;
							6'b100100  : reg_alu_op  = 6'b100100;  //AND
							6'b100101   : reg_alu_op  = 6'b100101; //OR
							6'b100110  : reg_alu_op  = 6'b100110; //XOR
							6'b100111  : reg_alu_op  = 6'b100111; //NOR
							// `SLT_FUNCTION  : reg_alu_op  = `SLT;
							default : reg_alu_op = funct;
							// default : reg_alu_op = 6'b000000;
						endcase
					end
				6'b001000 : reg_alu_op = 6'b100000;  // ADDI -> ADD
				6'b001100 : reg_alu_op = 6'b100100;  // ANDI -> AND
				6'b001101 : reg_alu_op = 6'b100101;  // ORI -> OR
				6'b100011 : reg_alu_op = 6'b100000;	 // LW -> ADD 
				6'b010011 : reg_alu_op = 6'b100000;	 // LWU -> ADD 
				6'b100000 : reg_alu_op = 6'b100000;	 // LB -> ADD 
				// `SLTI_ALUCODE     :	reg_alu_op = `SLT;
				// `LUI_ALUCODE      : reg_alu_op = `LUI;
				default :  reg_alu_op = 6'b000000;
			endcase
				
		end

endmodule


`timescale 1ns / 1ps

module mem_wb_stage
	#(
		parameter NB_DATA 		= 32,
		parameter NB_WB_CTRL	= 3,
		parameter NB_REG  		= 5
	)
	(
		input wire clock_i,
		input wire reset_i,
		input wire enable_pipe_i,
		input wire [NB_DATA-1:0] mem_data_read_i,
		input wire [NB_DATA-1:0] alu_result_i,
		input wire [NB_DATA-1:0] pc_i,
        // input wire [NB_DATA-1:0] data_inm_i, //dato a escribir en registro (LUI) 
		input wire [NB_REG-1:0] write_register_i,
		input wire [2:0]wb_signals_i,
		input wire halt_signal_i,

		output wire [NB_REG-1:0] write_register_o,
		output wire [2-1:0] mem_to_reg_o,
		output wire [NB_DATA-1:0] mem_data_read_o,
		output wire [NB_DATA-1:0] alu_result_o,
		output wire [NB_DATA-1:0] pc_o,
		// output wire [NB_DATA-1:0] inm_ext_o,
		output wire reg_write_o,
		output wire halt_signal_o	
	);

	reg [2-1:0] mem_to_reg;
	reg [NB_REG-1:0] write_reg;
	reg reg_write;
	reg [NB_DATA-1:0] mem_data_reg, alu_result_reg, inm_ext_reg;
	reg [NB_DATA-1:0] pc_reg;
	reg halt_signal_reg;
	

	always @(negedge clock_i)
		begin
			if (reset_i)
				begin
					mem_to_reg      <= 2'b0;
					reg_write       <= 1'b0;
					write_reg       <= 5'b0;
					mem_data_reg    <= 32'b0;
					alu_result_reg  <= 32'b0;
					pc_reg          <= 32'b0;
					halt_signal_reg <= 1'b0;
					// inm_ext_reg    <= 32'b0;
				end
			else
				begin
					if (enable_pipe_i)
						begin
							mem_to_reg      <= wb_signals_i[1:0];
							reg_write       <= wb_signals_i[2];
							write_reg       <= write_register_i;
							mem_data_reg    <= mem_data_read_i;
							alu_result_reg  <= alu_result_i;
							pc_reg          <= pc_i;
							halt_signal_reg <= halt_signal_i;
							// inm_ext_reg    <= data_inm_i;
						end
					else
						begin
							mem_to_reg      <= mem_to_reg;
							reg_write       <= reg_write;
							write_reg       <= write_reg;
							mem_data_reg    <= mem_data_reg;
							alu_result_reg  <= alu_result_reg;
							pc_reg          <= pc_reg;
							halt_signal_reg <= halt_signal_reg;
							// inm_ext_reg    <= inm_ext_reg;
						end
				end
		end

	assign mem_to_reg_o     = mem_to_reg;
	assign reg_write_o      = reg_write;
	assign write_register_o = write_reg;
	assign mem_data_read_o  = mem_data_reg;
	assign alu_result_o     = alu_result_reg;
	assign pc_o             = pc_reg;
	assign halt_signal_o 	= halt_signal_reg;
	// assign inm_ext_o        = inm_ext_reg;

endmodule
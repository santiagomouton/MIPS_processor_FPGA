
module ex_mem_stage
	#(
		parameter NB_DATA = 32,
        parameter NB_REGWR = 5
	)
	(
		input wire clock_i,  
		input wire en_pipeline,
		input wire [NB_DATA-1:0] data_wr_to_mem_i,
		input wire [NB_DATA-1:0] alu_result_i,
		input wire [NB_REGWR-1:0] writeReg_i,
        input wire [7-1:0] pc_i,
        input wire [5:0]mem_signals_i,

		output wire [NB_DATA-1:0] data_wr_to_mem_o,
        output wire [NB_DATA-1:0] alu_result_o,
        output wire [NB_REGWR-1:0] writeReg_o,
        output wire [7-1:0] pc_o,
        output wire [5:0]mem_signals_o
	);
	

	reg [7-1:0] pc_reg;
	reg [NB_DATA-1:0] data_wr_to_mem_reg, alu_result_reg;
    reg [NB_REGWR-1:0] writeReg_reg;

	// reg [NB_FUNCTION-1:0] function_reg;
	// reg [NB_OP-1:0] opcode_reg;
    reg [5:0] mem_signals_reg;
	// reg halt_detected;
	// reg [NB_EX_CTRL-1:0] EX_control_reg;
	// reg [NB_WB_CTRL-1:0] WB_control_reg;


	// assign halt_detected_o = halt_detected;

	always @(negedge clock)
    begin
        if (reset)
            begin 
                pc_reg     	 <= 6'b000000;
                data_wr_to_mem_reg  <= 32'd0;
                alu_result_reg  <= 32'd0;
                writeReg_reg  <= 5'b00000;
                mem_signals_reg <= 6'b000000;
            end
        else
            begin
                if (en_pipeline)
                    begin
                        // halt_detected <= halt_detected_i;
                        pc_reg              <= pc_i;
                        data_wr_to_mem_reg  <= data_wr_to_mem_i;
                        alu_result_reg      <= alu_result_i;
                        writeReg_reg        <= writeReg_i;
                        mem_signals_reg     <= mem_signals_i;
                    end
                else
                    begin
                        // halt_detected <= halt_detected;
                        pc_reg              <= pc_reg;
                        data_wr_to_mem_reg  <= data_wr_to_mem_reg;
                        alu_result_reg      <= alu_result_reg;
                        writeReg_reg        <= writeReg_reg;
                        mem_signals_reg     <= mem_signals_reg;
                    end
            end
    end	

	assign pc_o    = pc_reg;
	assign data_wr_to_mem_o = data_wr_to_mem_reg;
	assign alu_result_o = alu_result_reg;
	assign writeReg_i = writeReg_reg;
    assign mem_signals_o = mem_signals_reg;

	// assign function_o = function_reg;
	// assign opcode_o = opcode_reg;
	// assign tipeI_o = tipeI_reg;


endmodule
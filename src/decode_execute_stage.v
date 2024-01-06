
module decode_execute_stage
	#(
		parameter NB_DATA 		= 32,
		parameter NB_REG  		= 5,
		parameter NB_FUNCTION 	= 6,
		parameter NB_EX_CTRL  	= 7,
		parameter NB_MEM_CTRL 	= 6,
		parameter NB_WB_CTRL  	= 3,
		parameter NB_OP 		= 6,
		parameter N_REGDEST 	= 2
	)
	(
		input wire clock,   
		input wire reset,
		input wire en_pipeline,
		input wire [7-1:0] pc_i,
		input wire [NB_REG-1:0]	register_a_i, register_b_i, register_rw_i,
		// input wire [NB_REG-1:0]	shamt_i,

		input wire [NB_FUNCTION-1:0] function_i,
		input wire [NB_DATA-1:0] data_ra_i,
		input wire [NB_DATA-1:0] data_rb_i,
		input wire [NB_DATA-1:0] inm_ext_i,
		input wire tipeI,

		input wire [N_REGDEST-1:0] regDest_signal_i,

		input wire [NB_OP-1:0] opcode,
		input wire [5:0]mem_signals_i,
		input wire [2:0]wb_signals_i,
		input wire halt_signal_i,

		output wire [NB_DATA-1:0] data_ra_o,
		output wire [NB_DATA-1:0] data_rb_o,
		output wire [NB_DATA-1:0] inm_ext_o,
		output wire tipeI_o,

		// output wire [NB_REG-1:0] shamt_o,

		output wire [7-1:0] pc_o,
		output wire [NB_REG-1:0] register_a_o, register_b_o, register_rw_o,

		output wire [NB_FUNCTION-1:0] function_o,
		output wire [N_REGDEST-1:0] regDest_signal_o,

		output wire [NB_OP-1:0] opcode_o,
		output wire [5:0]mem_signals_o,
		output wire [2:0]wb_signals_o,
		output wire halt_signal_o
	);

	reg [7-1:0] pc_reg;
	reg [NB_DATA-1:0] data_ra_reg, data_rb_reg, inm_ext_reg;
	reg tipeI_reg;
	reg [NB_REG-1:0] register_a_reg, register_b_reg, register_wr_reg;//, shamt_reg;

	reg [NB_FUNCTION-1:0] function_reg;
	reg [N_REGDEST-1:0] regDest_signal_reg;
	reg [NB_OP-1:0] opcode_reg;
	reg [5:0]mem_signals_reg;
	reg [5:0]wb_signals_reg;
	reg halt_signal_reg;


	always @(negedge clock)
		begin
			if (reset)
				begin 
					pc_reg     	 		<= 6'b000000;
					data_ra_reg  		<= 32'b0;
					data_rb_reg  		<= 32'b0;
					inm_ext_reg  		<= 32'b0;
					// shamt_reg    <= 5'b0;
					function_reg 		<= 6'b0;
					regDest_signal_reg 	<= 2'b10;
					opcode_reg 			<= 6'b0;
					tipeI_reg 			<= 1'b0;
					mem_signals_reg 	<= 6'b000000;
					wb_signals_reg 		<= 6'b000;
					halt_signal_reg 	<= 1'b0;
				end
			else
				begin
					if (en_pipeline)
						begin
						    pc_reg        		<= pc_i;
							data_ra_reg   		<= data_ra_i;
							data_rb_reg   		<= data_rb_i;
							inm_ext_reg   		<= inm_ext_i;
							// shamt_reg     <= shamt_i;
							function_reg  		<= function_i;
							regDest_signal_reg  <= regDest_signal_i;
							opcode_reg 	  		<= opcode;
							tipeI_reg  	  		<= tipeI;
							mem_signals_reg 	<= mem_signals_i;
							wb_signals_reg 		<= wb_signals_i;
							halt_signal_reg 	<= halt_signal_i;
						end
					else
						begin
							pc_reg 	  			<= pc_reg;
							data_ra_reg   		<= data_ra_reg;
							data_rb_reg   		<= data_rb_reg;
							inm_ext_reg   		<= inm_ext_reg;
							// shamt_reg     <= shamt_reg;
							function_reg  		<= function_reg;
							regDest_signal_reg  <= regDest_signal_reg;
							opcode_reg 	  		<= opcode_reg;
							tipeI_reg     		<= tipeI_reg;
							mem_signals_reg 	<= mem_signals_reg;
							wb_signals_reg 		<= wb_signals_reg;
							halt_signal_reg 	<= halt_signal_reg;
						end
				end
		end	
 
	always @(negedge clock)
		begin
			if (reset)
				begin
					register_a_reg <= 5'b0;
					register_b_reg <= 5'b0;
					register_wr_reg <= 5'b0;
				end
			else
				begin
					if (en_pipeline)
						begin
							register_a_reg <= register_a_i;
							register_b_reg <= register_b_i;
							register_wr_reg <= register_rw_i;
						end	
					else
						begin
							register_a_reg <= register_a_reg;
							register_b_reg <= register_b_reg;
							register_wr_reg <= register_wr_reg;
						end
				end
		end

	assign pc_o    	 = pc_reg;
	assign data_ra_o = data_ra_reg;
	assign data_rb_o = data_rb_reg;
	assign inm_ext_o = inm_ext_reg;

	assign function_o 		= function_reg;
	assign opcode_o 		= opcode_reg;
	assign regDest_signal_o = regDest_signal_reg;
	assign tipeI_o 			= tipeI_reg;
	// assign shamt_o    = shamt_reg;

	assign register_a_o      = register_a_reg;
	assign register_b_o      = register_b_reg;
	assign register_rw_o     = register_wr_reg;

	assign mem_signals_o	= mem_signals_reg;
	assign wb_signals_o		= wb_signals_reg;
	assign halt_signal_o 	= halt_signal_reg;


endmodule 
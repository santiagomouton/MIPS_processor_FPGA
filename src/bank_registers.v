`timescale 1ns / 1ps

module bank_registers
	#(
		parameter NB_REG = 5,
		parameter NB_DATA = 32,
		parameter N_REGISTER = 32		
	)
	( 
		input wire clock_i,
		input wire reset_i,
		input wire rw_i, 
		input wire [NB_REG-1:0] addr_ra_i,
		input wire [NB_REG-1:0] addr_rb_i,
		input wire [NB_REG-1:0] addr_rw_i,
		input wire [NB_DATA-1:0] data_rw_i,

		output reg [NB_DATA-1:0] data_ra_o,
		output reg [NB_DATA-1:0] data_rb_o		
	
	);
	reg [NB_DATA-1:0] registers[N_REGISTER-1:0];  	

    always @(posedge clock_i)
        begin
	        if (reset_i)
				begin	        			
					data_ra_o <= 32'b0;
					data_rb_o <= 32'b0;
				end        	
        	else 
				begin
					if (rw_i)
						begin
							if (addr_rw_i != 5'b0)
								registers[addr_rw_i] <= data_rw_i;
							/* if (addr_ra_i == addr_rw_i)
								data_ra_o <= data_rw_i;
							else if (addr_rb_i == addr_rw_i)
								data_rb_o <= data_rw_i; */
						end
					data_ra_o <= registers[addr_ra_i];
					data_rb_o <= registers[addr_rb_i];
				end
        end

	generate
	    integer i;

		initial
	    for (i = 2; i < N_REGISTER; i = i + 1)
	        registers[i] = 32'd0;

	endgenerate


endmodule
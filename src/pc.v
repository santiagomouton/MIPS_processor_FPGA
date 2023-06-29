
module pc
	#(
		parameter NB_DATA = 7
	)
	(
		input wire clock,
		input wire reset,
		input wire enable,				
		input wire [NB_DATA-1:0] next_addr_i,
		output wire [NB_DATA-1:0] next_addr_o
	);

	reg [NB_DATA-1:0] reg_addr;

	always @(negedge clock)
		begin
		    if (reset)
		        reg_addr <= {NB_DATA{1'b0}};
		    else 
		    	begin
		    		if (enable) 
		    		    reg_addr <= next_addr_i;  
	
			        else
			        	reg_addr <= reg_addr;

		    	end 
		end

	assign next_addr_o = reg_addr;

endmodule
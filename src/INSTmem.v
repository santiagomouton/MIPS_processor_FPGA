`timescale 1ns / 1ps

module INSTmem
	#(
		parameter NB_DATA 	= 32,
		parameter NBYTE   	= 8,
		parameter N_ELEMENTS= 128
	)
	( 
		input wire clock_i,
		input wire reset_i,
		input wire en_write_i,
		input wire en_read_i, 		
		
		input wire [NB_DATA-1:0] addr_i_write,
		input wire [NB_DATA-1:0] addr_i_read,
		input wire [NB_DATA-1:0] data_i,
		output wire [NB_DATA-1:0] data_o
	
	);

	reg [NB_DATA-1:0] memory_instruction[N_ELEMENTS-1:0];
    reg [NB_DATA-1:0] data_reg;
	integer i;

	always @(posedge clock_i)
		begin
			if (reset_i)
				for (i = 0 ; i < N_ELEMENTS ; i = i + 1)
					memory_instruction[i] <= {32'd0};
			else if (en_write_i) begin
				/* memory_instruction[0] <= 32'haaaaaaaa;
				memory_instruction[1] <= 32'hbabababa;
				memory_instruction[2] <= 32'h238900c7;
				memory_instruction[3] <= 32'hac070000;
				memory_instruction[4] <= 32'hac880000;
				memory_instruction[5] <= 32'hae890000;
				memory_instruction[6] <= 32'h238a000a;
				memory_instruction[7] <= 32'h238b000a;
				memory_instruction[8] <= 32'h8c020000;
				memory_instruction[9] <= 32'h8e850000;
				memory_instruction[10] <= 32'hfc000000; */ 
				
				/* memory_instruction[0] <= 32'h00000000;
				memory_instruction[1] <= 32'h11111111;
				memory_instruction[2] <= 32'h22222222;
				memory_instruction[3] <= 32'h33333333;
				memory_instruction[4] <= 32'h44444444;
				memory_instruction[5] <= 32'hfc000000;
				 */
/* 					if (data_i == 32'h238700aa) begin
						memory_instruction[addr_i_write[6:0]] <= 32'h238700aa;
					end 
					else if(data_i == 32'h238800b5)begin
						memory_instruction[addr_i_write[6:0]] <= 32'h81818181;
					end
					else if(data_i == 32'h238900c7)begin
						memory_instruction[addr_i_write[6:0]] <= 32'hf2f2f2f2;
					end
					else if(data_i == 32'hac070000)begin
						memory_instruction[addr_i_write[6:0]] <= 32'ha3a3a3a3;
					end
					else if(data_i == 32'hac880000)begin
						memory_instruction[addr_i_write[6:0]] <= 32'h238700aa;
					end
					else if(data_i == 32'hae890000)begin
						memory_instruction[addr_i_write[6:0]] <= 32'hae890000;
					end
					else if(data_i == 32'h238a000a)begin
						memory_instruction[addr_i_write[6:0]] <= 32'h238a000a;
					end
					else if(data_i == 32'h8c020000)begin
						memory_instruction[addr_i_write[6:0]] <= 32'h8c020000;
					end
					else if(data_i == 32'h8e850000)begin
						memory_instruction[addr_i_write[6:0]] <= 32'h8e850000;
					end
					else if(data_i == 32'hfc000000)begin
						memory_instruction[addr_i_write[6:0]] <= 32'hfc000000;
					end
					else begin */
					memory_instruction[addr_i_write[6:0]] <= data_i;
						// memory_instruction[addr_i_write[6:0]][7:0] <= data_i[7:0];
						// memory_instruction[addr_i_write[6:0]][15:8] <= data_i[15:8];
						// memory_instruction[addr_i_write[6:0]][23:16] <= data_i[23:16];
						// memory_instruction[addr_i_write[6:0]][31:24] <= data_i[31:24];
/* 						memory_instruction[addr_i_write[6:0]][7:0] <= 8'h11;
						memory_instruction[addr_i_write[6:0]][15:8] <= 8'h22;
						memory_instruction[addr_i_write[6:0]][23:16] <= 8'h33;
						memory_instruction[addr_i_write[6:0]][31:24] <= 8'h44; */
					// end

				end
			else 
			// if (en_read_i)		
				data_reg <= memory_instruction[addr_i_read[6:0]];			
			/* else 
				data_reg <= data_reg;	 */						
		end
	
	assign data_o = data_reg;
  
endmodule


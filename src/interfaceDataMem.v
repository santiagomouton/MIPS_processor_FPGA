`timescale 1ns / 1ps

`define BYTE  3'b001
`define HALF_WORD 3'b010
`define WORD 3'b100

module interfaceDataMEM
	#(
		parameter NB_DATA     = 32,
		parameter NB_MEM_CTRL = 6	    
	)
	(
		input wire [NB_DATA-1:0] data_write_i,		
		input wire [NB_DATA-1:0] data_read_i,
   		input wire [NB_MEM_CTRL-1:0] mem_signals_i,

   		output wire [NB_DATA-1:0] data_write_o,
   		output wire [NB_DATA-1:0] data_read_o
	);

	reg [NB_DATA-1:0] data_write_reg;
	reg [NB_DATA-1:0] data_read_reg;
    

	always @(*)
		begin	
			if (mem_signals_i[4]) // memory read
	            begin 	
	                if (mem_signals_i[5]) //signado 
	                	begin 
			            	case (mem_signals_i[2:0]) //size(Word, HalfWord, Byte)		            		
								`BYTE:	                		
									data_read_reg = {{24{data_read_i[7]}}, data_read_i[7:0]}; 		  			
								`HALF_WORD:
									data_read_reg = {{16{data_read_i[15]}}, data_read_i[15:0]}; 
								`WORD:
									data_read_reg = data_read_i;     
								default:
									data_read_reg = 32'b0;        
	                		endcase
	                	end
	              	else
	              		begin
	              			case (mem_signals_i[2:0])	              				
								`BYTE:	                		
									data_read_reg = {{24{1'b0}}, data_read_i[7:0]}; 			                			           			
								`HALF_WORD:
									data_read_reg = {{16{1'b0}}, data_read_i[15:0]};  
								`WORD:
									data_read_reg = data_read_i;                 	
								default:
									data_read_reg = 32'b0;        
	                		endcase
	              		end
	            end	
	        else
				data_read_reg = 32'b0;	  
		end

	always @(*)
		begin
			if (mem_signals_i[3]) // memory write
	            begin 
	            	case (mem_signals_i[2:0])
	                	`BYTE:
	                		data_write_reg = data_write_i[7:0];                
	                	`HALF_WORD:
	                    	data_write_reg = data_write_i[15:0];	                    
	                	`WORD:            
	                    	data_write_reg = data_write_i;         
	                    default:
	                    	data_write_reg = 32'b0;
	                endcase
	            end
	        else
	            data_write_reg = 32'hffffffff;
		end

	assign data_write_o = data_write_reg;
	assign data_read_o  = data_read_reg;

endmodule
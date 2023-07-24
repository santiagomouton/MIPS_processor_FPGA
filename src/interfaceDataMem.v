`timescale 1ns / 1ps

`define BYTE  3'b001
`define HALF_WORD 3'b010
`define WORD 3'b100

`define N_BYTE 7:0
`define N_HALF 15:0

`define MEM_READ 4
`define MEM_WRITE 3
`define SIZE 2:0
`define SIGNED 5

// `define N_ELEMENTS 128
// `define ADDRWIDTH $clog2(`N_ELEMENTS)

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

	reg [NB_DATA-1:0] data_read_paraver_reg;

	assign data_write_o = data_write_reg;
	assign data_read_o  = data_read_reg;
    

	always @(*)
		begin	
			if (mem_signals_i[`MEM_READ])
	            begin 	
	                if (mem_signals_i[`SIGNED]) 
	                	begin 
			            	case (mem_signals_i[`SIZE])			            		
				                	`BYTE:	                		
				                		begin
				                			data_read_reg = {{24'b0}, data_read_i[`N_BYTE]};   		  			
				                		end	                		                
				                            
				                	`HALF_WORD:
				                		begin				                			                			
				                			data_read_reg = {16'b0, data_read_i[`N_HALF]};  
				                    	end
				                    	
				                	`WORD:
				                	  begin
									 		data_read_reg = data_read_i;     
				                		end

				                    default:
				                    	data_read_reg = 32'b0;        
	                    	
	                			endcase
	                	end
	              	else
	              		begin
	              			case (mem_signals_i[`SIZE])	              				
				                	`BYTE:	                		
				                		begin
				                			data_read_reg = {{24{data_read_i[7]}}, data_read_i[`N_BYTE]}; 			                			           			
				                		end	                		                
				                            
				                	`HALF_WORD:
				                		begin	                			
				                			data_read_reg = {{16{data_read_i[15]}}, data_read_i[`N_HALF]};   
				                    	end
				                    	
				                	`WORD:
				                	  begin
				                		data_read_reg = data_read_i;                 	
				                		end

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
			if (mem_signals_i[`MEM_WRITE])
	            begin    
	            	case (mem_signals_i[`SIZE])
	                	`BYTE:
	                		data_write_reg = data_write_i[`N_BYTE];                
	                            
	                	`HALF_WORD:               
	                    	data_write_reg = data_write_i[`N_HALF];	                    

	                	`WORD:                    
	                    	data_write_reg = data_write_i;         
	                    default:
	                    	data_write_reg = 32'b0;
	                endcase
	            end
	        else
	            data_write_reg = 32'b0;
		end

endmodule
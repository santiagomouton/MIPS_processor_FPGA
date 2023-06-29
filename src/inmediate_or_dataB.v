
module inmediate_or_dataB
#(
    parameter NB_DATA = 32
) 
(
    input wire tipeI,
    input wire [NB_DATA-1:0]inmediate,
    input wire [NB_DATA-1:0]dataB,
    output wire [NB_DATA-1:0]o_B_to_alu
);
    
  reg [NB_DATA-1:0]o_B_to_alu_reg;

  assign o_B_to_alu = o_B_to_alu_reg;

always @(*) begin
    if (tipeI == 1'b1) begin
      o_B_to_alu_reg = inmediate;
    end
    else begin
      o_B_to_alu_reg = dataB;
    end
end


endmodule


module control_unit
    #(
		parameter NB_DATA = 32,
		parameter NB_OP = 6,
		parameter NB_FUNCT = 6,
		parameter N_REGISTER = 32
    )
    (
        input wire clock,
        input wire reset,
        input wire [NB_OP-1:0]opcode,
        input wire [NB_FUNCT-1:0]funct,

        output wire regDest,
        output wire regWrite,
        output wire tipeI,
        output wire branch,
        output wire [NB_OP-1:0]opcode_o
    );

    reg regWrite_reg;
    reg regDest_reg;
    reg tipeI_reg;
    reg branch_reg;


    initial begin
        regWrite_reg = 1'b0;
        regDest_reg = 1'b0;
        tipeI_reg = 1'b0;     
        branch_reg = 1'b0;     
    end

    always @(*) begin
 /*        
        regWrite_reg = 1'b0;
        regDest_reg  = 1'b0;
        tipeI_reg    = 1'b0;     
        branch_reg   = 1'b0; */

        case (opcode)
            6'b000000: begin
                regDest_reg = 1;
                regWrite_reg = 1;
                tipeI_reg = 0;
                /* if (conditions) begin
                    regWrite_reg <= 1;
                end */
            end
            6'b001000: begin  //ADDI
                regDest_reg = 0;
                regWrite_reg = 1;
                tipeI_reg = 1;
            end
            6'b100001: begin //
                regDest_reg = 0;
                regWrite_reg = 0;
                tipeI_reg = 0;
            end
            6'b100011: begin //
                regDest_reg = 0;
                regWrite_reg = 0;
                tipeI_reg = 0;
            end
            6'b010011: begin // LWU
                regDest_reg = 0;
                regWrite_reg = 0;
                tipeI_reg = 0;
            end
            6'b100100: begin
                regDest_reg = 0;
                regWrite_reg = 0;
                tipeI_reg = 0;
            end
            6'b10101: begin //
                regDest_reg = 0;
                regWrite_reg = 0;
                tipeI_reg = 0;
            end
            6'b101000: begin
                regDest_reg = 0;
                regWrite_reg = 0;
                tipeI_reg = 0;
            end
            6'b101001: begin // SH
                regDest_reg = 0;
                regWrite_reg = 0;
                tipeI_reg = 0;
            end
            6'b101011: begin //sw
                regDest_reg = 0;
                regWrite_reg = 0;
                tipeI_reg = 0;
            end
            6'b001000: begin // 
                regDest_reg = 0;
                regWrite_reg = 0;
                tipeI_reg = 0;
            end
            default: begin
                regDest_reg = 1;
                regWrite_reg = 1;
                tipeI_reg = 1;
            end
        endcase
    end

    assign regDest = regDest_reg;
    assign regWrite = regWrite_reg;
    assign tipeI = tipeI_reg;
    assign opcode_o = opcode;

endmodule
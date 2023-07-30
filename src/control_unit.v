

module control_unit
    #(
		parameter NB_DATA = 32,
		parameter NB_OP = 6,
		parameter NB_FUNCT = 6,
		parameter N_REGISTER = 32,
		parameter N_REGDEST = 2
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
        output wire memWrite,
        output wire [N_REGDEST-1:0]regDest_signal, // 1-0(00: wireB, 01: wireWR, 10: 32'b1)
        output wire [NB_OP-1:0]opcode_o,

        output wire [5:0]mem_signals, // 5(sign), 4-3(mem_read, mem_write), 2-0(Word, HalfWord, Byte)  
        output wire [2:0]wb_signals // 2(regWrite), 1-0(mem_to_reg)(00:memData_to_reg, 01: alu_result_to_reg, 10: pc_to_reg)

    );

    reg regWrite_reg;
    reg tipeI_reg;
    reg branch_reg;
    reg [N_REGDEST-1:0]regDest_signal_reg;

    reg memWrite_reg;

    reg [5:0]mem_signals_reg;
    reg [2:0]wb_signals_reg;

    initial begin
        regWrite_reg = 1'b0;
        tipeI_reg = 1'b0;     
        branch_reg = 1'b0;     
        memWrite_reg = 1'b0;    

        regDest_signal_reg = 2'b00;
        mem_signals_reg = 6'b000000;
        wb_signals_reg = 3'b000;
    end

    always @(*) begin

        regWrite_reg = 1'b0;
        tipeI_reg    = 1'b0;     
        branch_reg   = 1'b0;
        memWrite_reg = 1'b0;

        regDest_signal_reg = 2'b00;
        mem_signals_reg = 6'b000000;
        wb_signals_reg = 3'b000;

        case (opcode)
            6'b000000: begin
                tipeI_reg = 0;
                memWrite_reg = 1'b0;
                regDest_signal_reg = 3'b01;
                mem_signals_reg = 6'b000000;
                wb_signals_reg = 3'b101; 
                /* if (conditions) begin
                    regWrite_reg <= 1;
                end */
            end
            6'b001000: begin  //ADDI
                tipeI_reg = 1;
                memWrite_reg = 1'b0;
                regDest_signal_reg = 3'b00;
                mem_signals_reg = 6'b000000;
                wb_signals_reg = 3'b101;
            end
            6'b100011: begin // LW
                tipeI_reg = 1;
                memWrite_reg = 1'b1;
                regDest_signal_reg = 3'b00;
                mem_signals_reg = 6'b110100;
                wb_signals_reg = 3'b100;
            end
            6'b010011: begin // LWU
                tipeI_reg = 1;
                regDest_signal_reg = 3'b00;
                mem_signals_reg = 6'b010100;
                wb_signals_reg = 3'b100;
            end
            6'b100000: begin // LB
                tipeI_reg = 1;
                regDest_signal_reg = 3'b00;
                mem_signals_reg = 6'b110001;
                wb_signals_reg = 3'b100;
            end
            6'b111110: begin  //NOP
                tipeI_reg = 0;
                regDest_signal_reg = 3'b00;
                mem_signals_reg = 6'b000000;
                wb_signals_reg = 3'b000;
            end
            6'b111111: begin // HALT
                tipeI_reg = 0;
                regDest_signal_reg = 3'bxx;
                mem_signals_reg = 6'b000000;
                wb_signals_reg = 3'bxxx;
            end
            6'b101000: begin
                tipeI_reg = 0;
                regDest_signal_reg = 3'b00;
                mem_signals_reg = 6'b010100;
                wb_signals_reg = 3'b000;
            end
            6'b101001: begin // SH
                tipeI_reg = 0;
                regDest_signal_reg = 3'b00;
                mem_signals_reg = 6'b010100;
                wb_signals_reg = 3'b000;
            end
            6'b101011: begin //sw
                tipeI_reg = 0;
                regDest_signal_reg = 3'b00;
                mem_signals_reg = 6'b010100;
                wb_signals_reg = 3'b000;
            end
            6'b001000: begin // 
                tipeI_reg = 0;
                regDest_signal_reg = 3'b00;
                mem_signals_reg = 6'b010100;
                wb_signals_reg = 3'b000;
            end
            default: begin
                tipeI_reg = 0;
                regDest_signal_reg = 3'b00;
                mem_signals_reg = 6'b010100;
                wb_signals_reg = 3'b000;
            end
        endcase
    end

    assign wb_signals = wb_signals_reg;
    assign regWrite = regWrite_reg;
    assign tipeI = tipeI_reg;
    assign regDest_signal = regDest_signal_reg;
    assign opcode_o = opcode;

    assign mem_signals = mem_signals_reg;

endmodule
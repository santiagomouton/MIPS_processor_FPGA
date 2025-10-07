`timescale 1ns / 1ps

module control_unit
    #(
		parameter NB_DATA = 32,
		parameter NB_OP = 6,
		parameter NB_FUNCT = 6,
		parameter N_REGISTER = 32,
		parameter N_REGDEST = 2,
		parameter NB_CONTROL_SIGNALS = 18
    )
    (
        input wire [NB_OP-1:0]opcode_i,
        input wire [NB_FUNCT-1:0]funct_i,

        output wire tipeI_o,
        output wire shamt_o,
        output wire beq_o,
		output wire bne_o,
		output wire jump_o,
        output wire [1:0]pc_src_o, // (00: address_register, 01: address_jump, 10: address_branch) 
        output wire [N_REGDEST-1:0]regDest_signal_o, // 1-0(00: wireB, 01: wireWR, 10: 32'b1)


        output wire [5:0]mem_signals_o, // 5(sign), 4-3(mem_read, mem_write), 2-0(Word, HalfWord, Byte)  
        output wire [2:0]wb_signals_o, // 2(regWrite), 1-0(mem_to_reg)(00:memData_to_reg, 01: alu_result_to_reg, 10: pc_to_reg)
 
        output wire [NB_OP-1:0]opcode_o,
        output wire halt_signal_o

        // output wire control_signals_o[NB_CONTROL_SIGNALS-1:0]
        // 17: tipeI, 16: shamt, 15: beq, 14: bne, 13: jump
        // [12:11]: pc_src (00: address_register, 01: address_jump, 10: address_branch)
        // [10:9]: regDest_signal (00: wireB, 01: wireWR, 10: 32'b1)
        // [8:3]:   mem_signals (5(sign), 4-3(mem_read, mem_write), 2-0(Word, HalfWord, Byte))
        // [2:0]:   wb_signals (2(regWrite), 1-0(mem_to_reg)(00:memData_to_reg, 01: alu_result_to_reg, 10: pc_to_reg))

    );

    reg tipeI_reg;
    reg shamt_reg;
    reg beq_reg;
    reg bne_reg;
    reg jump_reg;
    reg [1:0]pc_src_reg;
    reg [N_REGDEST-1:0]regDest_signal_reg;


    reg [5:0]mem_signals_reg;
    reg [2:0]wb_signals_reg;
    reg halt_signal_reg;

    initial begin
        tipeI_reg = 1'b0;     
        shamt_reg = 1'b0;     
        beq_reg = 1'b0;     
        bne_reg = 1'b0;     
        jump_reg = 1'b0;     
        // memWrite_reg = 1'b0;    

        pc_src_reg = 2'b00;
        regDest_signal_reg = 2'b00;
        mem_signals_reg = 6'b000000;
        wb_signals_reg = 3'b000;
        halt_signal_reg = 1'b0;
    end

    always @(*) begin

        tipeI_reg    = 1'b0;
        shamt_reg = 1'b0; 
        beq_reg   = 1'b0;
        bne_reg   = 1'b0;

        pc_src_reg     = 2'b00;
        regDest_signal_reg = 2'b00;
        mem_signals_reg = 6'b000000;
        wb_signals_reg = 3'b000;
        halt_signal_reg = 1'b0;

        case (opcode_i)
            6'b000000: begin
                if (funct_i == 6'b001001) begin // ESPECIAL JALR
                    tipeI_reg = 1'b0;
                    beq_reg   = 1'b0;
                    bne_reg   = 1'b0;
                    jump_reg  = 1'b1;
                    // memWrite_reg = 1'b0;
                    regDest_signal_reg = 3'b01;
                    mem_signals_reg = 6'b000000;
                    wb_signals_reg = 3'b101;
                    pc_src_reg     = 2'b00;           
                end
                else if (funct_i == 6'b001000) begin // ESPECIAL JR
                    tipeI_reg = 1'b0;
                    beq_reg   = 1'b0;
                    bne_reg   = 1'b0;
                    jump_reg  = 1'b1;
                    // memWrite_reg = 1'b0;
                    regDest_signal_reg = 3'b00;
                    mem_signals_reg = 6'b000000;
                    wb_signals_reg = 3'b000;
                    pc_src_reg     = 2'b00;                    
                end
                else if (funct_i == 6'b000000) begin // NOP
                    tipeI_reg = 1'b0;
                    beq_reg   = 1'b0;
                    bne_reg   = 1'b0;
                    jump_reg  = 1'b0;
                    regDest_signal_reg = 3'b00;
                    mem_signals_reg = 6'b000000;
                    wb_signals_reg = 3'b000;
                    pc_src_reg     = 2'b00;
                end
                else begin //TIPO R
                    tipeI_reg = 1'b0;
                    beq_reg   = 1'b0;
                    bne_reg   = 1'b0;
                    jump_reg  = 1'b0;
                    // memWrite_reg = 1'b0;
                    regDest_signal_reg = 3'b01;
                    mem_signals_reg = 6'b000000;
                    wb_signals_reg = 3'b101;
                    pc_src_reg     = 2'b00;
                end
            end
            6'b001000: begin  //ADDI
                tipeI_reg = 1'b1;
                beq_reg   = 1'b0;
                bne_reg   = 1'b0;
                jump_reg  = 1'b0;
                // memWrite_reg = 1'b0;
                regDest_signal_reg = 3'b00;
                mem_signals_reg = 6'b000000;
                wb_signals_reg = 3'b101;
                pc_src_reg     = 2'b00;
            end
            6'b100011: begin // LW
                tipeI_reg = 1'b1;
                beq_reg   = 1'b0;
                bne_reg   = 1'b0;
                jump_reg  = 1'b0;
                // memWrite_reg = 1'b1;
                regDest_signal_reg = 3'b00;
                mem_signals_reg = 6'b110100;
                wb_signals_reg = 3'b100;
                pc_src_reg     = 2'b00;
            end
            6'b010011: begin // LWU
                tipeI_reg = 1'b1;
                beq_reg   = 1'b0;
                bne_reg   = 1'b0;
                jump_reg  = 1'b0;
                regDest_signal_reg = 3'b00;
                mem_signals_reg = 6'b010100;
                wb_signals_reg = 3'b100;
                pc_src_reg     = 2'b00;
            end
            6'b100000: begin // LB
                tipeI_reg = 1'b1;
                beq_reg   = 1'b0;
                bne_reg   = 1'b0;
                jump_reg  = 1'b0;
                regDest_signal_reg = 3'b00;
                mem_signals_reg = 6'b110001;
                wb_signals_reg = 3'b100;
                pc_src_reg     = 2'b00;
            end
            6'b100001: begin // LH
                tipeI_reg = 1'b1;
                beq_reg   = 1'b0;
                bne_reg   = 1'b0;
                jump_reg  = 1'b0;
                regDest_signal_reg = 3'b00;
                mem_signals_reg = 6'b110010;
                wb_signals_reg = 3'b100;
                pc_src_reg     = 2'b00;
            end
            6'b101000: begin
                tipeI_reg = 1'b0;
                beq_reg   = 1'b0;
                bne_reg   = 1'b0;
                jump_reg  = 1'b0;
                regDest_signal_reg = 3'b00;
                mem_signals_reg = 6'b010100;
                wb_signals_reg = 3'b000;
            end
            6'b101001: begin // SH
                tipeI_reg = 1'b1;
                beq_reg   = 1'b0;
                bne_reg   = 1'b0;
                jump_reg  = 1'b0;
                regDest_signal_reg = 3'b00;
                mem_signals_reg = 6'b010100;
                wb_signals_reg = 3'b000;
                pc_src_reg     = 2'b00;
            end
            6'b101011: begin //sw
                tipeI_reg = 1'b1;
                beq_reg   = 1'b0;
                bne_reg   = 1'b0;
                jump_reg  = 1'b0;
                regDest_signal_reg = 3'b00;
                // mem_signals_reg = 6'b010100;
                mem_signals_reg = 6'b001100;
                wb_signals_reg = 3'b000;
                pc_src_reg     = 2'b00;
            end
/*             6'b001000: begin // 
                tipeI_reg = 1'b0;
                beq_reg   = 1'b0;
                bne_reg   = 1'b0;
                jump_reg  = 1'b0;
                regDest_signal_reg = 3'b00;
                mem_signals_reg = 6'b010100;
                wb_signals_reg = 3'b000;
            end */


            6'b000100: begin  // BEQ
                tipeI_reg = 1'b1;
                regDest_signal_reg = 3'b00;
                beq_reg   = 1'b1;
                bne_reg   = 1'b0;
                jump_reg  = 1'b0;
                mem_signals_reg = 6'b000000;
                wb_signals_reg = 3'b000;

                pc_src_reg     = 2'b10;
            end				
            6'b000101: begin  // BNE
                tipeI_reg = 1'b1;
                regDest_signal_reg = 3'b00;
                beq_reg   = 1'b0;
                bne_reg   = 1'b1;
                jump_reg  = 1'b0;
                mem_signals_reg = 6'b000000;
                wb_signals_reg = 3'b000;

                pc_src_reg     = 2'b10;   
            end
            6'b110001: begin  // J
                tipeI_reg = 1'b0;
                regDest_signal_reg = 3'b00;
                beq_reg   = 1'b0;
                bne_reg   = 1'b0;
                jump_reg  = 1'b1;
                mem_signals_reg = 6'b000000;
                wb_signals_reg = 3'bxxx;

                pc_src_reg     = 2'b01;						
            end
            6'b000011: begin  // JAL
                tipeI_reg = 1'b0;
                regDest_signal_reg = 3'b10;
                beq_reg   = 1'b0;
                bne_reg   = 1'b0;
                jump_reg  = 1'b1;
                mem_signals_reg = 6'b000000;
                wb_signals_reg = 3'b110;

                pc_src_reg     = 2'b01;									
            end	

            6'b111110: begin  //NOP
                tipeI_reg = 1'b0;
                beq_reg   = 1'b0;
                bne_reg   = 1'b0;
                jump_reg  = 1'b0;
                regDest_signal_reg = 3'b00;
                mem_signals_reg = 6'b000000;
                wb_signals_reg = 3'b000;
            end
            6'b111111: begin // HALT
                halt_signal_reg = 1'b1;
                tipeI_reg = 1'b0;
                beq_reg   = 1'b0;
                bne_reg   = 1'b0;
                jump_reg  = 1'b0;
                regDest_signal_reg = 3'b00;
                mem_signals_reg = 6'b000000;
                wb_signals_reg = 3'b000;
            end
            default: begin
                halt_signal_reg = 1'b0;
                tipeI_reg = 1'b0;
                regDest_signal_reg = 3'b00;
                beq_reg   = 1'b0;
                bne_reg   = 1'b0;
                jump_reg  = 1'b0;
                mem_signals_reg = 6'b010100;
                wb_signals_reg = 3'b000;
            end
        endcase
    end

    // assign control_signals_o = {tipeI_reg, shamt_reg, beq_reg, bne_reg, jump_reg, pc_src_reg, regDest_signal_reg, opcode, mem_signals_reg, wb_signals_reg}
    assign tipeI_o = tipeI_reg;
    assign shamt_o = shamt_reg;
    assign beq_o = beq_reg;
    assign bne_o = bne_reg;
    assign jump_o = jump_reg;
    assign pc_src_o = pc_src_reg;
    assign regDest_signal_o = regDest_signal_reg;

    assign mem_signals_o = mem_signals_reg;
    assign wb_signals_o = wb_signals_reg;
    assign opcode_o = opcode_i;
    assign halt_signal_o = halt_signal_reg;


endmodule
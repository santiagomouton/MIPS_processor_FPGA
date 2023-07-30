

module distributor 
#(
    parameter NB_DATA = 32,
    parameter NB_OP = 6,
    parameter NB_FUNCT = 6,
    parameter NB_INM = 16,
    parameter NB_REGA = 5,
    parameter NB_REGB = 5,
    parameter NB_REGD = 5,
    parameter NB_DIRECTION = 26
) 
(
    input wire [NB_DATA-1:0]instruction,
    input wire regDst,
    output wire [NB_OP-1:0]operation,
    output wire [NB_FUNCT-1:0]funct,
    output wire [NB_INM-1:0]inmediate,
    output wire [NB_REGA-1:0]wire_A,
    output wire [NB_REGB-1:0]wire_B,
    output wire [NB_DIRECTION-1:0]direction,
    output wire [NB_REGD-1:0]wire_dest
);

    assign operation   = instruction[31:26];
    assign funct       = instruction[5:0];
    assign inmediate   = instruction[15:0];
    assign wire_A      = instruction[25:21];
    assign wire_B      = instruction[20:16];
    assign direction   = instruction[25:0];
    assign wire_dest   = instruction[15:11];

endmodule
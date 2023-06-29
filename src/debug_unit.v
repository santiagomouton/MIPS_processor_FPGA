

module debug_unit 
#(
    parameter NB_DATA = 32,
    parameter NBYTE   = 8
) 
(
    input wire clock,
    input wire finish_rcv,
    output reg en_pipeline_o
);

    reg en_pipeline_reg;


    always @(posedge clock ) begin
        if (finish_rcv)
            en_pipeline_o <= 1'b1;
        else 
            en_pipeline_o <= 1'b0;
    end

endmodule
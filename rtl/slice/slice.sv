module slice #(parameter N=0)
    (
        input        CLK,
        input [3:0]  Instruction,
        input [7:0]  Target,
        input [7:0]  Arg1,
        input [7:0]  Arg2,
        input [7:0]  PC_in,
        output [7:0] PC_out
    );
`include "incl/ISA_Ops.svh"

    generate
        if (N == 0) begin
            // TODO hook up branch unit to alu
            //branch_unit bu();
        end;
    endgenerate

    always @(posedge CLK) begin

    end
endmodule // slice

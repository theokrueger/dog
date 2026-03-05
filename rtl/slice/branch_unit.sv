module branch_unit(
        input [1:0] Operation,
        input [7:0] Address,
        input [7:0] PC,
        input wire Zero,
        input wire Sub,
        output [7:0] PC_out
    );
`include "incl/Branch_Ops.svh"

    assign PC_out = PC;

    always @(Operation or Address) begin
        case (Operation)
            BRANCH_ZERO_OP:
                if (Zero == 1)
                    PC_out = Address;
            BRANCH_NOTZERO_OP:
                if (Zero == 0)
                    PC_out = Address;
            BRANCH_SUBOVERFLOW_OP:
                if (Sub == 1):
                        PC_out = Address;
        default: begin end
        endcase
    end
endmodule

module branch_unit(
        input CLK,
        input [2:0]      Operation,
        input [7:0]      Address,
        input [7:0]      PC,
        input wire       Zero,
        input wire       Sub_UF,
        output reg [7:0] PC_out
    );
`include "incl/Branch_Ops.svh"

    always @(posedge CLK) begin
        PC_out = PC + 8'b00000001;
        case (Operation)
            BRANCH_NO_OP: begin
            end
            BRANCH_ZERO_OP: begin
                if (Zero == 1)
                    PC_out = Address;
            end
            BRANCH_NOTZERO_OP: begin
                if (Zero == 0)
                    PC_out = Address;
            end
            BRANCH_SUBOVERFLOW_OP: begin
                if (Sub_UF == 1)
                    PC_out = Address;
            end
            BRANCH_UNCONDITIONAL_OP: begin
                PC_out = Address;
            end
            default: begin
                $display("Unreachable case in branch_unit was reached at %d!", $time);
                $display("Op: ", Operation);
                $finish;
            end
        endcase // case (Operation)
    end
endmodule // branch_unit

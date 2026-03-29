module alu(
           input CLK,
           input [3:0]      Operation,
           input [7:0]      A,
           input [7:0]      B,
           output reg [7:0] Y,
           output wire      Zero,
           output wire      Sub_UF
    );
`include "incl/ALU_Ops.svh"

    assign Zero = (Y == 8'b0);
    assign Sub_UF = ((Operation == ALU_SUB_OP) && (B > A));

    always @(posedge CLK)
    begin
        case (Operation)
            ALU_ADD_OP:
            begin
                Y = A + B;
            end
            ALU_SUB_OP:
            begin
                Y = A - B;
            end
            ALU_MUL_OP:
            begin
                Y = A*B;
            end
            ALU_DIV_OP:
            begin
                Y = A/B;
            end
            ALU_MOD_OP:
            begin
                Y = A % B;
            end
            ALU_AND_OP:
            begin
                Y = A & B;
            end
            ALU_OR_OP:
            begin
                Y = A | B;
            end
            ALU_EQ_OP:
            begin
                if (A == B)
                    Y = 8'b1;
                else
                    Y = 8'b0;
            end
            ALU_GT_OP:
            begin
                if (A > B)
                    Y = 8'b1;
                else
                    Y = 8'b0;
            end
            ALU_GTE_OP:
            begin
                if (A >= B)
                    Y = 8'b1;
                else
                    Y = 8'b0;
            end
            default:
            begin
                Y = 8'b0;
            end
        endcase

    end
endmodule // alu

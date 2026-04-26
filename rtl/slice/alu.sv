module alu(
        input CLK,
        input [3:0]      Operation,
        input [7:0]      A,
        input [7:0]      B,
        output logic [7:0] Y,
        output logic      Zero,
        output logic      Sub_UF
    );
`include "incl/ALU_Ops.svh"

    assign Zero = (Y == 8'b0);
    assign Sub_UF = ((Operation == ALU_SUB_OP) && (B > A));

    always @(*)
    begin
        //$display("alu op %d %d %d %d", Operation, ALU_ADD_IM_OP, A, B);
        unique case (Operation)
            ALU_ADD_OP,
            ALU_ADD_IM_OP:
            begin
                //$display("adding");
                Y <= A + B;
                //$display("y %d %d %d", Y, A, B);
            end
            ALU_SUB_OP,
            ALU_SUB_IM_OP:
            begin
                Y <= A - B;
            end
            ALU_MUL_OP,
            ALU_MUL_IM_OP:
            begin
                Y <= A*B;
            end
            ALU_DIV_OP,
            ALU_DIV_IM_OP:
            begin
                Y <= A/B;
            end
            ALU_MOD_OP,
            ALU_MOD_IM_OP:
            begin
                Y <= A % B;
            end
            ALU_AND_OP:
            begin
                Y <= A & B;
            end
            ALU_OR_OP:
            begin
                Y <= A | B;
            end
            ALU_EQ_OP:
            begin
                if (A == B)
                    Y <= 8'b1;
                else
                    Y <= 8'b0;
            end
            ALU_GT_OP:
            begin
                if (A > B)
                    Y <= 8'b1;
                else
                    Y <= 8'b0;
            end
            ALU_GTE_OP:
            begin
                if (A >= B)
                    Y <= 8'b1;
                else
                    Y <= 8'b0;
            end
            default:
            begin
                Y <= 8'b0;
            end
        endcase
    end
endmodule // alu

module alu(
    input [3:0] Operation,
    input [7:0] A,
    input [7:0] B,
    output reg [7:0] Y,
    output wire Zero // for branch ops mostly
  );
`include "incl/ALU_Ops.svh"

  assign Zero = (Y == 8'b0);


  always @(Operation or A or B)
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
            Y = 8'b0; // TODO
          end
        ALU_DIV_OP:
          begin
            Y = 8'b0; // TODO
          end
        ALU_AND_OP:
          begin
            Y = A & B;
$display("%b %b %b", A, B, Y);
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

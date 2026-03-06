module slice #(parameter N=0)
    (
        input [3:0]  Instruction,
        input [7:0]  Target,
        input [7:0]  Arg1,
        input [7:0]  Arg2,
        input [7:0]  PC_in,
        output [7:0] PC_out
    );
`include "incl/ISA_Ops.svh"
`include "incl/ALU_Ops.svh"
`include "incl/Branch_Ops.svh"

    generate
        if (N == 0) begin
            // TODO hook up branch unit to alu
            wire [3:0] branch_op;
            always @(Instruction) begin
                if (Instruction == ISA_OP_JEZ) begin

                end
                else if (Instruction == ISA_OP_JGZ) begin

                end
                //               else if (Instruction == ISA_OP_
                else begin
                    branch_op <= BRANCH_NO_OP;
                end

            end
            //branch_unit bu();
        end;
    endgenerate

    always @(Instruction or Target or Arg1 or Arg2 or PC_in) begin
        case (Instruction)
            ISA_OP_NOP:  begin
                //TODO
            end
            ISA_OP_ADD:  begin
                //TODO
            end
            ISA_OP_SUB:  begin
                //TODO
            end
            ISA_OP_MUL:  begin
                //TODO
            end
            ISA_OP_DIV:  begin
                //TODO
            end
            ISA_OP_JMP:  begin
                //TODO
            end
            ISA_OP_JEZ:  begin
                //TODO
            end
            ISA_OP_JGZ:  begin
                //TODO
            end
            ISA_OP_LADD: begin
                //TODO
            end
            ISA_OP_LSUB: begin
                //TODO
            end
            ISA_OP_LMUL: begin
                //TODO
            end
            ISA_OP_LDIV: begin
                // TODO
            end
            default: begin
                $display("Unreachable case in branch_unit was reached!");
                $finish;
            end
        endcase // case (Instruction)
    end

end
endmodule // slice

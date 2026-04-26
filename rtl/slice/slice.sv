module slice #(parameter N=0)
    (
        input CLK,
        input [3:0]  Instruction,
        input [7:0]  Arg1,
        input [7:0]  Arg2,
        input [7:0]  Regs [0:15],
        input [7:0]  PC_in,
        output [7:0] PC_out,
        output [7:0] ALU_out
    );
`include "incl/ISA_Ops.svh"
`include "incl/ALU_Ops.svh"
`include "incl/Branch_Ops.svh"

    // ALU
    logic [3:0] alu_op;
    logic       alu_zero;
    logic       alu_sub_uf;
    alu alu(
            .CLK(CLK),
            .Operation(alu_op),
            .A(Regs[Arg1]),
            .B(Instruction == ISA_OP_ADD_IM ? Arg2 : Regs[Arg2]),
            .Y(ALU_out),
            .Zero(alu_zero),
            .Sub_UF(alu_sub_uf)
        );

    // Instruction Dispatch
    always @(posedge CLK) begin
        $display("inst %d %d %d %d %d", Instruction, Arg1, Arg2, Regs[Arg1], Regs[Arg2]);
        unique case (Instruction)
                   ISA_OP_NOP:  begin
                       // it is assumed that target, arg1, and arg2 are zeroed here
                       alu_op <= ALU_NO_OP;
                   end
                   ISA_OP_ADD:  begin
                       alu_op <= ALU_ADD_OP;
                   end
                   ISA_OP_SUB:  begin
                       alu_op <= ALU_SUB_OP;
                   end
                   ISA_OP_MUL:  begin
                       alu_op <= ALU_MUL_OP;
                   end
                   ISA_OP_DIV:  begin
                       alu_op <= ALU_DIV_OP;
                   end
                   ISA_OP_JMP:  begin
                       alu_op <= ALU_NO_OP;
                   end
                   ISA_OP_JEZ:  begin
                       alu_op <= ALU_EQ_OP;
                   end
                   ISA_OP_JGZ:  begin
                       alu_op <= ALU_GT_OP;
                   end
                   ISA_OP_LADD: begin
                       alu_op <= ALU_ADD_OP;
                   end
                   ISA_OP_LSUB: begin
                       alu_op <= ALU_SUB_OP;
                   end
                   ISA_OP_LMUL: begin
                       alu_op <= ALU_MUL_OP;
                   end
                   ISA_OP_LDIV: begin
                       alu_op <= ALU_DIV_OP;
                   end
                   ISA_OP_ADD_IM: begin
                       alu_op <= ALU_ADD_OP;
                   end
                   default: begin
                       // only assert after no longer Z
                       alu_op <= ALU_NO_OP;
                       if ($time > 0) begin
                           $display("Unreachable case in slice was reached!");
                           $display("Instruction:", Instruction);
                           $finish;
                       end;
                   end
               endcase // case (Instruction)
   end

   // Branch unit
   generate
       if (N == 0) begin
           logic [2:0] branch_op;
           always @(posedge CLK) begin
               case (Instruction)
                   ISA_OP_JMP:  begin
                       branch_op = BRANCH_UNCONDITIONAL_OP;
                   end
                   ISA_OP_JEZ:  begin
                       branch_op = BRANCH_ZERO_OP;
                   end
                   ISA_OP_JGZ:  begin
                       branch_op = BRANCH_NOTZERO_OP;
                   end
                   default: begin
                       branch_op = BRANCH_NO_OP;
                   end
               endcase // case (Instruction)
           end
           branch_unit bu(
                           .CLK(CLK),
                           .Operation(branch_op),
                           .Address(Target),
                           .PC(PC_in),
                           .PC_out(PC_out),
                           .Zero(alu_zero),
                           .Sub_UF(alu_sub_uf)
                       );
       end;
   endgenerate


endmodule // slice

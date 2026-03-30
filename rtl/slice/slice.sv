module slice #(parameter N=0)
    (
        input CLK,
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

    // ALU
    logic [3:0] alu_op;
    logic [7:0] alu_arg_1;
    logic [7:0] alu_arg_2; // may be literal or register
    logic [7:0] alu_target;
    logic       alu_zero;
    logic       alu_sub_uf;
    alu alu(
            .Operation(alu_op),
            .A(alu_arg_1),
            .B(alu_arg_2),
            .Y(alu_target),
            .Zero(alu_zero),
            .Sub_UF(alu_sub_uf)
        );

    // Instruction Dispatch
    always @(posedge CLK) begin
        unique case (Instruction)
                   ISA_OP_NOP:  begin
                       alu_op = ALU_NO_OP;
                       // it is assumed that target, arg1, and arg2 are zeroed here
                   end
                   ISA_OP_ADD:  begin
                       alu_op = ALU_ADD_OP;
                   end
                   ISA_OP_SUB:  begin
                       alu_op = ALU_SUB_OP;
                   end
                   ISA_OP_MUL:  begin
                       alu_op = ALU_MUL_OP;
                   end
                   ISA_OP_DIV:  begin
                       alu_op = ALU_DIV_OP;
                   end
                   ISA_OP_JMP:  begin
                       alu_op = ALU_NO_OP;
                   end
                   ISA_OP_JEZ:  begin
                       alu_op = ALU_EQ_OP;
                   end
                   ISA_OP_JGZ:  begin
                       alu_op = ALU_GT_OP;
                   end
                   ISA_OP_LADD: begin
                       alu_op = ALU_ADD_OP;
                   end
                   ISA_OP_LSUB: begin
                       alu_op = ALU_SUB_OP;
                   end
                   ISA_OP_LMUL: begin
                       alu_op = ALU_MUL_OP;
                   end
                   ISA_OP_LDIV: begin
                       alu_op = ALU_DIV_OP;
                   end
                   default: begin
                       // only assert after no longer Z
                       if ($time > 0) begin
                           $display("Unreachable case in slice was reached!");
                           $display("Instruction:", Instruction);
                           $finish;
                       end;
                   end
               endcase // case (Instruction)
           end

           // Writeback
           always @(alu_target) begin
               // TODO write alu output to target register
           end

           // Register Read
           always @(Arg1) begin
               // TODO read register to arg1
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

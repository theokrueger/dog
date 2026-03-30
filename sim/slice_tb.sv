module slice_tb;
`include "incl/ISA_Ops.svh"
`include "incl/ALU_Ops.svh"

    logic CLK;

    logic [3:0] inst;
    logic [7:0] target, arg1, arg2, pc_in, pc_out;
    logic [7:0] expt_pc_out;

    task instruct( [3:0] new_instruction, [7:0] target_reg, [7:0] arg_reg, [7:0] arg_reg_or_literal, [7:0] pc_input, [7:0] pc_out_expt, [7:0] target_reg_expected_value);
        begin
            inst <= new_instruction;
            target <= target_reg;
            arg1 <= arg_reg;
            arg2 <= arg_reg_or_literal;
            pc_in <= pc_input;
            expt_pc_out <= pc_out_expt;
            // TODO target reg expected value
        end
    endtask

    slice dut (
              .CLK(CLK),
              .Instruction(inst),
              .Target(target),
              .Arg1(arg1),
              .Arg2(arg2),
              .PC_in(pc_in),
              .PC_out(pc_out)
          );

    task dump();
        $display("[ ERR] Failed slice test case at #%0d", $time);
        $display("  Instruction: %b", inst);
        $display("  Target: %b", target);
        $display("  Arg 1:  %0d", arg1);
        $display("  Arg 2:  %0d", arg2);
        $display("  PC in:  %b", pc_in);

        $display("\n  [Assertion] PC out:");
        $display("    Expected: %b (%0d)", expt_pc_out, expt_pc_out);
        $display("    Got:      %b (%0d)", pc_out, pc_out);

        // TODO target reg expected value

        $finish;
    endtask; // dump

    initial begin
        CLK = 1'b0;
        forever begin
            #0.4 CLK = 0;
            #0.6 CLK= 1;
        end
    end

    always @(negedge CLK)
        if ($time > 1)
        begin
            assert (pc_out == expt_pc_out) else dump();
            // TODO target reg expected value
        end;

    // test cases
    initial
    begin
        $display("[INFO] Testing slice");
        #0 instruct(ALU_NO_OP, 0, 0, 0,
                    0, 1, 0);

        // normal operation
        // nop
        #1 instruct(ALU_NO_OP, 0, 0, 0,
                    0, 1, 0);
        // r1 = 1+2
        #1 instruct(ALU_ADD_OP, 1, 1, 2,
                    55, 56, 3);
        // r1 = 1-2
        #1 instruct(ALU_SUB_OP, 1, 3, 2,
                    69, 70, 1);
        // r1 = 2*3
        #1 instruct(ALU_MUL_OP, 1, 3, 2,
                    69, 70, 6);

        // done
        #1 $display("[PASS] Completed slice Test at %0d",$time);

    end

endmodule // slice_tb


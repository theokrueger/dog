module processor_tb;
`include "incl/ISA_Ops.svh"
`include "incl/ALU_Ops.svh"

    logic clk;
    logic rst;

    logic [9+28*2:0] word;
    logic [7:0] PC;
    logic [7:0] nextPC;
    wire [7:0] reg_state [0:15];

    // expected values for checking
    logic [7:0] exp_nextPC;
    logic [7:0] exp_reg_state [0:15];

    processor #(.N(2)) dut (
        .clk(clk),
        .rst(rst),
        .word(word),
        .PC(PC),
        .nextPC(nextPC),
        .reg_state(reg_state)
    );

    integer i;
    task dump();
        $write("Register state: ");
        for (int i = 0; i < 16; i++) begin
            $write("r%0d=%0d ", i, reg_state[i]);
        end
        $write("\n");

    endtask; // dump

    initial begin
        clk = 1'b0;
        forever begin
            #0.4 clk = 0;
            #0.6 clk = 1;
        end
    end

    // test cases
    initial
    begin

        $display("[INFO] Testing thing");
        rst <= 1;
        word = {ALU_ADD_IM_OP, 8'b0, 8'b1101, 8'b1, ALU_NO_OP, 8'b0, 8'b0, 8'b0, 2'b00, 8'b0};
        @(posedge clk);
        dump();
        rst <= 0;
        word = {ALU_ADD_IM_OP, 8'b0, 8'b1101, 8'b1, ALU_NO_OP, 8'b0, 8'b0, 8'b0, 2'b00, 8'b0};
        @(posedge clk);
        #1;
        dump();
        $finish;
        // #0 instruct(ALU_NO_OP, 0, 0, 0,
        //             0, 1, 0);

        // // normal operation
        // // nop
        // #1 instruct(ALU_NO_OP, 0, 0, 0,
        //             0, 1, 0);
        // // r1 = 1+2
        // #1 instruct(ALU_ADD_OP, 1, 1, 2,
        //             55, 56, 3);
        // // r1 = 1-2
        // #1 instruct(ALU_SUB_OP, 1, 3, 2,
        //             69, 70, 1);
        // // r1 = 2*3
        // #1 instruct(ALU_MUL_OP, 1, 3, 2,
        //             69, 70, 6);

        // // done
        #1 $display("[PASS] Completed slice Test at %0d",$time);

    end

endmodule // slice_tb


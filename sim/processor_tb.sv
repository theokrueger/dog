module processor_tb;
`include "incl/ISA_Ops.svh"
`include "incl/ALU_Ops.svh"

    localparam regs = 32;
    localparam  reg_bits = $clog2(regs);
    localparam   n = 2;

    logic clk;
    logic rst;

    logic [10+28*n:0] word;
    logic [7:0] PC;
    logic [7:0] nextPC;
    wire [7:0] reg_state [regs];

    // expected values for checking
    logic [7:0] exp_nextPC;
    logic [7:0] exp_reg_state [regs];

    processor #(.N(n), .Regs(regs)) dut (
                  .clk(clk),
                  .rst(rst),
                  .word(word),
                  .PC(PC),
                  .nextPC(nextPC),
                  .reg_state(reg_state)
              );

    integer i, j;
    task dump();
        $display("[ ERR] Failure in processor test case at #%0d", $time);
        $display("  Register state: ");
        for (int i = 0; i < regs; i++) begin
            $display("    r%0d=%0d ", i, reg_state[i]);
        end
        $write("\n");
        $finish;

    endtask; // dump

    task assert_correct(input logic [127:0] arr, pc);
        for (int i=0; i<16; i++) begin
            assert (arr[8*i +: 8] == reg_state[i]);
            else begin
                // $write("expected: ");
                // for (int i = 0; i < 16; i++) begin
                //     $write("r%0d=%0d ", i, arr[8*i +: 8]);
                // end
                // $write("\n");
                dump();
            end
        end
        // assert (pc == nextPC) else begin
        //     $display("bad pc real %d expected %d", nextPC, pc);
        //     $write("expected: ");
        //     for (int i = 0; i < 16; i++) begin
        //         $write("r%0d=%0d ", i, arr[8*i +: 8]);
        //     end
        //     $write("\n");
        //     dump();
        // end
    endtask
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

        $display("[INFO] Testing processor");
        rst <= 1;
        word = {ALU_ADD_IM_OP, 8'b0, 8'b1101, 8'b1, ALU_NO_OP, 8'b0, 8'b0, 8'b0, 3'b0, 8'b0};
        @(posedge clk);
        // #1;
        // assert_correct({8'b0, 8'b0, 8'b0, 8'b0, 8'b0, 8'b0, 8'b0, 8'b0, 8'b0, 8'b0, 8'b0, 8'b0, 8'b0, 8'b0, 8'b0, 8'b0});
        rst <= 0;
        // source1 source2 dest
        //
        word = {ALU_ADD_IM_OP, 8'b0, 8'b1101, 8'b1, ALU_NO_OP, 8'b0, 8'b0, 8'b0, 3'b0, 8'b0};
        @(posedge clk);
        #1;
        assert_correct({8'b0, 8'd0, 8'b0, 8'b0, 8'b0, 8'b0, 8'b0, 8'b0, 8'b0, 8'b0, 8'b0, 8'b0, 8'b0, 8'b0, 8'd13, 8'b0}, 1);

        word = {ALU_ADD_IM_OP, 8'b0, 8'd13, 8'd2, ALU_NO_OP, 8'b0, 8'b0, 8'b0, 3'b0, 8'b0};
        @(posedge clk);
        #1;
        // // done
        #1 $display("[PASS] Completed slice Test at %0d",$time);

    end

endmodule // slice_tb


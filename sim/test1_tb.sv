
module test1_tb;
`include "incl/ISA_Ops.svh"
`include "incl/ALU_Ops.svh"

    localparam regs = 8;
    localparam  reg_bits = $clog2(regs);
    localparam   n = 4;

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

    integer i;
    task dump();
        $write("  registers: ");
        for (int i = 0; i < regs; i++) begin
            $write("    r%0d=%0d ", i, reg_state[i]);
        end
        $write("\n");
    endtask; // dump
    task fail(input logic [8*regs-1:0] arr, pc);
        $display("[ ERR] Failure in processor test case at #%0d", $time);
        $display("  pc real %d expected %d", nextPC, pc);
        $write("  expected: ");
        for (int i = 0; i < regs; i++) begin
            $write("    r%0d=%0d ", i, arr[8*i +: 8]);
        end
        $write("\n");
        dump();
        $finish;
    endtask
    task assert_correct(input logic [8*regs-1:0] arr, pc);
        for (int i=0; i<regs; i++) begin
            assert (arr[8*i +: 8] == reg_state[i]) else fail(arr, pc);
        end
        assert (pc == nextPC) else fail(arr, pc);
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

        $display("[INFO] Testing processor test1");
        rst <= 1;
        PC <= 0;
        word = '0;
        @(posedge clk);
        #1;
        assert_correct('0, 1);
        rst <= 0;

word = 'b101100000000111010000000000110110000000000000010000000101011000000001110010000000011000000000000000000000000000010000000101;
PC = 'd0;
@(posedge clk);
#1;
assert_correct('d0, 5);

word = 'b100100000011000000100000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000001;
PC = 'd5;
@(posedge clk);
#1;
assert_correct('d0, 1);

word = 'b101100000010000000000000010010110000001000000001000001011011000000100000001000000110101100000010000000110000011100000000000;
PC = 'd1;
@(posedge clk);
#1;
assert_correct('d0, 2);

word = 'b101000000001000001000000010010100000000100000101000001011010000000010000011000000110101000000001000001110000011100000000000;
PC = 'd2;
@(posedge clk);
#1;
assert_correct('d0, 3);

word = 'b001100000111000001000000010000110000011000000101000001010000000000000000000000000000000000000000000000000000000000000000000;
PC = 'd3;
@(posedge clk);
#1;
assert_correct('d0, 4);

word = 'b001100000101000001000000010010110000001000000100000000100000000000000000000000000000000000000000000000000000000001100000111;
PC = 'd4;
@(posedge clk);
#1;
assert_correct('d0, 7);

word = 'b101100000000000000010000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
PC = 'd7;
@(posedge clk);
#1;
assert_correct('d0, 8);

    end
endmodule


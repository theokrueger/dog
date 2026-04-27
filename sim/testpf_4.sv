

module testpf4_tb;
    localparam regs = 8;
    localparam  reg_bits = $clog2(regs);
    localparam   n = 4;

    logic clk;
    logic rst;

    logic [10+28*n:0] word;
    logic [7:0] PC;
    logic [7:0] nextPC;
    wire [8*regs-1:0] reg_state;

    wire [(10+28*n)*8-1:0] prog;
    assign prog = {
123'b101100000000000000010000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
123'b101100000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000010000001000,
123'b100100000011000000100000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000001,
123'b001100000101000001000000010010110000001000000100000000100000000000000000000000000000000000000000000000000000000001100000111,
123'b001100000111000001000000010000110000011000000101000001010000000000000000000000000000000000000000000000000000000000000000000,
123'b101000000001000001000000010010100000000100000101000001011010000000010000011000000110101000000001000001110000011100000000000,
123'b101100000010000000000000010010110000001000000001000001011011000000100000001000000110101100000010000000110000011100000000000,
123'b101100000000111010010000000110110000000000000010000000101011000000001110010100000011000000000000000000000000000010000000101
    };
    

    processor #(.N(n), .Regs(regs)) dut (
                  .CLK(clk),
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
            $write("    r%0d=%0d ", i, reg_state[8*i +: 8]);
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
            assert (arr[8*i +: 8] == reg_state[8*i +: 8]) else fail(arr, pc);
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
        #0.7
        assert_correct('0, 0);
        rst <= 0;

        while (nextPC != 8) begin
          PC = nextPC;
          word = prog[123*PC +: 123];
          @(posedge clk);
          #1;
        end

        dump();
        $display("[PASS] Completed test1 test at %0d",$time);
        $finish;
    end
endmodule


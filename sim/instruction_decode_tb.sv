`define die(message) begin $display($sformatf message); $stop; end

module instruction_decode_tb;

  reg [9+28:0] word1;
  wire [4-1:0] ops1;
  wire [8-1:0] As1, Bs1, Cs1;

  wire [1:0] branchop1;
  wire [7:0] branchaddr1;
  instruction_decode #(.N(1)) i1 (.word(word1), .ops(ops1), .As(As1), .Bs(Bs1), .Cs(Cs1), .branchop(branchop1), .branchaddr(branchaddr1));

  reg [9+28*2:0] word2;
  wire [2*4-1:0] ops2;
  wire [2*8-1:0] As2, Bs2, Cs2;

  wire [1:0] branchop2;
  wire [7:0] branchaddr2;
  instruction_decode #(.N(2)) i2 (.word(word2), .ops(ops2), .As(As2), .Bs(Bs2), .Cs(Cs2), .branchop(branchop2), .branchaddr(branchaddr2));

  initial begin
    // try to extract values when N=1
    word1 = 38'b11110000000000000000000000000000000000;
    #1 assert (ops1 == 4'b1111) else `die(("no op1 %b %b %b %b %b %b", ops1, As1, Bs1, Cs1, branchop1, branchaddr1));

    word1 = 38'b00001111111100000000000000000000000000;
    #1 assert (As1 == 8'b11111111) else `die(("no a1 %b %b %b %b %b %b", ops1, As1, Bs1, Cs1, branchop1, branchaddr1));

    word1 = 38'b00000000000011111111000000000000000000;
    #1 assert (Bs1 == 8'b11111111) else `die(("no b1 %b %b %b %b %b %b", ops1, As1, Bs1, Cs1, branchop1, branchaddr1));

    word1 = 38'b00000000000000000000111111110000000000;
    #1 assert (Cs1 == 8'b11111111) else `die(("no c1 %b %b %b %b %b %b", ops1, As1, Bs1, Cs1, branchop1, branchaddr1));

    word1 = 38'b1100000000;
    #1 assert (branchop1 == 2'b11) else `die(("no bo1 %b %b %b %b %b %b", ops1, As1, Bs1, Cs1, branchop1, branchaddr1));

    word1 = 38'b11111111;
    #1 assert (branchaddr1 == 8'b11111111) else `die(("no ba1 %b %b %b %b %b %b", ops1, As1, Bs1, Cs1, branchop1, branchaddr1));

    // try to extract values when N=2
    word2 = 76'b111100000000000000000000000000000000000000000000000000000000000000;
    #1 assert (ops2[4+:4] == 4'b1111) else `die(("no op2 %b %b %b %b %b %b", ops2, As2, Bs2, Cs2, branchop2, branchaddr2));

    word2 = 76'b000000000000000000000000000011110000000000000000000000000000000000;
    #1 assert (ops2[0+:4] == 4'b1111) else `die(("no op2 %b %b %b %b %b %b", ops2, As2, Bs2, Cs2, branchop2, branchaddr2));

    word2 = 76'b000011111111000000000000000000000000000000000000000000000000000000;
    #1 assert (As2[8+:8] == 8'b11111111) else `die(("no as2 %b %b %b %b %b %b", ops2, As2, Bs2, Cs2, branchop2, branchaddr2));

    word2 = 76'b000000000000000000000000000000001111111100000000000000000000000000;
    #1 assert (As2[0+:8] == 8'b11111111) else `die(("no as2 %b %b %b %b %b %b", ops2, As2, Bs2, Cs2, branchop2, branchaddr2));

    word2 = 76'b000000000000111111110000000000000000000000000000000000000000000000;
    #1 assert (Bs2[8+:8] == 8'b11111111) else `die(("no bs2 %b %b %b %b %b %b", ops2, As2, Bs2, Cs2, branchop2, branchaddr2));

    word2 = 76'b000000000000000000000000000000000000000011111111000000000000000000;
    #1 assert (Bs2[0+:8] == 8'b11111111) else `die(("no bs2 %b %b %b %b %b %b", ops2, As2, Bs2, Cs2, branchop2, branchaddr2));

    word2 = 76'b000000000000000000001111111100000000000000000000000000000000000000;
    #1 assert (Cs2[8+:8] == 8'b11111111) else `die(("no cs2 %b %b %b %b %b %b", ops2, As2, Bs2, Cs2, branchop2, branchaddr2));

    word2 = 76'b000000000000000000000000000000000000000000000000111111110000000000;
    #1 assert (Cs2[0+:8] == 8'b11111111) else `die(("no cs2 %b %b %b %b %b %b", ops2, As2, Bs2, Cs2, branchop2, branchaddr2));

    word2 = 76'b1100000000;
    #1 assert (branchop2 == 2'b11) else `die(("no bo1 %b %b %b %b %b %b", ops2, As2, Bs2, Cs2, branchop2, branchaddr2));

    word2 = 76'b11111111;
    #1 assert (branchaddr2 == 8'b11111111) else `die(("no ba1 %b %b %b %b %b %b", ops2, As2, Bs2, Cs2, branchop2, branchaddr2));
  end

endmodule

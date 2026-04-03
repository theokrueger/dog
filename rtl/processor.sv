module processor #(parameter N=4, parameter Regs=16) (
  input wire clk,
  input [9+20*N:0] word,
  output [7:0] PC
);

  wire [N*4-1:0] ops;
  wire [N*8-1:0] As, Bs, Cs;
  instruction_decode #(.N(N)) decode (.word(word), .ops(ops), .As(As), .Bs(Bs), .Cs(Cs), .branchop(branchop), .branchaddr(branchaddr));

  genvar i;
  generate
    for (i=0; i<N; i=i+1) begin
      slice #(.N(N)) s (.CLK(clk), .Instruction(ops[4*i +: 4]), .Target(Cs[8*i +: 8]), .Arg1(As[8*i +: 8]), .Arg2(Bs[8*i +: 8]), .PC_in(PC), .PC_out(PC));
    end
  endgenerate

endmodule



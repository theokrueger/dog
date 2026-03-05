
module processor #(parameter N=4) (
  input wire clk,
  input [9+20*N:0] word
);

  wire [N*4-1:0] ops;
  wire [N*8-1:0] As, Bs;

  wire [1:0] branchop;
  wire [7:0] branchaddr;

  instruction_decode #(.N(N)) decode (.word(word), .ops(ops), .As(As), .Bs(Bs), .branchop(branchop), .branchaddr(branchaddr));

  always @(posedge clk) begin
  
  end

endmodule



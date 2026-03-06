module instruction_decode #(parameter N=4) (
  input [9+28*N:0] word,

  output [N*4-1:0] ops,
  output [N*8-1:0] As, Bs, Cs,

  output [1:0] branchop,
  output [7:0] branchaddr
);

  assign branchaddr = word[7:0];
  assign branchop = word[9:8];

  genvar i;
  generate
    for (i=0; i<N; i=i+1) begin
      assign Cs[8*i +: 8] = word[10+28*i +: 8];
      assign Bs[8*i +: 8] = word[18+28*i +: 8];
      assign As[8*i +: 8] = word[26+28*i +: 8];
      assign ops[4*i +: 4] = word[34+28*i +: 4];
    end
  endgenerate
endmodule // instruction_decode

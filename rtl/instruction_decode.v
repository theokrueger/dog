module instruction_decode #(parameter N=4) (
  input [9+12*N:0] word,

  output [N*4-1:0] ops,
  output [N*8-1:0] As,
  output [N*8-1:0] Bs,

  //this should be dynamically generated
  output [1:0] branchop,
  output [7:0] branchaddr

  
);
  
  

  

endmodule


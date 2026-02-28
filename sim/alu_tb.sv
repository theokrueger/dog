// TODO sim MUL and DIV
module alu_tb;
`include "incl/ALU_Ops.svh"

  // the ALU
  reg [3:0] Op;
  reg [7:0] A;
  reg [7:0] B;
  output [7:0] Y;
  output       Zero;
  reg [7:0]   expt;

  alu dut (
        .Operation(Op),
        .A(A),
        .B(B),
        .Y(Y),
        .Zero(Zero)
      );


  always
    #2  assert (Y == expt) else
       begin
         $display("Failed ALU test case from %d", $time-2);
         $display("Output: %b", Y);
         $stop;
       end;

  // test cases
  initial
    begin
      #0
       Op = 8'b0;
      A=8'b0;
      B=8'b0;
      expt = 8'b0;

      // normal operation
      #2
       Op = ALU_ADD_OP;
      A = 'b00000001;
      B = 'b00000001;
      expt = 'b00000010;

      #4
       Op = ALU_SUB_OP;
      A = 'b00001000;
      B = 'b00000010;
      expt = 'b00000110;

      #6
       Op = ALU_AND_OP;
      A =    'b11001100;
      B =    'b01010101;
      expt = 'b01000100;

      #7
       Op = ALU_AND_OP;
      A =    'b11001100;
      B =    'b01010101;
      expt = 'b01000100;

      // overflow/underflow

      // done
      #200
       begin
         $display("Completed ALU Test at %d",$time);
         $finish;
       end
     end

 endmodule // alu_tb

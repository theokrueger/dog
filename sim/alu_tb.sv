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
  reg [7:0]  lastexpt;

  alu dut (
        .Operation(Op),
        .A(A),
        .B(B),
        .Y(Y),
        .Zero(Zero)
      );


  // check
  always @(expt)
    assert (Y == expt) else
             begin
               $display("Failed ALU test case from %d", $time);
               $display("Op: %b", Op);
               $display("A: %b", A);
               $display("B: %b", B);
               $display("Y: %b", Y);
               $display("Expected: %b", expt);
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
      #1
       Op = ALU_ADD_OP;
      A = 'b00000001;
      B = 'b00000001;
      expt = 'b00000010;

      #2
       Op = ALU_SUB_OP;
      A = 'b00001000;
      B = 'b00000010;
      expt = 'b00000110;

      #3
       Op = ALU_AND_OP;
      A =    'b11001100;
      B =    'b01010101;
      expt = 'b01000100;

      #4
       Op = ALU_OR_OP;
      A =    'b11001100;
      B =    'b01110101;
      expt = 'b11111101;

      #5
       Op =ALU_EQ_OP;
      A = 8'b101;
      B = 8'b101;
      expt = 8'b1;

      #6
       Op = ALU_EQ_OP;
      A = 8'b001;
      //B = 8'b101;
      expt = 8'b0;

      #7
       Op =ALU_GT_OP;
      A = 8'b001;
      B = 8'b101;
      expt = 8'b0;

      #8
       Op = ALU_GT_OP;
      A = 8'b1000;
      B = 8'b0101;
      expt = 8'b1;

      #9
       Op = ALU_GT_OP;
      A = 8'b101;
      B = 8'b101;
      expt = 8'b0;

      #10
       Op =ALU_GTE_OP;
      A = 8'b101;
      B = 8'b101;
      expt = 8'b1;

      #11
       Op = ALU_GTE_OP;
      A = 8'b1000;
      B = 8'b0101;
      expt = 8'b1;

      #12
       Op = ALU_GTE_OP;
      A = 8'b001;
      B = 8'b101;
      expt = 8'b0;



      // overflow/underflow

      // done
      #200
       begin
         $display("Completed ALU Test at %d",$time);
         $finish;
       end
     end

 endmodule // alu_tb

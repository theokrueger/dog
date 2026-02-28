// TODO sim MUL and DIV
module alu_tb;
`include "incl/ALU_Ops.svh"

  // the ALU
  reg [3:0] Op;
  reg [7:0] A;
  reg [7:0] B;
  output [7:0] Y;
  output       Zero;

  alu dut (
        .Operation(Op),
        .A(A),
        .B(B),
        .Y(Y),
        .Zero(Zero)
      );

  // clock
  reg clk;
  always
    #1 clk = ~clk;   // Generate clock

  // test infra
  struct {
      string name;
      bit [3:0] op;
      bit [7:0] a;
      bit [7:0] b;
      bit [7:0] expt;
    } test;

  task clear;
    begin
      Op = 8'b0;
      A=8'b0;
      B=8'b0;
      Y_Expect = 8'b0;
      test = {"none", b0, b0, b0, b0};
    end
  endtask // clear

  task check;
    begin
      if (Y == Y_Expect)
        begin
        end
      else
        begin
          $display("Failed ALU test case %s", test.name);
          $stop;


        end
    end
  endtask // check


  // test cases
  initial
    begin
      #0 clear;

      #25
       begin
         $display("Completed ALU Test at %d",$time);
         $finish;
       end
     end

 endmodule // alu_tb

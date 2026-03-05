// TODO sim MUL and DIV
module alu_tb;
`include "incl/ALU_Ops.svh"

    // the ALU
    reg [3:0] Op;
    reg [7:0] A;
    reg [7:0] B;
    output [7:0] Y;
    output        Zero, Sub_UF;
    reg [7:0]    expt;

    alu dut (
            .Operation(Op),
            .A(A),
            .B(B),
            .Y(Y),
            .Zero(Zero),
            .Sub_UF(Sub_UF)
        );

    task dump();
        $display("Failed ALU test case from %d", $time);
        $display("Op: %b", Op);
        $display("A: %b", A);
        $display("B: %b", B);
        $display("Y: %b", Y);
        $display("Zero: %b", Zero);
        $display("Sub_UF: %b", Sub_UF);
        $display("Expected: %b", expt);
        $finish;
    endtask;

    // check
    always @(expt)
        assert (Y == expt) else dump();
    always @(Sub_UF)
    begin
        if (Op == ALU_SUB_OP) begin
            if (A >= B) begin
                assert(Sub_UF == 'b0) else dump();
            end
            else
                assert(Sub_UF == 'b1) else
                      begin
                          $display("Expected sub underflow flag!",);
                          dump();
                      end;

        end
        else
            assert(Sub_UF == 'b0) else dump();
    end;


    // test cases
    initial
    begin
        #0
         begin
             Op = 8'b0;
             A=8'b0;
             B=8'b0;
             expt = 8'b0;
         end;


        // normal operation
        #1
         begin
             Op = ALU_ADD_OP;
             A = 'b00000001;
             B = 'b00000001;
             expt = 'b00000010;
         end;

        #2
         begin
             Op = ALU_SUB_OP;
             A = 'b00001000;
             B = 'b00000010;
             expt = 'b00000110;
         end;

        #3
         begin
             Op = ALU_AND_OP;
             A =    'b11001100;
             B =    'b01010101;
             expt = 'b01000100;
         end;

        #4
         begin
             Op = ALU_OR_OP;
             A =    'b11001100;
             B =    'b01110101;
             expt = 'b11111101;
         end;

        #5
         begin
             Op =ALU_EQ_OP;
             A = 8'b101;
             B = 8'b101;
             expt = 8'b1;
         end;

        #6
         begin
             Op = ALU_EQ_OP;
             A = 8'b001;
             //B = 8'b101;
             expt = 8'b0;
         end;

        #7
         begin
             Op =ALU_GT_OP;
             A = 8'b001;
             B = 8'b101;
             expt = 8'b0;
         end;

        #8
         begin
             Op = ALU_GT_OP;
             A = 8'b1000;
             B = 8'b0101;
             expt = 8'b1;
         end;

        #9
         begin
             Op = ALU_GT_OP;
             A = 8'b101;
             B = 8'b101;
             expt = 8'b0;
         end;

        #10
         begin
             Op =ALU_GTE_OP;
             A = 8'b101;
             B = 8'b101;
             expt = 8'b1;
         end;

        #11
         begin
             Op = ALU_GTE_OP;
             A = 8'b1000;
             B = 8'b0101;
             expt = 8'b1;
         end;

        #12
         begin
             Op = ALU_GTE_OP;
             A = 8'b001;
             B = 8'b101;
             expt = 8'b0;
         end;

        // overflow/underflow
        #100
         begin
             Op = ALU_ADD_OP;
             A = 'b11111111;
             B = 'b00000001;
             expt = 'b00000000; // TODO is overflow intended?
         end;

        #101
         begin
             Op = ALU_SUB_OP;
             A = 'b0;
             B = 'b1;
             expt = 'b11111111;
         end;

        #102
         begin
             Op = ALU_SUB_OP;
             A = 'b0;
             B = 'b10;
             expt = 'b11111110;
         end;

        // done
        #200
         begin
             $display("Completed ALU Test at %d",$time);
         end;

    end

endmodule // alu_tb

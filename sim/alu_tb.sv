// TODO sim MUL and DIV
module alu_tb;
`include "incl/ALU_Ops.svh"

    // the ALU
    logic CLK;
    logic [3:0] Op;
    logic [7:0] A;
    logic [7:0] B;
    output logic [7:0] Y;
    output logic   Zero, Sub_UF;
    logic [7:0]    expt;

    alu dut (
            .CLK(CLK),
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
    endtask; // dump

    initial begin
        CLK = 1'b0;
        forever begin
           #0.4 CLK = 0;
           #0.6 CLK = 1;
        end
    end


    // check
    always @(negedge CLK)
      if ($time > 1)
        assert (Y == expt) else dump();


    // test cases
    initial
    begin
        #0
         begin
             Op <= 8'b0;
             A<=8'b0;
             B<=8'b0;
             expt <= 8'b0;
         end;


        // normal operation
        #1
         begin
             Op <= ALU_ADD_OP;
             A <= 'b00000001;
             B <= 'b00000001;
             expt <= 'b00000010;
         end;

        #1
         begin
             Op <= ALU_SUB_OP;
             A <= 'b00001000;
             B <= 'b00000010;
             expt <= 'b00000110;
         end;

        #1
         begin
             Op <= ALU_AND_OP;
             A <=    'b11001100;
             B <=    'b01010101;
             expt <= 'b01000100;
         end;

        #1
         begin
             Op <= ALU_OR_OP;
             A <=    'b11001100;
             B <=    'b01110101;
             expt <= 'b11111101;
         end;

        #1
         begin
             Op <=ALU_EQ_OP;
             A <= 8'b101;
             B <= 8'b101;
             expt <= 8'b1;
         end;

        #1
         begin
             Op <= ALU_EQ_OP;
             A <= 8'b001;
             B <= 8'b101;
             expt <= 8'b0;
         end;

        #1
         begin
             Op <=ALU_GT_OP;
             A <= 8'b001;
             B <= 8'b101;
             expt <= 8'b0;
         end;

        #1
         begin
             Op <= ALU_GT_OP;
             A <= 8'b1000;
             B <= 8'b0101;
             expt <= 8'b1;
         end;

        #1
         begin
             Op <= ALU_GT_OP;
             A <= 8'b101;
             B <= 8'b101;
             expt <= 8'b0;
         end;

        #1
         begin
             Op <=ALU_GTE_OP;
             A <= 8'b101;
             B <= 8'b101;
             expt <= 8'b1;
         end;

        #1
         begin
             Op <= ALU_GTE_OP;
             A <= 8'b1000;
             B <= 8'b0101;
             expt <= 8'b1;
         end;

        #1
         begin
             Op <= ALU_GTE_OP;
             A <= 8'b001;
             B <= 8'b101;
             expt <= 8'b0;
         end;

        // overflow/underflow
        #1
         begin
             Op <= ALU_ADD_OP;
             A <= 'b11111111;
             B <= 'b00000001;
             expt <= 'b00000000; // TODO is overflow intended?
         end;

        #1
         begin
             Op <= ALU_SUB_OP;
             A <= 'b0;
             B <= 'b1;
             expt <= 'b11111111;
         end;

        #1
         begin
             Op <= ALU_SUB_OP;
             A <= 'b0;
             B <= 'b10;
             expt <= 'b11111110;
         end;

        // done
        #1
         begin
             $display("Completed ALU Test at %d",$time);
         end;

    end

endmodule // alu_tb

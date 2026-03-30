module branch_unit_tb;
`include "incl/Branch_Ops.svh"

    // the branch unit
    logic CLK;
    logic [2:0] Op;
    logic [7:0] Addr;
    logic [7:0] PC;
    logic       Zero, Sub_UF;
    output [7:0] PC_out;
    logic [7:0]     expt;

    branch_unit dut (
                    .CLK(CLK),
                    .Operation(Op),
                    .Address(Addr),
                    .PC(PC),
                    .Zero(Zero),
                    .Sub_UF(Sub_UF),
                    .PC_out(PC_out)
                );

    task dump();
        $display("Failed branch_unit test case at %d", $time);
        $display("Op: %b", Op);
        $display("Addr: %b", Addr);
        $display("PC: %b", PC);
        $display("Zero: %b", Zero);
        $display("Sub_UF: %b", Sub_UF);
        $display("PC_out: %b", PC_out);
        $display("Expt: %b", expt);
        $finish;
    endtask; // dump

    initial begin
        CLK = 1'b0;
        forever begin
            #0.4 CLK = 0;
            #0.6 CLK = 1;
        end
    end

    always @(negedge CLK)
        if ($time > 1)
            assert (PC_out == expt) else dump();

    // test cases
    initial
    begin
        #0
         begin
             Op <= BRANCH_NO_OP;
             Addr<=8'b0;
             PC<=8'b0;
             Zero <= 'b0;
             Sub_UF <= 'b0;
             expt <= 8'b01;
         end;


        // normal operation
        #1
         begin
             Op <= BRANCH_ZERO_OP;
             Addr<=8'b0;
             Zero <= 'b0;
             Sub_UF <= 'b0;
             PC<=8'b01;
             expt <= 8'b10;
         end;
        #1
         begin
             Op <= BRANCH_ZERO_OP;
             Addr<=8'b1111;
             PC<=8'b11110000;
             Zero <= 'b1;
             Sub_UF <= 'b0;
             expt <= 8'b1111;
         end;

        #1
         begin
             Op <= BRANCH_NOTZERO_OP;
             Addr<=8'b1111;
             PC<=8'b11110001;
             Zero <= 'b1;
             Sub_UF <= 'b0;
             expt <= 8'b11110010;
         end;

        #1
         begin
             Op <= BRANCH_NOTZERO_OP;
             Addr<=8'b1111;
             PC<=8'b11110000;
             Zero <= 'b0;
             Sub_UF <= 'b0;
             expt <= 8'b1111;
         end;

        #1
         begin
             Op <= BRANCH_SUBOVERFLOW_OP;
             Addr<=8'b10101;
             PC<=8'b11110000;
             Zero <= 'b0;
             Sub_UF <= 'b1;
             expt <= 8'b10101;
         end;

        #1
         begin
             Op <= BRANCH_SUBOVERFLOW_OP;
             Addr<=8'b10111;
             PC<=8'b11110000;
             Zero <= 'b0;
             Sub_UF <= 'b0;
             expt <= 8'b11110001;
         end;


        // done
        #1
         begin
             $display("Completed branch_unit Test at %d",$time);
         end;

    end

endmodule // branch_unit_tb


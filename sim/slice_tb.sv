module slice_tb;
`include "incl/ISA_Ops.svh"

    reg CLK;

    slice dut (
                );

    task dump();
        $display("Failed slice test case from %d", $time);

        $finish;
    endtask; // dump

    initial begin
        CLK = 1'b0;
        forever begin
            #0.5 CLK = ~CLK;
        end
    end

    // always @(posedge CLK)
    //     assert (PC_out == expt) else dump();

    // test cases
    initial
    begin
        #0
         begin
         end;


        // normal operation
        #1
         begin

         end;

        // done
        #1
         begin
             $display("Completed slice Test at %d",$time);
         end;

    end

endmodule // slice_tb


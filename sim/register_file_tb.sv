module register_file_tb;
    logic CLK;

    register_file dut (
          );

    task dump();
        $display("[ ERR] Failed register_file test case at #%0d", $time);

        $finish;
    endtask; // dump

    initial begin
        CLK = 1'b0;
        forever begin
            #0.4 CLK = 0;
            #0.6 CLK= 1;
        end
    end

    always @(negedge CLK)
        if ($time > 1)
        begin
            //assert (pc_out == expt_pc_out) else dump();
        end;

    // test cases
    initial
      begin
         $display("[INFO] Testing register file");
        #0

        // normal operation
        #1

        // done
        #1 $display("[PASS] Completed register_file Test at %0d",$time);

    end

endmodule // register_file_tb


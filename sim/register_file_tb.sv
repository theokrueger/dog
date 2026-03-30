module register_file_tb;
    logic CLK;

    logic [3:0] d1_sel[2];
    logic [7:0] d1_data[2];
    logic [7:0] d1_expt;
    register_file #(2,5) dut1 (
                      .CLK(CLK),
                      .Reg_Selector(d1_sel),
                      .Data_Bus(d1_data)
                  );

    task test1([3:0] sel, [7:0] data, [7:0] expt);
        begin
            d1_sel[0] = sel;
            if (sel[7] == 1)
                d1_data[0] = data;
            else
                d1_data[0] = 'z;
            d1_expt = expt;
        end
    endtask

    task dump1();
        $display("[ ERR] Failed register_file no.1 test case at #%0d", $time);
        $display("  (0,0):");
        if (d1_sel[0][7] == 1)
            $display("    (Write)");
        $display("    Reg:  %0d", d1_sel[0]);
        $display("    Got:  %0d", d1_data[0]);
        $display("    Want: %0d", d1_expt);


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
            assert (d1_sel[0][7] == 1 || d1_data[0] == d1_expt) else dump1();
        end;

    // test cases
    initial
    begin
        $display("[INFO] Testing register file");
        #0 begin
             d1_sel[0] = '0;
             d1_data[0] = '0;
             d1_expt = '0;
         end;
        // normal operation
        #1 test1(8'b10000001, 12, 'x);
        #1 test1(8'b10000001, 'x, 12);

        // done
        #1 begin
             d1_sel[0] = '0;
             d1_data[0] = '0;
             d1_expt = '0;
         end;
        $display("[PASS] Completed register_file Test at %0d",$time);

    end

endmodule // register_file_tb


module register_file_tb;
    logic CLK;

    logic [3:0] d1_sel[2];
    logic [7:0] d1_data[2];
    logic [7:0] d1_expt;
    logic        check;
    register_file #(2,5) dut1 (
                      .CLK(CLK),
                      .Reg_Selector(d1_sel),
                      .Data_Bus(d1_data)
                  );

    task test1_r([3:0] sel, [7:0] expt);
        begin
            d1_sel[0] = sel;
            d1_expt = expt;
            check = 1;
        end
    endtask // test1_r

    task test1_w([3:0] sel, [7:0] data);
        begin
            d1_sel[0] = sel;
            d1_data[0] = data;
        end
    endtask // test1_w

    task dump1();
        $display("[ ERR] Failed register_file no.1 test case at #%0d", $time);
        $display("  Slice 0:");
        $display("    Reg:  %0d", d1_sel[0]);
        $display("    Got:  %0d", d1_data[0]);
        $display("    Want: %0d", d1_expt);


        //$finish;
    endtask; // dump

    initial begin
        CLK = 1'b0;
        forever begin
            #0.4 CLK = 0;
            #0.6 CLK= 1;
        end
    end

    always @(negedge CLK)
        if (check == 1'b1) begin
            assert (d1_data[0] == d1_expt) else dump1();
            check = 1'b0;
        end

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
        #1 test1_w(8'b10000010, 12);
        #1 test1_r(8'b00000010, 12);
        #1 test1_r(8'b00000010, 12);
        #1 test1_w(8'b10000011, 13);
        #1 test1_r(8'b00000011, 13);
        #1 test1_r(8'b00000010, 12);
        #1 test1_r(8'b00000010, 12); // TODO wtf going on
        #1 test1_r(8'b00000001, 12);

        // done
        #2 begin
             d1_sel[0] = '0;
             d1_data[0] = '0;
             d1_expt = '0;
         end;
        $display("[PASS] Completed register_file Test at %0d",$time);

    end

endmodule // register_file_tb


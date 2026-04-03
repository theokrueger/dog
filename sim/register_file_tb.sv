module register_file_tb;
    logic CLK;

    logic [3:0] d1_sel[2];
    logic [8*2-1:0]  d1_data;
    tri [8*2-1:0]     d1_data_bus;

    assign d1_data_bus = (d1_sel[0][3] == 1) ? d1_data : 'z;
    always @(negedge CLK) begin
        if (d1_sel[0][3] == 0)
            d1_data <= d1_data_bus;
    end

    logic [7:0] d1_expt;
    logic        check;


    register_file #(2,5) dut1 ( // 2 EU, 5 reg
                      .CLK(CLK),
                      .Reg_Selector(d1_sel),
                      .Data_Bus(d1_data_bus)
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
            d1_data = {8'b0, data};
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
            assert (d1_data[7:0] == d1_expt) else dump1();
            check = 1'b0;
        end

    // test cases
    initial
    begin
        $display("[INFO] Testing register file");
        #0 begin
             d1_sel[0] = '0;
             d1_sel[1] = '0;
             d1_data = '0;
             d1_expt = '0;
         end;
        // normal operation
        // #1 test1_w(4'b1010, 12); // write 12 to 2
        // #1 test1_r(4'b0010, 12); // read 12 from 2
        // #1 test1_r(4'b0010, 12); // read 12 from 2
        // #1 test1_w(4'b1011, 13); // write 13 to 3
        // #1 test1_r(4'b0011, 13); // read 13 from 3
        // #1 test1_w(4'b1001, 15); // write 15 to 1
        // #1 test1_r(4'b0010, 12); // still read 12 from 2 (#7)
        // #1 test1_r(4'b0010, 12); // still read 12 from 2 (#8)

        #1 test1_w(4'b1010, 67);
        #1 test1_w(4'b1011, 68);
        #1 test1_r(4'b0010, 67);
        #1 test1_r(4'b0010, 67);

        // done
        #2 begin
             d1_sel[0] = '0;
             d1_data[0] = '0;
             d1_expt = '0;
             $finish;

         end;
        $display("[PASS] Completed register_file Test at %0d",$time);

    end

endmodule // register_file_tb


module register_file_tb;

    logic clk;
    logic rst;
    wire [7:0] regs_out [0:15];
    logic [7:0] write_data [0:2-1];
    logic [3:0] write_sel [0:2-1];
    register_file #(2) dut (.clk(clk), .rst(rst), .regs_out(regs_out), .write_data(write_data), .write_sel(write_sel));

    initial begin
        clk = 1'b0;
        forever begin
            #0.4 clk = 0;
            #0.6 clk = 1;
        end
    end

    integer i;
    task dump();
        $display("[ ERR] Failed slice test case at #%0d", $time);
        $write("Register state: ");
        for (int i = 0; i < 16; i++) begin
            $write("r%0d=%0d ", i, regs_out[i]);
        end

        $finish;
    endtask; // dump


    initial
    begin

        $display("[INFO] Testing register_file");
        rst <= 1;
        @(posedge clk);
        rst <= 0;
        write_data[0] <= 8'b1;
        write_data[1] <= 8'b10;
        write_sel[0] <= 1'b1;
        write_sel[1] <= 2'b10;
        @(posedge clk);
        $display("%b", regs_out[1]);
        $display("%b", regs_out[2]);
        dump();

        // // done
        // #1 $display("[PASS] Completed slice Test at %0d",$time);

    end
    
endmodule // register_file_tb


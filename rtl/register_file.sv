module register_file #(
        parameter N=4,
        parameter Regs=8
    )
    (
        input                    CLK,
        input [(N*8-1):0]        Reg_Selector,
        output logic [(N*8-1):0] Out_Bus
    );

    // sanity check
    initial begin
        assert (Regs >= 1) else $fatal("[ ERR] Not enough registers!");
        assert (Regs <= 255) else $fatal("[ ERR] Too many registers!");
        assert (N >= 1) else $fatal("[ ERR] No VLIW cores???");
        assert (N <= 100) else $fatal("[ ERR] Unreasonable number of VLIW slices!");
        $display("[ GEN] Generating %0d registers for %0d slices...", Regs, N);
    end

    // scratch reg r0
    logic [7:0] r0;
    assign r0 = 8'b0;

    // other registers
    logic [(Regs*8-1):0] reg_bus;

    // crossbar
    always @(posedge CLK)
    begin

    end;

    genvar i;
    generate
        for (i=1; i<N+1; i=i+1) begin : register_generation_n
            $display("Generating register %0d", i);

        end;
    endgenerate

endmodule



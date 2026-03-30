module register_file #(
        parameter N=4,
        parameter Regs=16
    )
    (
        input                    CLK,
        input [(reg_address_bits-1):0]       Reg_Selector[N],
        output tri [7:0] Data_Bus[N]
    );

    localparam reg_address_bits = $clog2(Regs) + 1; // plus r/w bit as MSB

    // sanity check
    initial begin
        assert (Regs >= 2) else $fatal("[ ERR] Not enough registers!");
        assert (reg_address_bits <= 8) else $fatal("[ ERR] Too many registers, address space not large enough!!");
        assert (N >= 1) else $fatal("[ ERR] No VLIW slices???");
        assert (N <= 100) else $fatal("[ ERR] Unreasonably large number of VLIW slices!");
        assert (Regs >= N+1 || Regs >= 8) else $fatal("[ ERR] Unreasonably small number of registers!");

        $display("[ GEN] Generated %0d registers for %0d slices with %0d address bits", Regs, N, reg_address_bits);
    end

    // register file
    logic [7:0] reg_file[Regs];

    genvar       reg_i, slice_i;
    generate
        for (reg_i=0; reg_i<Regs; ++reg_i) begin
            // shared
            tri [7:0] data;
            tri enable;
            tri write;

            // reg writer boundary
            if (reg_i!=0) begin
                reg_writer writer(
                               .CLK(CLK),
                               .Enable(Enable),
                               .Write(write),
                               .Register(reg_file[reg_i]),
                               .Data_Reg_Cross(data)
                           );
            end else begin
                // scratch register
                assign data = '0;
            end

            // crossbar
            for (slice_i=0; slice_i<N; ++slice_i) begin
                reg_crossbar #(reg_address_bits, reg_i) crossbar (
                                 .CLK(CLK),
                                 .Addr(Reg_Selector[slice_i]),
                                 .Data_Reg_Cross(data),
                                 .Data_Cross_Slice(Data_Bus[slice_i]),
                                 .Enable_Out(enable),
                                 .Write_Out(write)
                             );
            end
        end

    endgenerate



endmodule

// A crossbar between a data bus and a reg_writer
module reg_crossbar #(
        parameter ADDR_W, // including r/w bit
        parameter TARGET // when to forward signal
    )
    (
        input              CLK,
        input [ADDR_W-1:0] Addr,
        inout tri [7:0]    Data_Reg_Cross,
        inout tri [7:0]    Data_Cross_Slice,
        output             Enable_Out,
        output             Write_Out
    );
    assign Write_Out = Addr[ADDR_W-1];
    assign Enable_Out = (Addr[ADDR_W-2:0] == TARGET) ? '1 : 'z;

    // send data from slice to reg when enable and write are on, otherwise do not drive
    assign Data_Reg_Cross = (Enable_Out && Write_Out) ? Data_Cross_Slice : 'z;
    // same but for other direction
    assign Data_Cross_Slice = (Enable_Out && !Write_Out) ? Data_Reg_Cross : 'z;
endmodule

// Boundary between reg and tristate crossbar
module reg_writer    (
        input              CLK,
        input              Enable,
        input              Write, // 1 = write from data to register
        output logic [7:0] Register,
        inout tri [7:0]    Data_Reg_Cross
    );

    assign Data_Reg_Cross = (Enable && !Write) ? Register : 'z;

    logic [7:0] internal;
    assign Register = internal;

    always @(posedge CLK) begin
        if (Enable && Write) begin
            internal <= Data_Reg_Cross;
        end
    end
endmodule

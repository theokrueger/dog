module register_file #(
        parameter N=4,
        parameter Regs=16
    )
    (
        input                    CLK,
        input [(reg_address_bits-1):0]       Reg_Selector[N],
        inout tri [8*N-1:0] Data_Bus
    );

    localparam reg_address_bits = $clog2(Regs+1) + 1; // plus r/w bit as MSB, plus one to Regs because address 0 is "do nothing"

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

    genvar reg_i, slice_i;
    generate
        for (reg_i=0; reg_i<Regs; ++reg_i) begin
            // shared
            tri [7:0] data;
            tri enable;
            tri write;

            // N crossbars for each register
            for (slice_i=0; slice_i<N; ++slice_i) begin
                reg_crossbar #(reg_address_bits, reg_i+1) crossbar (
                                 .CLK(CLK),
                                 .Addr(Reg_Selector[slice_i]),
                                 .Data_Reg_Cross(data),
                                 .Data_Cross_Slice(Data_Bus[slice_i*8+7:slice_i*8]),
                                 .Enable_Out(enable),
                                 .Write_Out(write)
                             );
            end

            // reg writer boundary
            if (reg_i!=0) begin
                reg_writer #(reg_i+1) writer(
                               .CLK(CLK),
                               .Enable(Enable),
                               .Write(write),
                               .Register(reg_file[reg_i]),
                               .Data_Reg_Cross(data)
                           );
            end else begin
                // scratch register always has zero on read and writes do not impact it
                assign data = '0;
            end
        end
    endgenerate

    always @(posedge CLK) begin
        #0.1 begin
             $display(" Data Bus: ", Data_Bus);
         end;
    end
endmodule

// A crossbar between a data bus and a reg_writer
module reg_crossbar #(
        parameter ADDR_W, // including r/w bit
        parameter [ADDR_W-1:0] TARGET // when to forward signal, len = ADDR_W - 1
    )
    (
        input              CLK,
        input [ADDR_W-1:0] Addr,             // register address line
        inout tri [7:0]    Data_Reg_Cross,   // dataline between this and a register
        inout tri [7:0]    Data_Cross_Slice, // dataline between this and a slice
        output             Enable_Out,       // is the register supposed to do anythin?
        output             Write_Out         // write to the reg_writer
    );

    assign Enable_Out = (Addr[ADDR_W-2:0] == TARGET) ? '1 : 'z;
    assign Write_Out = (Addr[ADDR_W-1] == 1) ? Enable_Out: 'z;

    // send data from slice to reg when enable and write are on, otherwise do not drive
    assign Data_Reg_Cross = (Enable_Out && Write_Out) ? Data_Cross_Slice : 'z;
    // same but for other direction
    assign Data_Cross_Slice = (Enable_Out && !Write_Out) ? Data_Reg_Cross : 'z;

    always @(posedge CLK) begin
        #0.2 begin

             //if (TARGET == 1) begin
             $display("   Crossbar Node: TARGET=%0d ", TARGET, " Addr %b", Addr, " En ", Enable_Out, " W ", Write_Out, " DRC ", Data_Reg_Cross, " DCS ", Data_Cross_Slice);
             //end
         end;
    end
endmodule

// Boundary between reg and tristate crossbar
module reg_writer #(parameter NUM)
    (
        input              CLK,
        input              Enable,
        input              Write,
        output logic [7:0] Register,      // register we are writing to
        inout tri [7:0]    Data_Reg_Cross // dataline between this and a crossbar
    );

    // reg out to datapus on read
    assign Data_Reg_Cross = (Enable && !Write) ? Register : 'z; // Read when enabled, otherwise do not drive

    // register update on write
    logic [7:0] internal_reg;
    assign Register = internal_reg;

    always @(posedge CLK) begin
        if (Enable && Write) begin
            internal_reg <= Data_Reg_Cross;
        end
    end

    // print
    always @(posedge CLK) begin
        #0.3 begin
             $display(" RegWriter r%0d:", NUM, " En ", Enable, " W ", Write);
         end;
    end

endmodule

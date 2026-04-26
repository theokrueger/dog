module register_file #(parameter N=4, parameter Regs=16)
    (
        input wire clk,
        input wire rst,
        // 15 8-bit registers
        output wire [7:0] regs_out [Regs],
        // what to
        input wire [7:0] write_data [0:N-1],
        input wire [reg_address_bits-1:0] write_sel [0:N-1]
    );

    localparam reg_address_bits = $clog2(Regs);
    reg [7:0] registers [Regs];
    integer i;

    always @(posedge clk) begin

        if (rst) begin
            for (i=0; i<16; i=i+1) begin
                registers[i] <= {8'b0};
            end
        end
        else begin
            $display("not resetting, setting stuff");
            for (i=0; i<N; i=i+1) begin
                // ignore 0
                if (write_sel[i] != 0) begin
                    $display("setting %d to %d", write_sel[i], write_data[i]);
                    registers[write_sel[i]] <= write_data[i];
                end
            end
        end // else: !if(rst)
        registers[0] = 0;
    end

    genvar j;
    generate
        for (j=0; j<16; j=j+1) begin
            assign regs_out[j] = registers[j];
        end
    endgenerate

endmodule

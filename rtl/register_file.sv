module register_file #(parameter N=4)
    (
        input wire clk,
        input wire rst,
        // 15 8-bit registers
        output wire [7:0] regs_out [0:15],
        // what to 
        input wire [7:0] write_data [0:N-1],
        input wire [3:0] write_sel [0:N-1]
    );

    reg [7:0] registers [0:15];
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
        end
        registers[0] = 8'b0;
    end

    genvar j;
    generate
        for (j=0; j<16; j=j+1) begin
            assign regs_out[j] = registers[j];
        end
    endgenerate
    
endmodule

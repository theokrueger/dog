module instruction_decode #(parameter N=4) (
        input wire CLK,
        input [10+28*N:0] word,

        output [N*4-1:0]  ops,
        output [N*8-1:0]  As, Bs, Cs,

        output [2:0]      branchop,
        output [7:0]      branchaddr
    );

    // sanity check
    initial begin
        assert (N>=1) else $fatal("[ ERR] Instruction word length too short!");
        $display("[ GEN] Generated %0d-instruction wordlength decoder", N);
    end


    assign branchaddr = word[7:0];
    assign branchop = word[10:8];

    genvar i;
    generate
        for (i=0; i<N; i=i+1) begin : instruction_decode_n
            assign Cs[8*i +: 8] = word[11+28*i +: 8];
            assign Bs[8*i +: 8] = word[19+28*i +: 8];
            assign As[8*i +: 8] = word[27+28*i +: 8];
            assign ops[4*i +: 4] = word[35+28*i +: 4];
        end
    endgenerate
endmodule // instruction_decode

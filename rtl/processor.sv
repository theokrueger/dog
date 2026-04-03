module processor #(parameter N=4) (
  input wire clk,
  input wire rst,
  input [9+20*N:0] word,
  input [7:0] PC,
  output [7:0] nextPC,
  output [7:0] reg_state [0:15]
);

  wire [N*4-1:0] ops;
  wire [N*8-1:0] As, Bs, Cs;
  wire [1:0] branchop;
  wire [7:0] branchaddr;
  instruction_decode #(.N(N)) decode (.word(word), .ops(ops), .As(As), .Bs(Bs), .Cs(Cs), .branchop(branchop), .branchaddr(branchaddr));

  wire [7:0] regs_out [0:15];
  wire [7:0] write_data [0:N-1];
  wire [3:0] write_sel [0:N-1];
  register_file #(.N(N)) rf (.clk(clk), .rst(rst), .regs_out(regs_out), .write_data(write_data), .write_sel(write_sel));

  genvar i;
  wire [7:0] next_PC
  generate
    for (i=0; i<N; i=i+1) begin
      slice #(.N(N)) s (
        .CLK(clk),
        .Instruction(ops[4*i +: 4]),
        .Arg1(regs_out[As[8*i +: 8]]),
        .Arg2(regs_out[Bs[8*i +: 8]]),
        .PC_in(PC),
        .PC_out(next_PC),
        .ALU_out(write_data[i]));
      assign write_sel[i] = Cs[8*i +: 8];
    end
  endgenerate

  assign reg_state = regs_out;

endmodule



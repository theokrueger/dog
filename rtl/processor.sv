module processor #(parameter N=4, parameter Regs=16) (
  input wire clk,
  input wire rst,
  input [10+28*N:0] word,
  input [7:0] PC,
  output [7:0] nextPC,
  output [7:0] reg_state [0:15]
);
`include "incl/ALU_Ops.svh"
  localparam reg_address_bits = $clog2(Regs);

  wire [N*4-1:0] ops;
  wire [N*8-1:0] As, Bs, Cs;
  wire [2:0] branchop;
  wire [7:0] branchaddr;
  instruction_decode #(.N(N)) decode (.word(word), .ops(ops), .As(As), .Bs(Bs), .Cs(Cs), .branchop(branchop), .branchaddr(branchaddr));


  wire [7:0] regs_out [0:15];
  wire [7:0] write_data [0:N-1];
  wire [reg_address_bits-1:0] write_sel [0:N-1];
  register_file #(.N(N), .Regs(Regs)) rf (.clk(clk), .rst(rst), .regs_out(regs_out), .write_data(write_data), .write_sel(write_sel));

  genvar i;
  wire [7:0] next_PC;
  generate
    for (i=0; i<N; i=i+1) begin
      logic [7:0] A_reg, B_reg;
      logic [3:0] op_reg;

      always_ff @(posedge clk) begin
        A_reg <= regs_out[As[8*i +: 4]];
        case(ops[4*i +: 4])
          ALU_ADD_IM_OP, 
          ALU_SUB_IM_OP,
          ALU_MUL_IM_OP,
          ALU_DIV_IM_OP,
          ALU_MOD_IM_OP : B_reg <= Bs[8*i +: 8];
          default       : B_reg <= regs_out[Bs[8*i +: 4]];
        endcase;
        op_reg <= ops[4*i +: 4];
      end
      logic alu_zero;
      logic alu_sub_uf;
      alu alu(
              .CLK(clk),
              .Operation(op_reg),
              .A(A_reg),
              .B(B_reg),
              .Y(write_data[i]),
              .Zero(alu_zero),
              .Sub_UF(alu_sub_uf)
          );


      if (i == 0) begin
        branch_unit bu(
                       .CLK(CLK),
                       .Operation(branchop),
                       .Address(branchaddr),
                       .PC(PC),
                       .PC_out(nextPC),
                       .Zero(alu_zero),
                       .Sub_UF(alu_sub_uf));
      end

      assign write_sel[i] = Cs[8*i +: 4];
    end
  endgenerate

  assign reg_state = regs_out;

endmodule



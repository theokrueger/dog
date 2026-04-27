from dataclasses import dataclass
from generate_prime_factorization import word_into_bin, generate
from sys import argv

@dataclass
class Ops:
    ALU_NO_OP = 0b0000
    ALU_ADD_OP = 0b0001
    ALU_SUB_OP = 0b0010
    ALU_MUL_OP = 0b0011
    ALU_DIV_OP = 0b0100
    ALU_AND_OP = 0b0101
    ALU_OR_OP = 0b0110
    ALU_EQ_OP = 0b0111
    ALU_GT_OP = 0b1000
    ALU_GTE_OP = 0b1001
    ALU_MOD_OP = 0b1010
    ALU_ADD_IM_OP = 0b1011
    ALU_SUB_IM_OP = 0b1100
    ALU_MUL_IM_OP = 0b1101
    ALU_DIV_IM_OP = 0b1110
    ALU_MOD_IM_OP = 0b1111
    BRANCH_NO_OP = 0b00
    BRANCH_NOTZERO_OP = 0b01
    BRANCH_SUBOVERFLOW_OP = 0b10
    BRANCH_ZERO_OP = 0b11
    BRANCH_UNCONDITIONAL_OP = 0b100

class Processor():

    def __init__(self, N, regs):

        self.steps = 0
        self.N = N
        self.regs = [0 for _ in range(regs)]
    
    def decode_program(self, program: str) -> list:
        # programs are given in binary, we need to decode them
        # first 28*n bits are operations, last bits are branch stuff
        decoded_lines = []
        lines = program.splitlines()
        for line in lines:
            decoded_line = []
            for i in range(self.N):
                decoded_line.append([
                    int(line[i*28:i*28+4], 2),
                    int(line[i*28+4:i*28+12], 2),
                    int(line[i*28+12:i*28+20], 2),
                    int(line[i*28+20:i*28+28], 2)])

            # add branching part
            # branchop is 2 bits, branchaddr is 7
            decoded_line.append([
                int(line[self.N*28:self.N*28+3], 2),
                int(line[self.N*28+3:self.N*28+11], 2)
            ])

            decoded_lines.append(decoded_line)

        return decoded_lines
    
    def run_program(self, program: str):

        program_decoded = self.decode_program(program) # todo
        program_split = program.splitlines()
        res = []
        pc = 0
        while pc < len(program_decoded):
            res2 = [pc, program_split[pc], program_decoded[pc]]
            pc = self.step(pc, program_decoded[pc])
            res2 += [[*self.regs], pc]
            res.append(res2)

        return res

        
    def step(self, pc, instructions: list):
        
        zero = None
        sub_UF = None
        for i, inst in enumerate(instructions[:-1]):
            arg1 = self.regs[inst[1]]
            arg2 = None
            match inst[0]:
                case Ops.ALU_ADD_IM_OP \
                    | Ops.ALU_SUB_IM_OP \
                    | Ops.ALU_MUL_IM_OP \
                    | Ops.ALU_DIV_IM_OP \
                    | Ops.ALU_MOD_IM_OP:
                    arg2 = inst[2]
                case _:
                    arg2 = self.regs[inst[2]]
            match inst[0]:
                case Ops.ALU_NO_OP:
                    ...
                case Ops.ALU_ADD_OP | Ops.ALU_ADD_IM_OP:
                    self.regs[inst[3]] = (arg1 + arg2) % 2**8
                case Ops.ALU_SUB_OP | Ops.ALU_SUB_IM_OP:
                    self.regs[inst[3]] = (arg1 - arg2) % 2**8
                case Ops.ALU_MUL_OP | Ops.ALU_MUL_IM_OP:
                    self.regs[inst[3]] = (arg1 * arg2) % 2**8
                case Ops.ALU_DIV_OP | Ops.ALU_DIV_IM_OP:
                    self.regs[inst[3]] = (int(arg1 / arg2)) % 2**8
                case Ops.ALU_AND_OP:
                    self.regs[inst[3]] = (arg1 & arg2) % 2**8
                case Ops.ALU_OR_OP:
                    self.regs[inst[3]] = (arg1 | arg2) % 2**8
                case Ops.ALU_EQ_OP:
                    self.regs[inst[3]] = int(arg1 == arg2)
                case Ops.ALU_GT_OP:
                    self.regs[inst[3]] = int(arg1 > arg2)
                case Ops.ALU_GTE_OP:
                    self.regs[inst[3]] = int(arg1 >= arg2)
                case Ops.ALU_MOD_OP | Ops.ALU_MOD_IM_OP:
                    self.regs[inst[3]] = (arg1 % arg2) % 2**8
                case _:
                    raise Exception("died")
            if (i == 0):
                zero = (self.regs[inst[3]] == 0)
                sub_UF = (inst[0] == Ops.ALU_SUB_OP or inst[0] == Ops.ALU_SUB_IM_OP) and (arg2 > arg1)

        branchop, branchaddr = instructions[-1]
        pc = pc + 1
        match branchop:
            case Ops.BRANCH_NO_OP: 
                ...
            case Ops.BRANCH_NOTZERO_OP: 
                if not zero:
                    pc = branchaddr
            case Ops.BRANCH_SUBOVERFLOW_OP: 
                if sub_UF:
                    pc = branchaddr
            case Ops.BRANCH_ZERO_OP: 
                if zero:
                    pc = branchaddr
            case Ops.BRANCH_UNCONDITIONAL_OP: 
                pc = branchaddr
            case _:
                raise Exception("died")

        
        self.steps += 1
        return pc

        

def generate_testbench(name, N, value, clk=5):
    
    program = "\n".join([word_into_bin(word, N) for word in generate(N, value)])
    
    proc = Processor(N, N+4)
    run = proc.run_program(program)
    
    content = ""

    for oldpc, inst, inst_decoded, regs, newpc in run:
        
        regvalue = 0
        for i, reg in enumerate(regs):
            regvalue += reg << (8*i)
        
        content += f"""
        // {inst_decoded}
        word = 'd{int(inst, 2)};
        PC = 'd{oldpc};
        @(posedge CLK);
        #{clk-1};
        // assert_correct('d{regvalue}, {newpc});
"""
    
    
    return f"""
`timescale 1ns / 1ps
module {name}_tb;
    localparam regs = 8;
    localparam  reg_bits = $clog2(regs);
    localparam   n = 4;

    logic CLK;
    logic rst;

    logic [10+28*n:0] word;
    logic [7:0] PC;
    logic [7:0] nextPC;
    wire [8*regs-1:0] reg_state;

    // processor #(.N(n), .Regs(regs)) dut (
    processor dut (
                  .CLK(CLK),
                  .rst(rst),
                  .word(word),
                  .PC(PC),
                  .nextPC(nextPC),
                  .reg_state(reg_state)
              );

    integer i;
    task dump();
        $write("  registers: ");
        for (int i = 0; i < regs; i++) begin
            $write("    r%0d=%0d ", i, reg_state[8*i +: 8]);
        end
        $write("\\n");
    endtask; // dump
    task fail(input logic [8*regs-1:0] arr, pc);
        $display("[ ERR] Failure in processor test case at #%0d", $time);
        $display("  pc real %d expected %d", nextPC, pc);
        $write("  expected: ");
        for (int i = 0; i < regs; i++) begin
            $write("    r%0d=%0d ", i, arr[8*i +: 8]);
        end
        $write("\\n");
        dump();
        $finish;
    endtask
    task assert_correct(input logic [8*regs-1:0] arr, pc);
        for (int i=0; i<regs; i++) begin
            assert (arr[8*i +: 8] == reg_state[8*i +: 8]) else fail(arr, pc);
        end
        assert (pc == nextPC) else fail(arr, pc);
    endtask
    initial begin
        CLK = 1'b0;
        forever begin
            #{clk} CLK = 0;
            #{clk} CLK = 1;
        end
    end

    // test cases
    initial
    begin
        $dumpfile("decode.vcd");
        $dumpvars(0, test1_tb);

        $display("[INFO] Testing processor {name}");
        rst <= 1;
        PC <= 0;
        word = '0;
        @(posedge CLK);
        #{clk-1};
        // assert_correct('0, 1);
        rst <= 0;
{content}

        $display("[PASS] Completed {name} test at %0d",$time);
        $finish;
    end
endmodule
"""

    

if __name__ == "__main__":
    # program = "\n".join([word_into_bin(word, 4) for word in generate(4, 232)])
    
    # proc = Processor(4, 16)
    # run = proc.run_program(program)
    # print("\n".join(map(lambda a: str(a[2]) + "\n" + str(a[3]), run)))


    print(generate_testbench("test1", int(argv[1]), 233, int(argv[2])))



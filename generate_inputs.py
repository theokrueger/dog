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



class processor():

    def __init__(self, N, regs):
        ...

        self.N = N
        self.regs = [0 for _ in range(regs)]
    
    def decode_program(self, program: str) -> list:
        ...
    
    def run_program(self, program: str):

        program_decoded = self.decode_program(program) # todo
        pc = 0
        while pc < len(program_decoded):
            pc = self.step(program_decoded[pc])

        
    def step(self, instruction):
        ...
        
    
        

    




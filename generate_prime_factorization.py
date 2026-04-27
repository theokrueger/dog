from math import log, ceil, floor
from dataclasses import dataclass

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
"""ex
        {
        LADD r1 r0 233 // p
        LADD r2 r0 2 // i
        J loopstart
        }
        {
        LSUB r3 r0 4
        }
        // we have some constant n
loopbody:
        {
        LADD r4 r2 0
        LADD r5 r2 1
        LADD r6 r2 2
        LADD r7 r2 3
        }
        {
        MOD r4 r1 r4
        MOD r5 r1 r5
        MOD r6 r1 r6
        MOD r7 r1 r7
        }
        {
        MUL r3 r3 r4 
        MUL r5 r5 r6
        }
        {
        MUL r3 r3 r5
        LADD r2 4 r2
        JZ found
        }
loopstart:
        // if i >= p ew loop
        {
        GEQ r3 r2 r1
        JNZ loopbody
        }
notfound:
        {
        LADD r1 r0 0
        J exit
        }
found:
        LADD r1 r0 1
exit:
"""

# let's make lists that we fill with nops later
# N must be geq 2, must have N+3 regs
def generate(N, p=233):
    cz = coalesce_zeros(N)

    loopbody = 1
    loopstart = 3+len(cz)
    notfound = loopstart + 1
    found = notfound + 1
    exit = found + 1

    cz[-1][-1] = [Ops.ALU_ADD_IM_OP, 2, N, 2] # increment i
    cz[-1].append([Ops.BRANCH_ZERO_OP, found])

    nob = [Ops.BRANCH_NO_OP, 0]
    startops = [[Ops.ALU_ADD_IM_OP, 0, p, 1], [Ops.ALU_ADD_IM_OP, 0, 2, 2], [Ops.ALU_ADD_IM_OP, 0, p-4, 3], [Ops.BRANCH_UNCONDITIONAL_OP, loopstart]]
    start = [
        [[startops[0], nob], [startops[1], nob], [startops[2], startops[3]]],
        [[startops[0], startops[1], nob], [startops[2], startops[3]]],
        [startops]
    ]

    # make the base stuff
    insts = [
        *(start[N-1] if N < 3 else start[2]),
        [*[[Ops.ALU_ADD_IM_OP, 2, i, 4+i] for i in range(N)], [Ops.BRANCH_NO_OP, 0]],# add offsets
        [*[[Ops.ALU_MOD_OP, 1, 4+i, 4+i] for i in range(N)], [Ops.BRANCH_NO_OP, 0]], # check modulo
        *cz,
        [
            [Ops.ALU_GTE_OP, 3, 2, 4],
            [Ops.BRANCH_NOTZERO_OP, loopbody]
        ],
        [
            [Ops.ALU_ADD_IM_OP, 0, 0, 1],
            [Ops.BRANCH_UNCONDITIONAL_OP, exit]
        ],
        [[Ops.ALU_ADD_IM_OP, 0, 1, 1], [Ops.BRANCH_NO_OP, 0]]
    ]

    return insts
    
def coalesce_zeros(N):
    res = []
    regs = [4+i for i in range(N)]

    # pair registers until there's only one left
    while len(regs) > 1:
        can_kill = min(floor(len(regs)/2), N)
        res.append([*[[Ops.ALU_MUL_OP, regs[-i-1], regs[i], regs[i]] for i in range(can_kill)], [Ops.BRANCH_NO_OP, 0]])
        regs = regs[:-can_kill]

    return res
    
def word_into_bin(word, N):
    head = "".join([f"{op:04b}{s1:08b}{s2:08b}{dest:08b}" for op, s1, s2, dest in word[:-1]])
    nops = ("0" * 28 * (N-len(word)+1))
    branch = f"{word[-1][0]:03b}{word[-1][1]:08b}"

    return head + nops + branch

if __name__ == "__main__":
    # print(generate(4))
    import sys
    N=int(sys.argv[1] or 4)
    print("\n".join(reversed([word_into_bin(word, N) for word in generate(N)])))
    # "\n".join([word_into_bin(word, 4) for word in generate(4)])

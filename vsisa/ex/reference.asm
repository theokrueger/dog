// single-line comment
/* multi-line
        comment */

// arguments:
// r0          is a register
// 0b1010      is a binary literal
// 0xabcd      is a hex literal
// 0d1234      is a decimal literal
// label_name: is a label, which is turned into a literal during assembly

// instruction reference:
        ADD  r0 r1 r2  // r0 = r1+r2
        SUB  r0 r1 r2  // r0 = r1-r2
        MUL  r0 r1 r2  // r0 = r1*r2
        DIV  r0 r1 r2  // r0 = r1/r2
        AND  r0 r1 r2  // r0 = r1&r2
        OR   r0 r1 r3  // r0 = r1|r2
        JMP  label:    // jump to address of label
        JMP  0x123     // jump to address of literal
        JEZ  0d12 r1   // jump to 0d12 if r1 == 0
        JGZ  0d12 r1   // jump to 0d12 if r1 > 0
//        NOP            // do nothing
        LADD r0 r1 0x1 // r0 = r1 + 0x1
        LSUB r0 r1 0x1 // r0 = r1 - 0x1
        LMUL r0 r1 0x1 // r0 = r1 * 0x1
        LDIV r0 r1 0x1 // r0 = r1 / 0x1
        LAND r0 r2 0x1 // r0 = r1 & 0x1
        LOR  r0 r1 0x1 // r0 = r1 | 0x1


label:  // this is a label
        // it must be on its own line
        // it is considered a literal as well

// sample pogram

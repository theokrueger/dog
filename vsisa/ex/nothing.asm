        ADD     r0      r2      r3
// ars
        JMP     0b001
label: // with comment
        SUB     r3      r3      r2
        JEZ     label2:  r3
        JGZ     0b001   r2
label2:
        JEZ     label: r2
        ADD    r1      r2      r3
        SUB    r4      r4      r6
        LDIV   r1      r2      0xA
        MUL    r5      r6      r6

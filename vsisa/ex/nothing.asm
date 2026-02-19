        ADD     r0      r2      r3
// ars
        JMP     r0
label: // with comment
        SUB     r3      r3      r2
        JEZ     label:  r3
        JGT     0b001   r2
label2: 
        JEZ     label2: r2

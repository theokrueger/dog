        ADD     r0      r2      r3
// ars
        JMP     0b001
label: // with comment
        SUB     r3      r3      r2
        JEZ     label2:  r3
        JGZ     0b001   r2
label2: 
        JEZ     label: r2

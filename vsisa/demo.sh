#!/bin/bash
clear;
cargo run -- ex/nothing.asm /tmp/out2 -w 2
cargo run -- ex/nothing.asm /tmp/out4 -w 4
echo
echo "Program N=2:"
cat /tmp/out2 | sed 's/......../& /g'
echo
echo "Program N=4:"
cat /tmp/out4 | sed 's/......../& /g'


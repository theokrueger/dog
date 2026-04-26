#!/bin/bash
clear;
cargo run -- ex/nothing.asm /tmp/out2 -w 2 || exit
cargo run -- ex/nothing.asm /tmp/out4 -w 3 || exit
echo
echo "Program N=2:"
cat /tmp/out2 | sed 's/......../& /g'
echo
echo "Program N=3:"
cat /tmp/out4 | sed 's/......../& /g'


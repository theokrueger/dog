# generate a testbench
cd "$(dirname "$0")" || exit

python generate_inputs.py $1 $2 > test1_tb.sv

# run the tb to get the vcd
iverilog -g2012 -gassertions -o sim test1_tb.sv netlist.v slow_vdd1v0_basicCells.v
vvp sim

# report power
sudo docker run -i -v .:/data opensta_ubuntu22.04 -exit /data/sta.tcl

# cleanup
# rm sim
# rm decode.vcd

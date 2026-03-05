#####################################################################
# setup.tcl
#####################################################################
set CLK_NAME CLK

set SYNTH_DIR ./synth

set RPT_DIR ./rpt/synth
file mkdir $RPT_DIR

set PNR_DIR ./pnr
file mkdir $PNR_DIR

# root mod to synthesize
set MOD_NAME alu

# initialize link and synthetic libraries
# is synthetic library global??? lol.
set synthetic_library [list dw_foundation.sldb]
set link_library [list $SYNTH_DIR/gpdk045_slow.db]
set target_library $SYNTH_DIR/gpdk045_slow.db


# read potential verilog targets
set RTL_DIR rtl
read_verilog $RTL_DIR/slice/alu.sv
# TODO add more

current_design $MOD_NAME

#set the number of digits to be used for delay/power results
set report_default_significant_digits 4

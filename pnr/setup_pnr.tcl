set init_lef_file [list $PNR_DIR/lib/gsclib045.lef]

set init_verilog $PNR_DIR/netlist.v
set init_top_cell alu
set init_mmmc_file $PNR_DIR/mmmc.tcl

#set power and ground rails
set init_pwr_net {VDD VDD}
set init_gnd_net {VSS VSS}

#set process node
setDesignMode -process 45

set RPT_DIR rpt/pnr
file mkdir $RPT_DIR

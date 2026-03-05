# run timing checks before reporting
check_timing

# write out reports so that you can read them after synthesis
report_timing -delay_type max > $RPT_DIR/timing_max.rpt
report_timing -delay_type min > $RPT_DIR/timing_min.rpt
report_cell                   > $RPT_DIR/cell_report.rpt
report_power                  > $RPT_DIR/power_report.rpt

# write out the post-synthesis netlist
write_file -hierarchy -f verilog -o $RPT_DIR/netlist.v


# write out the post-synthesis netlist in the pnr directory
write_file -hierarchy -f verilog -o $PNR_DIR/netlist.v

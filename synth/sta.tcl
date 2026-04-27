read_liberty /data/slow.lib
read_verilog /data/netlist.v
link_design processor
create_clock -name CLK -period 10 [get_ports CLK]
read_vcd /data/decode.vcd -scope test1_db/dut
report_power
exit

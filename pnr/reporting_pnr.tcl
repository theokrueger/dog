# drc
verify_drc > $RPT_DIR/drc.rpt

# report timing
setAnalysisMode -analysisType onChipVariation
timeDesign -postRoute > $RPT_DIR/timeDesign_summary.rpt
report_timing         > $RPT_DIR/timing.rpt

# report power
reportPower > $RPT_DIR/power.rpt

# report routing
reportRoute > $RPT_DIR/route.rpt

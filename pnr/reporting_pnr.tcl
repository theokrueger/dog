# drc
verify_drc > $RPT_DIR/drc.rpt

setAnalysisMode -analysisType onChipVariation
timeDesign -postRoute > $RPT_DIR/timeDesign_summary.rpt
report_timing         > $RPT_DIR/timing.rpt

reportPower > $RPT_DIR/power.rpt

reportRoute > $RPT_DIR/route.rpt

report_area > $RPT_DIR/area_report.rpt

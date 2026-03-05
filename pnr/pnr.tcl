# set floorplan dimensions
set aspect_ratio 0.5
set core_utilization 0.7
set core_to_io_spacing 10
floorPlan -r $aspect_ratio $core_utilization $core_to_io_spacing $core_to_io_spacing $core_to_io_spacing $core_to_io_spacing

# add power ring and powergrid
set PR_width 1.25
set PR_space 1.25
set PR_offset 1.25
addRing -nets {VDD VSS} -type core_rings -follow core -layer {top Metal9 bottom Metal9 left Metal8 right Metal8} \
                        -width $PR_width \
                        -spacing $PR_space \
                        -offset $PR_offset \
                        -center 1

globalNetConnect VDD -type pgpin -pin VDD -instanceBasename *
globalNetConnect VSS -type pgpin -pin VSS -instanceBasename *
setSrouteMode -viaConnectToShape stripe
sroute

# run placement
setPlaceMode -place_global_place_io_pins true
placeDesign

optDesign

# clock tree synthesis:
# can include cts if required

# routing
routeDesign -globalDetail

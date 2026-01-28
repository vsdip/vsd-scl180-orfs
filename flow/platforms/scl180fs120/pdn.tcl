####################################
# SCL180 FS120 PDN (drop-in, safer)
# Routing layers (tech.lef): M1 M2 M3 M4 M5 TOP_M
# Stdcell PG pins: VDD / VSS
####################################

####################################
# global connections
####################################
add_global_connection -net {VDD} -inst_pattern {.*} -pin_pattern {^VDD$} -power
add_global_connection -net {VSS} -inst_pattern {.*} -pin_pattern {^VSS$} -ground
global_connect

####################################
# voltage domains
####################################
set_voltage_domain -name {CORE} -power {VDD} -ground {VSS}

####################################
# standard cell grid
####################################
# Use TOP_M as the "pin" layer for robustness (top-level straps/pins)
define_pdn_grid -name {grid} -voltage_domains {CORE} -pins {TOP_M}

# 1) Follow stdcell rails on M1 (rail height in LEF is 0.740)
add_pdn_stripe -grid {grid} -layer {M1} -width {0.740} -pitch {0} -offset {0} -followpins

# 2) Add core straps on upper metals (tune pitch/offset later as needed)
#    Conservative starting point
add_pdn_stripe -grid {grid} -layer {M4} -width {1.600} -pitch {30.000} -offset {15.000}
add_pdn_stripe -grid {grid} -layer {M5} -width {1.600} -pitch {30.000} -offset {15.000}

# 3) Connect layers (STEPPED connects are safer than direct M1<->M4)
add_pdn_connect -grid {grid} -layers {M1 M2}
add_pdn_connect -grid {grid} -layers {M2 M3}
add_pdn_connect -grid {grid} -layers {M3 M4}
add_pdn_connect -grid {grid} -layers {M4 M5}
add_pdn_connect -grid {grid} -layers {M5 TOP_M}

####################################
# macro grids (only used if macros exist)
####################################
define_pdn_grid -name {CORE_macro_grid_1} -voltage_domains {CORE} -macro \
  -orient {R0 R180 MX MY} -halo {2.0 2.0 2.0 2.0} -default -grid_over_boundary
add_pdn_connect -grid {CORE_macro_grid_1} -layers {M4 M5}
add_pdn_connect -grid {CORE_macro_grid_1} -layers {M5 TOP_M}

define_pdn_grid -name {CORE_macro_grid_2} -voltage_domains {CORE} -macro \
  -orient {R90 R270 MXR90 MYR90} -halo {2.0 2.0 2.0 2.0} -default -grid_over_boundary
add_pdn_connect -grid {CORE_macro_grid_2} -layers {M4 M5}
add_pdn_connect -grid {CORE_macro_grid_2} -layers {M5 TOP_M}


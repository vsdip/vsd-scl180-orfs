# SCL180 FS120 6M1L — RC derived from scl18fs120_tech.lef (unitNomResistance/unitNomCapacitance)
# cap units: pf/um
# res units: ohm/um
#
# Method:
#   R_per_um = (RPERSQ in ohm/sq) / WIDTH(um)
#   C_per_um = (CPERSQDIST in pf/um^2) * WIDTH(um)

# Routing layers
set_layer_rc -layer M1    -capacitance 8.119e-06  -resistance 3.47826e-01
set_layer_rc -layer M2    -capacitance 6.776e-06  -resistance 1.42857e-01
set_layer_rc -layer M3    -capacitance 6.776e-06  -resistance 1.14286e-01
set_layer_rc -layer M4    -capacitance 1.400e-05  -resistance 2.85714e-02
set_layer_rc -layer M5    -capacitance 2.832e-05  -resistance 6.66667e-03
set_layer_rc -layer TOP_M -capacitance 3.540e-05  -resistance 2.66667e-03

# Via resistances (from VIA blocks in tech.lef)
set_layer_rc -via V2 -resistance 6.96
set_layer_rc -via V3 -resistance 3.44
set_layer_rc -via V4 -resistance 1.90
set_layer_rc -via V5 -resistance 0.90
#set_layer_rc -via VL -resistance 0.88

# Default wire RC layers
set_wire_rc -signal -layer M1
set_wire_rc -clock  -layer M3


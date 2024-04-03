set_property PACKAGE_PIN T10 [get_ports {SS_out[6]}]
set_property PACKAGE_PIN R10 [get_ports {SS_out[5]}]
set_property PACKAGE_PIN K16 [get_ports {SS_out[4]}]
set_property PACKAGE_PIN K13 [get_ports {SS_out[3]}]
set_property PACKAGE_PIN P15 [get_ports {SS_out[2]}]
set_property PACKAGE_PIN T11 [get_ports {SS_out[1]}]
set_property PACKAGE_PIN L18 [get_ports {SS_out[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SS_out[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SS_out[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SS_out[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SS_out[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SS_out[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SS_out[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SS_out[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {anOut[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {anOut[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {anOut[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {anOut[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {anOut[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {anOut[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {anOut[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {anOut[0]}]
set_property PACKAGE_PIN U13 [get_ports {anOut[7]}]
set_property PACKAGE_PIN K2 [get_ports {anOut[6]}]
set_property PACKAGE_PIN T14 [get_ports {anOut[5]}]
set_property PACKAGE_PIN P14 [get_ports {anOut[4]}]
set_property PACKAGE_PIN J14 [get_ports {anOut[3]}]
set_property PACKAGE_PIN T9 [get_ports {anOut[2]}]
set_property PACKAGE_PIN J18 [get_ports {anOut[1]}]
set_property PACKAGE_PIN J17 [get_ports {anOut[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports i_clk]
set_property IOSTANDARD LVCMOS33 [get_ports i_rst]
set_property PACKAGE_PIN E3 [get_ports i_clk]
set_property PACKAGE_PIN J15 [get_ports i_rst]

set_false_path -from [get_ports i_rst]
set_false_path -through [get_ports {SS_out[*]}]
set_false_path -through [get_ports {anOut[*]}]

# set_property IOSTANDARD LVCMOS33 [get_ports {segOut[6]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {segOut[5]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {segOut[4]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {segOut[3]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {segOut[2]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {segOut[1]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {segOut[0]}]


set_property PACKAGE_PIN E15 [get_ports i_miso]
set_property PACKAGE_PIN D15 [get_ports o_CS]
set_property PACKAGE_PIN F14 [get_ports o_MOSI]
set_property PACKAGE_PIN F15 [get_ports o_SCLK]
set_property IOSTANDARD LVCMOS33 [get_ports o_CS]
set_property IOSTANDARD LVCMOS33 [get_ports o_MOSI]
set_property IOSTANDARD LVCMOS33 [get_ports o_SCLK]
set_property IOSTANDARD LVCMOS33 [get_ports i_r_accel]
set_property IOSTANDARD LVCMOS33 [get_ports i_miso]
set_property PACKAGE_PIN L16 [get_ports i_r_accel]


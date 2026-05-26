# Run in Vivado Tcl Console:
#   cd <repo root>
#   source vivado_add_parallel_io.tcl

set script_dir [file normalize [file dirname [info script]]]
set project_file [file join $script_dir mini_io.xpr]
set bd_file [file join $script_dir mini_io.srcs sources_1 bd design_1 design_1.bd]

if {[llength [get_projects -quiet]] == 0} {
    open_project $project_file
}

open_bd_design $bd_file
current_bd_design design_1

if {[llength [get_bd_cells -quiet axi_gpio_in]] == 0} {
    set axi_gpio_in [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_in]
    set_property -dict [list \
        CONFIG.C_GPIO_WIDTH {16} \
        CONFIG.C_ALL_INPUTS {1} \
        CONFIG.C_IS_DUAL {1} \
        CONFIG.C_GPIO2_WIDTH {5} \
        CONFIG.C_ALL_INPUTS_2 {1} \
    ] $axi_gpio_in
} else {
    set axi_gpio_in [get_bd_cells axi_gpio_in]
}

if {[llength [get_bd_cells -quiet axi_gpio_led]] == 0} {
    set axi_gpio_led [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_led]
    set_property -dict [list \
        CONFIG.C_GPIO_WIDTH {16} \
        CONFIG.C_ALL_OUTPUTS {1} \
    ] $axi_gpio_led
} else {
    set axi_gpio_led [get_bd_cells axi_gpio_led]
}

if {[llength [get_bd_intf_ports -quiet dip_switches_16bits]] == 0} {
    create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 dip_switches_16bits
}
if {[llength [get_bd_intf_ports -quiet push_buttons_5bits]] == 0} {
    create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 push_buttons_5bits
}
if {[llength [get_bd_intf_ports -quiet led_16bits]] == 0} {
    create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 led_16bits
}

connect_bd_intf_net [get_bd_intf_ports dip_switches_16bits] [get_bd_intf_pins axi_gpio_in/GPIO]
connect_bd_intf_net [get_bd_intf_ports push_buttons_5bits] [get_bd_intf_pins axi_gpio_in/GPIO2]
connect_bd_intf_net [get_bd_intf_ports led_16bits] [get_bd_intf_pins axi_gpio_led/GPIO]

set_property -dict [list CONFIG.NUM_MI {3}] [get_bd_cells microblaze_0_axi_periph]

if {[llength [get_bd_intf_nets -quiet microblaze_0_axi_periph_M01_AXI]] == 0} {
    connect_bd_intf_net [get_bd_intf_pins microblaze_0_axi_periph/M01_AXI] [get_bd_intf_pins axi_gpio_in/S_AXI]
}
if {[llength [get_bd_intf_nets -quiet microblaze_0_axi_periph_M02_AXI]] == 0} {
    connect_bd_intf_net [get_bd_intf_pins microblaze_0_axi_periph/M02_AXI] [get_bd_intf_pins axi_gpio_led/S_AXI]
}

connect_bd_net [get_bd_pins microblaze_0/Clk] [get_bd_pins axi_gpio_in/s_axi_aclk] [get_bd_pins axi_gpio_led/s_axi_aclk]
connect_bd_net [get_bd_pins rst_clk_wiz_1_100M/peripheral_aresetn] [get_bd_pins axi_gpio_in/s_axi_aresetn] [get_bd_pins axi_gpio_led/s_axi_aresetn]

assign_bd_address
if {[llength [get_bd_addr_segs -quiet {microblaze_0/Data/SEG_axi_gpio_in_Reg}]] != 0} {
    set_property offset 0x40000000 [get_bd_addr_segs {microblaze_0/Data/SEG_axi_gpio_in_Reg}]
}
if {[llength [get_bd_addr_segs -quiet {microblaze_0/Data/SEG_axi_gpio_led_Reg}]] != 0} {
    set_property offset 0x40010000 [get_bd_addr_segs {microblaze_0/Data/SEG_axi_gpio_led_Reg}]
}

validate_bd_design
save_bd_design
set wrapper_file [make_wrapper -files [get_files $bd_file] -top]
add_files -norecurse $wrapper_file
update_compile_order -fileset sources_1

puts "Parallel IO hardware is ready."

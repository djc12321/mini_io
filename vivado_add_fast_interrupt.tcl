# Run after vivado_add_parallel_io.tcl.

set script_dir [file normalize [file dirname [info script]]]
set project_file [file join $script_dir mini_io.xpr]
set bd_file [file join $script_dir mini_io.srcs sources_1 bd design_1 design_1.bd]

if {[llength [get_projects -quiet]] == 0} {
    open_project $project_file
}

open_bd_design $bd_file
current_bd_design design_1

set_property -dict [list CONFIG.C_INTERRUPT_PRESENT {1}] [get_bd_cells axi_gpio_in]
set_property -dict [list CONFIG.C_USE_INTERRUPT {2}] [get_bd_cells microblaze_0]

if {[llength [get_bd_cells -quiet axi_intc_0]] == 0} {
    set axi_intc_0 [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc:4.1 axi_intc_0]
    set_property -dict [list \
        CONFIG.C_HAS_FAST {1} \
        CONFIG.C_KIND_OF_INTR {0x00000000} \
        CONFIG.C_KIND_OF_LVL {0x00000001} \
        CONFIG.C_KIND_OF_EDGE {0x00000000} \
        CONFIG.C_IRQ_CONNECTION {0} \
    ] $axi_intc_0

    set_property -dict [list CONFIG.NUM_MI {4}] [get_bd_cells microblaze_0_axi_periph]
    connect_bd_intf_net [get_bd_intf_pins microblaze_0_axi_periph/M03_AXI] [get_bd_intf_pins axi_intc_0/s_axi]
    connect_bd_net [get_bd_pins microblaze_0/Clk] [get_bd_pins axi_intc_0/s_axi_aclk] [get_bd_pins axi_intc_0/processor_clk]
    connect_bd_net [get_bd_pins rst_clk_wiz_1_100M/peripheral_aresetn] [get_bd_pins axi_intc_0/s_axi_aresetn]
    connect_bd_net [get_bd_pins rst_clk_wiz_1_100M/mb_reset] [get_bd_pins axi_intc_0/processor_rst]
    connect_bd_net [get_bd_pins axi_gpio_in/ip2intc_irpt] [get_bd_pins axi_intc_0/intr]
    connect_bd_intf_net [get_bd_intf_pins axi_intc_0/interrupt] [get_bd_intf_pins microblaze_0/INTERRUPT]

    assign_bd_address
    if {[llength [get_bd_addr_segs -quiet {microblaze_0/Data/SEG_axi_intc_0_Reg}]] != 0} {
        set_property offset 0x41200000 [get_bd_addr_segs {microblaze_0/Data/SEG_axi_intc_0_Reg}]
    }
}

validate_bd_design
save_bd_design
set wrapper_file [make_wrapper -files [get_files $bd_file] -top]
add_files -norecurse $wrapper_file
update_compile_order -fileset sources_1

puts "Fast interrupt hardware is ready."

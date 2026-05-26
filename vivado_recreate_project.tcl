# Recreate the Vivado project file if mini_io.xpr is missing.

set script_dir [file normalize [file dirname [info script]]]
set project_file [file join $script_dir mini_io.xpr]
set bd_file [file join $script_dir mini_io.srcs sources_1 bd design_1 design_1.bd]
set wrapper_file [file join $script_dir mini_io.srcs sources_1 bd design_1 hdl design_1_wrapper.v]

if {![file exists $bd_file]} {
    error "Block design is missing: $bd_file"
}

create_project -in_memory -part xc7a100tcsg324-1
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]

if {[catch {set_property board_part digilentinc.com:nexys4_ddr:part0:1.1 [current_project]} msg]} {
    puts "Board part was not set: $msg"
}

add_files -norecurse $bd_file
if {[file exists $wrapper_file]} {
    add_files -norecurse $wrapper_file
    set_property top design_1_wrapper [current_fileset]
}

set_property source_mgmt_mode All [current_project]
update_compile_order -fileset sources_1
save_project_as mini_io $script_dir

puts "Vivado project recreated:"
puts "  $project_file"

set script_dir [file normalize [file dirname [info script]]]
set project_file [file join $script_dir mini_io.xpr]
set bd_file [file join $script_dir mini_io.srcs sources_1 bd design_1 design_1.bd]

if {[llength [get_projects -quiet]] == 0} {
    open_project $project_file
}

open_bd_design $bd_file
validate_bd_design
save_bd_design

set hdf_file [file join $script_dir mini_io.sdk design_1_wrapper.hdf]
file mkdir [file dirname $hdf_file]
write_hwdef -force -file $hdf_file

set platform_dir [file join $script_dir mini_io.sdk design_1_wrapper_hw_platform_0]
file mkdir $platform_dir
file copy -force $hdf_file [file join $platform_dir system.hdf]

puts "Hardware definition exported:"
puts "  $hdf_file"

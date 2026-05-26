set script_dir [file normalize [file dirname [info script]]]
set project_file [file join $script_dir mini_io.xpr]

if {[llength [get_projects -quiet]] == 0} {
    open_project $project_file
}

reset_run synth_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1

reset_run impl_1
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

set bit_file [file join $script_dir mini_io.runs impl_1 design_1_wrapper.bit]
if {![file exists $bit_file]} {
    error "Bitstream was not generated: $bit_file"
}

puts "Bitstream generated:"
puts "  $bit_file"

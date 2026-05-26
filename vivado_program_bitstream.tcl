set script_dir [file normalize [file dirname [info script]]]
set bit_file [file join $script_dir mini_io.runs impl_1 design_1_wrapper.bit]

open_hw
connect_hw_server
open_hw_target
set dev [lindex [get_hw_devices xc7a100t*] 0]
current_hw_device $dev
refresh_hw_device -update_hw_probes false $dev
set_property PROGRAM.FILE $bit_file $dev
program_hw_devices $dev
refresh_hw_device $dev
close_hw

puts "FPGA programmed with $bit_file"

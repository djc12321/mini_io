set script_dir [file normalize [file dirname [info script]]]
set bit_file [file join $script_dir mini_io.runs impl_1 design_1_wrapper.bit]
set elf_file [file join $script_dir mini_io.sdk mini_io_fast_interrupt Debug mini_io_fast_interrupt.elf]

connect
targets -set -filter {name =~ "xc7a100t*"}
fpga $bit_file
after 1000
targets -set -filter {name =~ "MicroBlaze #0*"}
rst -processor
dow $elf_file
con

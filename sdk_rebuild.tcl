# Run with Xilinx SDK 2018.2:
#   <Xilinx SDK>/bin/xsct.bat sdk_rebuild.tcl

set script_dir [file normalize [file dirname [info script]]]
setws [file join $script_dir mini_io.sdk]

updatehw -hw design_1_wrapper_hw_platform_0 \
    -newhwspec [file join $script_dir mini_io.sdk design_1_wrapper.hdf]

regenbsp -bsp mini_io_bsp
projects -build -type bsp -name mini_io_bsp
projects -build -type app -name mini_io

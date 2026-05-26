open_hw
connect_hw_server
set targets [get_hw_targets *]
puts "HW_TARGETS=$targets"
foreach target $targets {
    puts "OPEN_TARGET=$target"
    open_hw_target $target
    puts "HW_DEVICES=[get_hw_devices *]"
    close_hw_target
}
close_hw

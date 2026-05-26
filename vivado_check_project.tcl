set script_dir [file normalize [file dirname [info script]]]
open_project [file join $script_dir mini_io.xpr]
puts "PROJECT_OPENED=[current_project]"
puts "TOP=[get_property top [current_fileset]]"
close_project

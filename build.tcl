set project_dir [file dirname [file normalize [info script]]]
open_project [file join $project_dir z1013_display.gprj]
set_option -verilog_std sysv2017
set_option -top_module z1013_display_top
set_option -bit_security 0
set_option -use_sspi_as_gpio 1
run all

set_property SRC_FILE_INFO {cfile:D:/Vivado_Projects/Assignment_1/Assignment_1.srcs/constrs_1/new/cons.xdc rfile:../../../Assignment_1.srcs/constrs_1/new/cons.xdc id:1} [current_design]
set_property src_info {type:XDC file:1 line:82 export:INPUT save:INPUT read:READ} [current_design]
set_property PACKAGE_PIN Y9 [get_ports {clk}];  # "GCLK"
set_property src_info {type:XDC file:1 line:175 export:INPUT save:INPUT read:READ} [current_design]
set_property PACKAGE_PIN T22 [get_ports {counter[0]}];  # "LD0"
set_property src_info {type:XDC file:1 line:176 export:INPUT save:INPUT read:READ} [current_design]
set_property PACKAGE_PIN T21 [get_ports {counter[1]}];  # "LD1"
set_property src_info {type:XDC file:1 line:177 export:INPUT save:INPUT read:READ} [current_design]
set_property PACKAGE_PIN U22 [get_ports {counter[2]}];  # "LD2"
set_property src_info {type:XDC file:1 line:237 export:INPUT save:INPUT read:READ} [current_design]
set_property PACKAGE_PIN F22 [get_ports {rst_n}];  # "SW0"
set_property src_info {type:XDC file:1 line:363 export:INPUT save:INPUT read:READ} [current_design]
set_false_path -from rst_n -to counter_reg[0]/CLR
set_property src_info {type:XDC file:1 line:364 export:INPUT save:INPUT read:READ} [current_design]
set_false_path -from rst_n -to counter_reg[1]/CLR
set_property src_info {type:XDC file:1 line:365 export:INPUT save:INPUT read:READ} [current_design]
set_false_path -from rst_n -to counter_reg[2]/CLR
set_property src_info {type:XDC file:1 line:368 export:INPUT save:INPUT read:READ} [current_design]
set_false_path -from counter_reg[0]/C -to counter[0]
set_property src_info {type:XDC file:1 line:369 export:INPUT save:INPUT read:READ} [current_design]
set_false_path -from counter_reg[1]/C -to counter[1]
set_property src_info {type:XDC file:1 line:370 export:INPUT save:INPUT read:READ} [current_design]
set_false_path -from counter_reg[2]/C -to counter[2]
set_property src_info {type:XDC file:1 line:374 export:INPUT save:INPUT read:READ} [current_design]
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 33]];
set_property src_info {type:XDC file:1 line:384 export:INPUT save:INPUT read:READ} [current_design]
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 35]];
set_property src_info {type:XDC file:1 line:387 export:INPUT save:INPUT read:READ} [current_design]
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 13]];

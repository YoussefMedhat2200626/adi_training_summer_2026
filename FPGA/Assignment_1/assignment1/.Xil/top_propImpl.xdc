set_property SRC_FILE_INFO {cfile:{c:/Electronics - Analog and Digital/ADI/FPGA/Assignment_1/assignment1/assignment1.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xdc} rfile:../assignment1.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xdc id:1 order:EARLY scoped_inst:u_pll/inst} [current_design]
set_property SRC_FILE_INFO {cfile:{C:/Electronics - Analog and Digital/ADI/FPGA/Assignment_1/assignment1/assignment1.srcs/constrs_1/new/cons.xdc} rfile:../assignment1.srcs/constrs_1/new/cons.xdc id:2} [current_design]
set_property src_info {type:SCOPED_XDC file:1 line:57 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports clk_in1]] 0.1
set_property src_info {type:XDC file:2 line:116 export:INPUT save:INPUT read:READ} [current_design]
set_false_path -from rst_n -to counter_reg[0]/CLR
set_property src_info {type:XDC file:2 line:117 export:INPUT save:INPUT read:READ} [current_design]
set_false_path -from rst_n -to counter_reg[1]/CLR
set_property src_info {type:XDC file:2 line:118 export:INPUT save:INPUT read:READ} [current_design]
set_false_path -from rst_n -to counter_reg[2]/CLR
set_property src_info {type:XDC file:2 line:119 export:INPUT save:INPUT read:READ} [current_design]
set_false_path -from rst_n -to counter_reg[3]/CLR
set_property src_info {type:XDC file:2 line:121 export:INPUT save:INPUT read:READ} [current_design]
set_false_path -from counter_reg[0]/C -to counter[0]
set_property src_info {type:XDC file:2 line:122 export:INPUT save:INPUT read:READ} [current_design]
set_false_path -from counter_reg[1]/C -to counter[1]
set_property src_info {type:XDC file:2 line:123 export:INPUT save:INPUT read:READ} [current_design]
set_false_path -from counter_reg[2]/C -to counter[2]
set_property src_info {type:XDC file:2 line:124 export:INPUT save:INPUT read:READ} [current_design]
set_false_path -from counter_reg[3]/C -to counter[3]
set_property src_info {type:XDC file:2 line:397 export:INPUT save:INPUT read:READ} [current_design]
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 34]];

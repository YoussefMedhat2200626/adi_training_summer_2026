vlib work
vlog -f file_list.src +cover -covercells
vsim -voptargs=+acc work.tb_top

add wave -divider "Interface Signals"
add wave -position insertpoint sim:/tb_top/vif/*

add wave -divider "DUT Internal Signals"
add wave -position insertpoint sim:/tb_top/dut/*

run -all
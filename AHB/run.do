vlib work
vlog Master.sv Interconnection.sv slave.sv Top_wrapper.sv tb_AHB_Lite.sv
vsim -voptargs=+acc work.tb_ahb_system
add wave *
run -all
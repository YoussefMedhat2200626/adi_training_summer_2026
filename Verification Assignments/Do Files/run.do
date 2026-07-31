vlib work
vmap work work

vlog -work work -sv -stats=none "alu.sv" "alu_interface.sv" "alu_tb.sv"

vsim -voptargs=+acc work.alu_tb
do wave.do
run -all

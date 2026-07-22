vlib work
vlog ahb_shared_pkg.sv ahb_slave.sv ahb_slave_tb.sv
vsim -voptargs=+ work.ahb_slave_tb
add wave -radix Ufixed *
add wave -radix Ufixed -position insertpoint  \
sim:/ahb_slave_tb/uut/slave_mem \
sim:/ahb_slave_tb/uut/addr_reg \
sim:/ahb_slave_tb/uut/error_flag

run -all
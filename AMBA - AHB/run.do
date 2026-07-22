vlib work
vlog ahb_shared_pkg.sv ahb_master.sv ahb_master_tb.sv
vsim -voptargs=+ work.ahb_master_tb
add wave -radix Ufixed *
add wave -radix Ufixed -position insertpoint  \
sim:/ahb_master_tb/uut/ps \
sim:/ahb_master_tb/uut/addr_inc \
sim:/ahb_master_tb/uut/next_addr \
sim:/ahb_master_tb/uut/next_addr_sel \
sim:/ahb_master_tb/uut/beats_count
add wave -radix Ufixed -position insertpoint  \
sim:/ahb_master_tb/slave_mem
add wave -radix Ufixed -position insertpoint  \
sim:/ahb_master_tb/wr_addr
add wave -position insertpoint  \
sim:/ahb_master_tb/uut/ns
add wave -radix Ufixed -position insertpoint  \
sim:/ahb_master_tb/uut/wrap_size
add wave -radix Ufixed -position insertpoint  \
sim:/ahb_master_tb/uut/master_mem \
sim:/ahb_master_tb/uut/read_addr_buffer
add wave -radix Ufixed -position insertpoint  \
sim:/ahb_master_tb/uut/addr_ptr

run -all
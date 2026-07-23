vlib work
vlog DATA_FIFO.sv AHB_master.sv AHB_slave.sv AHB_wrapper.sv AHB_wrapper_tb.sv
vsim -voptargs=+acc work.AHB_wrapper_tb
add wave -position insertpoint  \
sim:/AHB_wrapper_tb/W_HCLK
add wave -position insertpoint  \
sim:/AHB_wrapper_tb/W_HRESETn
add wave -position insertpoint  \
sim:/AHB_wrapper_tb/W_ENABLE_S
add wave -position insertpoint  \
sim:/AHB_wrapper_tb/W_WRITE_S
add wave -position insertpoint  \
sim:/AHB_wrapper_tb/W_BURST_S
add wave -position insertpoint  \
sim:/AHB_wrapper_tb/W_ADDR_S
add wave -position insertpoint  \
sim:/AHB_wrapper_tb/dut/master/HWRITE
add wave -position insertpoint  \
sim:/AHB_wrapper_tb/dut/master/HTRANS
add wave -position insertpoint  \
sim:/AHB_wrapper_tb/dut/master/HSIZE
add wave -position insertpoint  \
sim:/AHB_wrapper_tb/dut/master/HPROT
add wave -position insertpoint  \
sim:/AHB_wrapper_tb/dut/master/HMASTLOCK
add wave -position insertpoint  \
sim:/AHB_wrapper_tb/dut/master/HBURST
add wave -position insertpoint  \
sim:/AHB_wrapper_tb/dut/master/HWDATA
add wave -position insertpoint  \
sim:/AHB_wrapper_tb/dut/master/HADDR
add wave -position insertpoint  \
sim:/AHB_wrapper_tb/dut/master/HREADY
add wave -position insertpoint  \
sim:/AHB_wrapper_tb/dut/master/HRESP
add wave -position insertpoint  \
sim:/AHB_wrapper_tb/pass_count \
sim:/AHB_wrapper_tb/error_count
add wave -position insertpoint  \
sim:/AHB_wrapper_tb/dut/slave/mem
run -all
#quit -sim 
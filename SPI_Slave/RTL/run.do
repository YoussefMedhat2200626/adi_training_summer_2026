vlib work
vlog reg_map.sv spi_slave.sv spi_wrapper.sv wrapper_tb.sv
vsim -voptargs=+acc work.wrapper_tb
add wave -position insertpoint  \
sim:/wrapper_tb/dut/spi/SCLK
add wave -position insertpoint  \
sim:/wrapper_tb/dut/spi/CSB
add wave -position insertpoint  \
sim:/wrapper_tb/dut/spi/SDI
add wave -position insertpoint  \
sim:/wrapper_tb/dut/spi/rd_data
add wave -position insertpoint  \
sim:/wrapper_tb/dut/spi/state
add wave -position insertpoint  \
sim:/wrapper_tb/dut/spi/SDO
add wave -position insertpoint  \
sim:/wrapper_tb/dut/spi/wr_en
add wave -position insertpoint  \
sim:/wrapper_tb/dut/spi/SDO_en
add wave -position insertpoint  \
sim:/wrapper_tb/dut/spi/wr_data
add wave -position insertpoint  \
sim:/wrapper_tb/dut/spi/addr
add wave -position insertpoint  \
sim:/wrapper_tb/dut/spi/cnt
add wave -position insertpoint  \
sim:/wrapper_tb/error_count
add wave -position insertpoint  \
sim:/wrapper_tb/correct_count
add wave -position insertpoint  \
sim:/wrapper_tb/dut/ram/mem
run -all
#wave zoom full
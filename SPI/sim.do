vlib work
vlog *.sv
vsim -voptargs=+ work.spi_slave_wrapper_tb
add wave -radix Ufixed *

add wave -radix Ufixed -position insertpoint  \
sim:/spi_slave_wrapper_tb/u_dut/u_reg_map/addr \
sim:/spi_slave_wrapper_tb/u_dut/u_reg_map/wr_data \
sim:/spi_slave_wrapper_tb/u_dut/u_reg_map/rd_data \
sim:/spi_slave_wrapper_tb/u_dut/u_reg_map/ram \
sim:/spi_slave_wrapper_tb/u_dut/u_reg_map/offset
add wave -radix Ufixed -position insertpoint  \
sim:/spi_slave_wrapper_tb/u_dut/u_spi_slave/addr_reg


add wave -radix Ufixed -position insertpoint  \
sim:/spi_slave_wrapper_tb/u_dut/u_spi_slave/wr_data \
sim:/spi_slave_wrapper_tb/u_dut/u_spi_slave/rd_data

add wave -position insertpoint  \
sim:/spi_slave_wrapper_tb/u_dut/u_spi_slave/ps

add wave -radix Ufixed -position insertpoint  \
sim:/spi_slave_wrapper_tb/u_dut/u_spi_slave/wr_addr_cnt \
sim:/spi_slave_wrapper_tb/u_dut/u_spi_slave/rd_addr_cnt \
sim:/spi_slave_wrapper_tb/u_dut/u_spi_slave/wr_data_cnt \
sim:/spi_slave_wrapper_tb/u_dut/u_spi_slave/rd_data_cnt \
sim:/spi_slave_wrapper_tb/u_dut/u_spi_slave/wr_data_reg

add wave -position insertpoint  \
sim:/spi_slave_wrapper_tb/u_dut/u_spi_slave/CLK
add wave -position insertpoint  \
sim:/spi_slave_wrapper_tb/u_dut/u_spi_slave/wr_en
run -all

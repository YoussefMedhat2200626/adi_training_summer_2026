vlog spi_slave.v 
vlog register_map.v 
vlog spi_top.v 
vlog tb_spi_slave.v
vsim -voptargs=+acc work.tb_spi_slave
# 5. Add waves for debugging
add wave -noupdate -divider "SPI Master / Pins"
add wave -noupdate -color Yellow /tb_spi_slave/tb_csb
add wave -noupdate -color White  /tb_spi_slave/tb_sclk
add wave -noupdate -color Green  /tb_spi_slave/tb_sdi
add wave -noupdate -color Cyan   /tb_spi_slave/tb_sdo

add wave -noupdate -divider "FSM & Control"
add wave -noupdate -radix unsigned /tb_spi_slave/u_spi_top/u_spi_slave/state
add wave -noupdate -radix unsigned /tb_spi_slave/u_spi_top/u_spi_slave/bit_cnt
add wave -noupdate /tb_spi_slave/u_spi_top/u_spi_slave/rw_bit

add wave -noupdate -divider "Register Map Interface"
add wave -noupdate -radix hex /tb_spi_slave/u_spi_top/addr
add wave -noupdate /tb_spi_slave/u_spi_top/wr_en
add wave -noupdate -radix hex /tb_spi_slave/u_spi_top/wr_data
add wave -noupdate -radix hex /tb_spi_slave/u_spi_top/rd_data

# 6. Format the waveform window
configure wave -namecolwidth 250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2

# 7. Run the simulation
run -all

# 8. Zoom to fit the full transaction history
wave zoom full
vlib work
vlog +cover=bcestfx ALU.sv interface.sv test.sv transaction.sv generator.sv driver.sv monitor.sv environment.sv scoreboard.sv agent.sv
vsim -coverage -voptargs=+acc -assertdebug tb
add wave -r /tb/*
run -all
coverage save ALU.ucdb
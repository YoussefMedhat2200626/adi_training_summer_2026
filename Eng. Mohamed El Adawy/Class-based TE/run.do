
quit -sim

vlib work
vmap work work

vlog -sv +incdir+. alu.sv
vlog -sv +incdir+. intf.sv
vlog -sv +incdir+. transaction.sv
vlog -sv +incdir+. generator.sv
vlog -sv +incdir+. driver.sv
vlog -sv +incdir+. monitor.sv
vlog -sv +incdir+. scoreboard.sv
vlog -sv +incdir+. agent.sv
vlog -sv +incdir+. environment.sv
vlog -sv +incdir+. test.sv
vlog -sv +incdir+. tb.sv

vsim -voptargs=+acc work.tb

run -all
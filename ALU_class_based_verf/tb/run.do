vlib work
vlog interface.sv ALU_design.sv package.sv test.sv
vsim -voptargs=+acc work.alu_test
add wave -position insertpoint  \
sim:/alu_test/alu_if/clk \
sim:/alu_test/alu_if/rst_n \
sim:/alu_test/alu_if/A \
sim:/alu_test/alu_if/B \
sim:/alu_test/alu_if/opcode \
sim:/alu_test/alu_if/ALU_Out 
run -all
#quit -sim 
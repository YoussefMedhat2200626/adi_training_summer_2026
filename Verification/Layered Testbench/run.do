vlib work

vlog -sv -mfcu \
    ALU_shared_pkg.sv \
    ALU_transaction_pkg.sv \
    ALU_if.sv \
    ALU_cvg_pkg.sv \
    ALU.sv \
    ALU_generator.sv \
    ALU_driver.sv \
    ALU_monitor.sv \
    ALU_agent.sv \
    ALU_subscriber.sv \
    ALU_scoreboard.sv \
    ALU_env.sv \
    ALU_test.sv \
    ALU_tb.sv \
    +cover=bcesfx +define+SIM


vsim -voptargs="+acc +cover=bcesfx" work.ALU_tb -coverage

add wave -radix decimal *
add wave -radix decimal -position insertpoint  \
sim:/ALU_tb/alu_if/rst_n \
sim:/ALU_tb/alu_if/A \
sim:/ALU_tb/alu_if/B \
sim:/ALU_tb/alu_if/opcode \
sim:/ALU_tb/alu_if/ALU_OUT \
sim:/ALU_tb/alu_if/carry_flag \
sim:/ALU_tb/alu_if/arith_flag \
sim:/ALU_tb/alu_if/logic_flag \
sim:/ALU_tb/alu_if/zero_flag

add wave -radix decimal -position insertpoint  \
sim:/ALU_shared_pkg::error_count \
sim:/ALU_shared_pkg::correct_count

add wave -position insertpoint  \
sim:/ALU_shared_pkg::test_finished
run -all

coverage save ALU_tb.ucdb 

vcover report ALU_tb.ucdb -details -annotate -all -output coverage_rpt.txt

coverage report -detail -cvg -directive -comments -output fcover_report.txt
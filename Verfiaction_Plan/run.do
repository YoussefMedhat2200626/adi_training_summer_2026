vlib work

vlog -sv -mfcu +incdir+. \
    alu_if.sv \
    alu_pkg.sv \
    alu_cvg_pkg.sv \
    alu_agent.sv \
    test.sv \
    alu.sv \
    tb_top.sv \
    +cover=bcesfx +define+SIM

vsim -voptargs="+acc +cover=bcesfx" work.tb_top -coverage

add wave -radix decimal *
add wave -radix decimal -position insertpoint  \
sim:/tb_top/vif/RST \
sim:/tb_top/vif/A \
sim:/tb_top/vif/B \
sim:/tb_top/vif/OP \
sim:/tb_top/vif/Result \
sim:/tb_top/vif/Carry_Flag \
sim:/tb_top/vif/Arithm_FLag \
sim:/tb_top/vif/Logic_Flag \
sim:/tb_top/vif/Zero_Flag



run -all

coverage save tb_top.ucdb
vcover report tb_top.ucdb -details -annotate -all -output coverage_rpt.txt
coverage report -detail -cvg -directive -comments -output fcover_report.txt
coverage report -cvg -directive -comments
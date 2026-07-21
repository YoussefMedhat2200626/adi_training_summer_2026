# ============================================================================
# QUESTA / MODELSIM TCL AUTOMATION SCRIPT (run.do)
# ============================================================================

# 1. Close any running simulation
quit -sim -f

# 2. Clear old working library
if {[file exists work]} {
    vdel -lib work -all
}

# 3. Create fresh working library
vlib work
vmap work work

# 4. Compile RTL and Testbench (+cover enables Code Coverage)
vlog -sv +cover +incdir+. ALU.v alu_interface.sv alu_pkg.sv tb_top.sv

# 5. Elaborate design with Coverage enabled
vsim -coverage tb_top

# 6. Execute Simulation
run -all

# 7. Output report to Transcript
coverage report -detail -cvg

# 8. Export Coverage Report to a TXT File
coverage report -file coverage_report.txt -detail -cvg -codeAll

echo "=================================================="
echo " Coverage report saved to: coverage_report.txt"
echo "=================================================="
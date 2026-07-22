# ============================================================
#  Makefile - ALU class-based testbench
#  Works with QuestaSim/ModelSim. For VCS or Xcelium, swap the
#  compile/run commands in the 'sim' target accordingly.
# ============================================================

TOP    = tb
FILES  = alu.sv intf.sv tb.sv

.PHONY: all sim clean

all: sim

sim:
	vlog $(FILES)
	vsim -c -do "run -all; quit" $(TOP)

# Icarus Verilog note:
# iverilog's SystemVerilog class/randomize/covergroup support is
# incomplete, so this testbench should be run on a full SV simulator
# (QuestaSim, VCS, Xcelium). tb.sv `includes` every class file, so
# only alu.sv, intf.sv and tb.sv need to be listed as top-level files.

clean:
	rm -rf work transcript vsim.wlf *.log

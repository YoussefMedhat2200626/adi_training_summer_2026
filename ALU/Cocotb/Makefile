# QuestaSim
SIM ?= questa
TOPLEVEL_LANG ?= verilog

# Include your interface and DUT files
VERILOG_SOURCES += $(PWD)/ALU_if.sv
VERILOG_SOURCES += $(PWD)/alu.sv

# The top-level module
TOPLEVEL = alu

# The name of the Python test file
MODULE = test_alu

# Include standard cocotb makefile rules
include $(shell cocotb-config --makefiles)/Makefile.sim
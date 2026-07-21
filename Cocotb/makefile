TOPLEVEL_LANG = verilog

VERILOG_SOURCES := $(CURDIR)/rtl/alu.sv
TOPLEVEL := alu

COCOTB_TEST_MODULES := test_alu
PYTHONPATH := $(CURDIR)/tests

SIM := icarus

export PYTHONPATH

include $(shell cocotb-config --makefiles)/Makefile.sim

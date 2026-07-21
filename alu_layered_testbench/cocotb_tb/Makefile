# Makefile following the ADI Cocotb Session Slides (Slide 16)

# Simulator
SIM ?= questa

# Top level language
TOPLEVEL_LANG ?= verilog
PWD=$(shell pwd)

# RTL Source files (Pointing to our uploaded ALU design)
VERILOG_SOURCES = $(PWD)/../rtl/alu.sv

# Top level module in the RTL (Module_NAME from slides)
TOPLEVEL = alu

# Name of the Python test file without .py (File_Python_Name from slides)
MODULE = test_alu

# Tell cocotb where to find the test
export PYTHONPATH := $(PWD):$(PYTHONPATH)

# Include the cocotb makefiles (Slide 16)
include $(shell cocotb-config --makefiles)/Makefile.sim

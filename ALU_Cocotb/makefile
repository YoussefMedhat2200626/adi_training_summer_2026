TOPLEVEL_LANG ?= verilog
SIM ?= icarus
PWD=$(shell pwd)

ifeq ($(TOPLEVEL_LANG),verilog)
    VERILOG_SOURCES = $(PWD)/ALU_design.sv
else ifeq ($(TOPLEVEL_LANG),vhdl)
    VHDL_SOURCES = $(PWD)/ALU_design.vhdl
else
    $(error A valid value (verilog or vhdl) was not provided for TOPLEVEL_LANG=$(TOPLEVEL_LANG))
endif

TOPLEVEL := ALU              #Module_NAME
MODULE   := my_coco_tb       #File_Python_Name

include $(shell cocotb-config --makefiles)/Makefile.sim
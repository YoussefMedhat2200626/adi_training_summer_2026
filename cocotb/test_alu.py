import cocotb
from cocotb.clock import Clock
from cocotb.triggers import *

async def driving_stimulus(dut):
    await FallingEdge(dut.clk)
    dut.rst.value = 0
    await FallingEdge(dut.clk)
    dut.rst.value = 1

    dut.Opcode.value = 0
    dut.A.value = 5
    dut.B.value = 3
    dut.Cin.value = 0
    await RisingEdge(dut.clk)
    await ReadOnly()
    cocotb.log.info("Add result : " + str(dut.Result.value))

    await FallingEdge(dut.clk)
    dut.Opcode.value = 1
    dut.A.value = 10
    dut.B.value = 4
    await RisingEdge(dut.clk)
    await ReadOnly()
    cocotb.log.info("Sub result : " + str(dut.Result.value))

    await FallingEdge(dut.clk)
    dut.Opcode.value = 2
    dut.A.value = 12
    dut.B.value = 10
    await RisingEdge(dut.clk)
    await ReadOnly()
    cocotb.log.info("AND result : " + str(dut.Result.value))

    await FallingEdge(dut.clk)
    dut.Opcode.value = 3
    dut.A.value = 12
    dut.B.value = 3
    await RisingEdge(dut.clk)
    await ReadOnly()
    cocotb.log.info("OR result : " + str(dut.Result.value))


@cocotb.test()
async def tb_top(dut):
    cocotb.log.info(" Start sim ")
    
    CLK = Clock(dut.clk, 10, units="ns")
    dut.rst.value = 0
    
    await cocotb.start(CLK.start())
    await cocotb.start_soon(driving_stimulus(dut))
    
    cocotb.log.info(" After driving stimulus")
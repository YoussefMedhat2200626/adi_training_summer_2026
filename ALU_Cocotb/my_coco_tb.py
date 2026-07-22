import cocotb
from cocotb.clock import Clock
from cocotb.triggers import *
import random

async def drive_arithmetic(dut):
    # Assert reset
    dut.rst_n.value = 0
    dut.A.value = 1
    dut.B.value = 1
    dut.opcode.value = 0

    await FallingEdge(dut.clk)
    
    out = int(dut.ALU_Out.value)
    expected = 0

    if expected == out:
        print("Pass")
        print("expected , ALU_OUT", expected, out)
    else:
        print("Fail")
        print("expected , ALU_OUT", expected, out)
    
    # Deassert reset & make addition operation (Directed test case)
    dut.rst_n.value = 1
    dut.A.value = 1
    dut.B.value = 1
    dut.opcode.value = 0

    await FallingEdge(dut.clk)
    
    out = int(dut.ALU_Out.value)
    expected = 2

    if expected == out:
        print("Pass")
        print("expected , ALU_OUT", expected, out)
    else:
        print("Fail")
        print("expected , ALU_OUT", expected, out)

    # make subtraction operation (Directed test case)
    dut.rst_n.value = 1
    dut.A.value = 1
    dut.B.value = 1
    dut.opcode.value = 1

    await FallingEdge(dut.clk)
    
    out = int(dut.ALU_Out.value)
    expected = 0

    if expected == out:
        print("Pass")
        print("expected , ALU_OUT", expected, out)
    else:
        print("Fail")
        print("expected , ALU_OUT", expected, out)

    # randomized addition & subtraction operations
    for i in range(10):
        a = random.randint(0,15)
        b = random.randint(0,15)
        op = random.choice([0,1])

        dut.A.value = a
        dut.B.value = b
        dut.opcode.value = op

        await FallingEdge(dut.clk)

        out = int(dut.ALU_Out.value)

        if op == 0:
            expected = (a + b) & 0xF
            if expected == out:
                print("Pass")
                print("expected , ALU_OUT", expected, out)
            else:
                print("Fail")
                print("expected , ALU_OUT", expected, out)

        else:
            expected = (a - b) & 0xF
            if expected == out:
                print("Pass")
                print("expected , ALU_OUT", expected, out)
            else:
                print("Fail")
                print("expected , ALU_OUT", expected, out)


async def drive_logical(dut):
    # Assert reset
    dut.rst_n.value = 0
    dut.A.value = 1
    dut.B.value = 1
    dut.opcode.value = 2

    await FallingEdge(dut.clk)
    
    out = int(dut.ALU_Out.value)
    expected = 0

    if expected == out:
        print("Pass")
        print("expected , ALU_OUT", expected, out)
    else:
        print("Fail")
        print("expected , ALU_OUT", expected, out)
    
    # Deassert reset & make adding operation
    dut.rst_n.value = 1
    dut.A.value = 1
    dut.B.value = 1
    dut.opcode.value = 2

    await FallingEdge(dut.clk)
    
    out = int(dut.ALU_Out.value)
    expected = 1

    if expected == out:
        print("Pass")
        print("expected , ALU_OUT", expected, out)
    else:
        print("Fail")
        print("expected , ALU_OUT", expected, out)

    # make oring operation
    dut.rst_n.value = 1
    dut.A.value = 1
    dut.B.value = 1
    dut.opcode.value = 3

    await FallingEdge(dut.clk)
    
    out = int(dut.ALU_Out.value)
    expected = 1

    if expected == out:
        print("Pass")
        print("expected , ALU_OUT", expected, out)
    else:
        print("Fail")
        print("expected , ALU_OUT", expected, out)

    # randomized adding & oring operations
    for i in range(10):
        a = random.randint(0,15)
        b = random.randint(0,15)
        op = random.choice([2,3])

        dut.A.value = a
        dut.B.value = b
        dut.opcode.value = op

        await FallingEdge(dut.clk)

        out = int(dut.ALU_Out.value)

        if op == 2:
            expected = a & b
            if expected == out:
                print("Pass")
                print("expected , ALU_OUT", expected, out)
            else:
                print("Fail")
                print("expected , ALU_OUT", expected, out)

        else:
            expected = a | b
            if expected == out:
                print("Pass")
                print("expected , ALU_OUT", expected, out)
            else:
                print("Fail")
                print("expected , ALU_OUT", expected, out)

@cocotb.test()
async def alu_tb(dut):
    print("Starting Simulation")
    clk = Clock(dut.clk, 5, units="ns")
    cocotb.start_soon(clk.start())
    await cocotb.start_soon(drive_arithmetic(dut))
    await cocotb.start_soon(drive_logical(dut))
    print("After start coroutine")

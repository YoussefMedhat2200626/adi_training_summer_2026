import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, ReadOnly

ARITH_OPCODES = [0, 1]   
LOGIC_OPCODES = [2, 3]   


@cocotb.test()
async def tb_top(dut):
    cocotb.log.info("Starting sim")
    clk = Clock(dut.clk, 10, unit="ns")
    dut.rst_n.value = 0
    await cocotb.start(clk.start())

    await FallingEdge(dut.clk)
    dut.rst_n.value = 1

    await arith_stimulus(dut)
    await logic_stimulus(dut)

    cocotb.log.info("End sim")


async def arith_stimulus(dut):

    opcodes = random.sample(ARITH_OPCODES, k=len(ARITH_OPCODES))
    for opcode in opcodes:
        await FallingEdge(dut.clk)
        dut.A.value = random.randint(-128, 127)
        dut.B.value = random.randint(-128, 127)
        dut.opcode.value = opcode
        await RisingEdge(dut.clk)
        await ReadOnly()
        cocotb.log.info(
            f"[ARITH] opcode={opcode} A={int(dut.A.value.signed_integer)} "
            f"B={int(dut.B.value.signed_integer)} "
            f"ALU_OUT={int(dut.ALU_OUT.value.signed_integer)} "
            f"carry_flag={dut.carry_flag.value} arith_flag={dut.arith_flag.value}"
        )


async def logic_stimulus(dut):
    # Same idea for the two logic opcodes: AND and XOR, each exactly once,
    # in random order.
    opcodes = random.sample(LOGIC_OPCODES, k=len(LOGIC_OPCODES))
    for opcode in opcodes:
        await FallingEdge(dut.clk)
        dut.A.value = random.randint(-128, 127)
        dut.B.value = random.randint(-128, 127)
        dut.opcode.value = opcode
        await RisingEdge(dut.clk)
        await ReadOnly()
        cocotb.log.info(
            f"[LOGIC] opcode={opcode} A={int(dut.A.value.signed_integer)} "
            f"B={int(dut.B.value.signed_integer)} "
            f"ALU_OUT={int(dut.ALU_OUT.value.signed_integer)} "
            f"logic_flag={dut.logic_flag.value}"
        )
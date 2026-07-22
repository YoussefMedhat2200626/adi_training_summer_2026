import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ReadOnly
import random


def golden_model(a, b, op):

    if op == 0:
        return (a + b) & 0xff

    elif op == 1:
        return (a - b) & 0xff

    elif op == 2:
        return a & b

    else:
        return a | b


async def reset_dut(dut):

    dut.rst.value = 0
    dut.a.value = 0
    dut.b.value = 0
    dut.alu_fun.value = 0

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    dut.rst.value = 1

    await RisingEdge(dut.clk)


async def drive_stimulus(dut):

    cocotb.log.info("Starting stimulus")

    for i in range(20):

        a = random.randint(0,255)
        b = random.randint(0,255)
        op = random.randint(0,3)

        dut.a.value = a
        dut.b.value = b
        dut.alu_fun.value = op

        await RisingEdge(dut.clk)
        await RisingEdge(dut.clk)

        actual = dut.alu_out.value.integer
        expected = golden_model(a,b,op)

        cocotb.log.info(
            f"TEST {i} : "
            f"A={a} "
            f"B={b} "
            f"OP={op} "
            f"OUT={actual}"
        )

        assert actual == expected, \
            f"Mismatch! expected={expected} got={actual}"

    cocotb.log.info("All tests passed")


@cocotb.test()
async def alu_test(dut):

    cocotb.log.info("========== STARTING ALU TEST ==========")

    cocotb.start_soon(Clock(dut.clk,10,units="ns").start())

    await reset_dut(dut)

    await drive_stimulus(dut)

    cocotb.log.info("========== TEST FINISHED ==========")
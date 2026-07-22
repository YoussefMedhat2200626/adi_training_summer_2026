


import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer, ReadOnly

OP_ADD = 0b00
OP_SUB = 0b01
OP_AND = 0b10
OP_OR  = 0b11


async def start_clock(dut):
    cocotb.start_soon(Clock(dut.CLK, 10, unit="ns").start())


async def reset_dut(dut):
    dut.RST.value = 0
    dut.A.value = 0
    dut.B.value = 0
    dut.OP.value = 0
    await Timer(20, unit="ns")
    dut.RST.value = 1
    await RisingEdge(dut.CLK)


async def apply_op(dut, a, b, op):
    await RisingEdge(dut.CLK)
    dut.A.value = a
    dut.B.value = b
    dut.OP.value = op
    await RisingEdge(dut.CLK)
    await ReadOnly() 



async def test_add(dut):
    a, b = 5, 3
    await apply_op(dut, a, b, OP_ADD)

    expected = (a + b) & 0xF
    dut._log.info(
        f"ADD: A={a} B={b} -> Result={int(dut.Result.value)} "
        f"Carry_Flag={int(dut.Carry_Flag.value)} Arithm_FLag={int(dut.Arithm_FLag.value)} "
        f"Logic_Flag={int(dut.Logic_Flag.value)} Zero_Flag={int(dut.Zero_Flag.value)} "
        f"(expected Result={expected})"
    )
    assert dut.Result.value == expected, f"ADD: expected {expected}, got {int(dut.Result.value)}"
    assert dut.Arithm_FLag.value == 1
    assert dut.Logic_Flag.value == 0


async def test_sub(dut):
    a, b = 5, 3
    await apply_op(dut, a, b, OP_SUB)

    expected = (a - b) & 0xF
    dut._log.info(
        f"SUB: A={a} B={b} -> Result={int(dut.Result.value)} "
        f"Carry_Flag={int(dut.Carry_Flag.value)} Arithm_FLag={int(dut.Arithm_FLag.value)} "
        f"Logic_Flag={int(dut.Logic_Flag.value)} Zero_Flag={int(dut.Zero_Flag.value)} "
        f"(expected Result={expected})"
    )
    assert dut.Result.value == expected, f"SUB: expected {expected}, got {int(dut.Result.value)}"
    assert dut.Arithm_FLag.value == 1
    assert dut.Logic_Flag.value == 0


async def test_and(dut):
    a, b = 0b1100, 0b1010
    await apply_op(dut, a, b, OP_AND)

    expected = a & b
    dut._log.info(
        f"AND: A={a:#06b} B={b:#06b} -> Result={int(dut.Result.value):#06b} "
        f"Carry_Flag={int(dut.Carry_Flag.value)} Arithm_FLag={int(dut.Arithm_FLag.value)} "
        f"Logic_Flag={int(dut.Logic_Flag.value)} Zero_Flag={int(dut.Zero_Flag.value)} "
        f"(expected Result={expected:#06b})"
    )
    assert dut.Result.value == expected, f"AND: expected {expected}, got {int(dut.Result.value)}"
    assert dut.Arithm_FLag.value == 0
    assert dut.Logic_Flag.value == 1


async def test_or(dut):
    a, b = 0b1100, 0b1010
    await apply_op(dut, a, b, OP_OR)

    expected = a | b
    dut._log.info(
        f"OR: A={a:#06b} B={b:#06b} -> Result={int(dut.Result.value):#06b} "
        f"Carry_Flag={int(dut.Carry_Flag.value)} Arithm_FLag={int(dut.Arithm_FLag.value)} "
        f"Logic_Flag={int(dut.Logic_Flag.value)} Zero_Flag={int(dut.Zero_Flag.value)} "
        f"(expected Result={expected:#06b})"
    )
    assert dut.Result.value == expected, f"OR: expected {expected}, got {int(dut.Result.value)}"
    assert dut.Arithm_FLag.value == 0
    assert dut.Logic_Flag.value == 1


@cocotb.test()
async def test_case_add(dut):
    await start_clock(dut)
    await reset_dut(dut)
    await test_add(dut)


@cocotb.test()
async def test_case_sub(dut):
    await start_clock(dut)
    await reset_dut(dut)
    await test_sub(dut)


@cocotb.test()
async def test_case_and(dut):
    await start_clock(dut)
    await reset_dut(dut)
    await test_and(dut)


@cocotb.test()
async def test_case_or(dut):
    await start_clock(dut)
    await reset_dut(dut)
    await test_or(dut)

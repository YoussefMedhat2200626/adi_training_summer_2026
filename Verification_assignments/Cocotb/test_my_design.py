import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import *
from cocotb.handle import Force, Release, Freeze, Deposit

OP_ADD = 0b00
OP_SUB = 0b01
OP_AND = 0b10
OP_OR  = 0b11

N        = 4                       
MASK     = (1 << N) - 1            
EXT_MASK = (1 << (N + 1)) - 1      


def expected_result(a, b, opsel):
    """Golden model matching the RTL's  {Carry, Out} <= ...  behaviour."""
    if opsel == OP_ADD:
        res = (a + b) & EXT_MASK
    elif opsel == OP_SUB:
        res = (a - b) & EXT_MASK
    elif opsel == OP_AND:
        res = (a & b) & EXT_MASK
    else:  
        res = (a | b) & EXT_MASK

    carry = (res >> N) & 1
    out   = res & MASK
    return out, carry


async def reset_dut(dut, cycles=3):
    dut.RST.value    = 0     
    dut.A.value      = 0
    dut.B.value      = 0
    dut.OpSel.value  = 0

    for _ in range(cycles):
        await FallingEdge(dut.CLK)

    dut.RST.value = 1
    await FallingEdge(dut.CLK)
    dut._log.info("Reset released")


async def drive_and_check(dut, a, b, opsel, op_name):
    await FallingEdge(dut.CLK)
    dut.A.value     = a
    dut.B.value     = b
    dut.OpSel.value = opsel

    await RisingEdge(dut.CLK)
    await ReadOnly()               

    exp_out, exp_carry = expected_result(a, b, opsel)
    got_out   = int(dut.Out.value)
    got_carry = int(dut.Carry.value)

    if got_out == exp_out and got_carry == exp_carry:
        dut._log.info(
            f"PASS [{op_name}] A={a} B={b} -> Out={got_out} Carry={got_carry}"
        )
        return True

    dut._log.error(
        f"FAIL [{op_name}] A={a} B={b} OpSel={opsel:02b} -> "
        f"got Out={got_out} Carry={got_carry}, "
        f"exp Out={exp_out} Carry={exp_carry}"
    )
    return False


async def arithmetic_driver(dut, n_transactions=25):
    passed = 0
    for _ in range(n_transactions):
        a       = random.randint(0, MASK)
        b       = random.randint(0, MASK)
        opsel   = random.choice([OP_ADD, OP_SUB])
        op_name = "ADD" if opsel == OP_ADD else "SUB"
        passed += await drive_and_check(dut, a, b, opsel, op_name)

    dut._log.info(f"Arithmetic driver done: {passed}/{n_transactions} passed")
    return passed, n_transactions


async def logic_driver(dut, n_transactions=25):
    passed = 0
    for _ in range(n_transactions):
        a       = random.randint(0, MASK)
        b       = random.randint(0, MASK)
        opsel   = random.choice([OP_AND, OP_OR])
        op_name = "AND" if opsel == OP_AND else "OR"
        passed += await drive_and_check(dut, a, b, opsel, op_name)

    dut._log.info(f"Logic driver done: {passed}/{n_transactions} passed")
    return passed, n_transactions


@cocotb.test()
async def tb_top(dut):
    dut._log.info("STARTING SIMULATION")

    clk = Clock(dut.CLK, 10, units="ns")
    await cocotb.start(clk.start())

    await reset_dut(dut)

    dut._log.info("=== Running arithmetic driver (ADD/SUB) ===")
    arith_pass, arith_total = await arithmetic_driver(dut, n_transactions=25)

    dut._log.info("=== Running logic driver (AND/OR) ===")
    logic_pass, logic_total = await logic_driver(dut, n_transactions=25)

    total_pass = arith_pass + logic_pass
    total_txn  = arith_total + logic_total
    dut._log.info(f"SUMMARY: {total_pass}/{total_txn} transactions passed")

    assert total_pass == total_txn, f"{total_txn - total_pass} transaction(s) failed!"

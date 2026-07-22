"""
File: sequences.py
Purpose: Contains stimulus generation routines for the ALU testbench.
"""
import random
import cocotb
from constants import ALUOpcode, MAX_8BIT, MIN_8BIT
from driver import ALUDriver
from monitor import ALUMonitor

async def opcode_sweep_sequence(driver: ALUDriver, monitor: ALUMonitor) -> None:
    cocotb.log.info("--- Starting Opcode Sweep Sequence ---")
    for opcode in ALUOpcode:
        await driver.drive(a=0x55, b=0xAA, opcode=opcode)
        await monitor.capture_transaction()

async def boundary_sequence(driver: ALUDriver, monitor: ALUMonitor) -> None:
    cocotb.log.info("--- Starting Boundary Sequence ---")
    boundary_values = [0x00, 0x01, 0x7F, 0x80, 0xFE, 0xFF]
    for a in boundary_values:
        for b in boundary_values:
            for opcode in [ALUOpcode.ADD, ALUOpcode.SUB, ALUOpcode.INC, ALUOpcode.DEC]:
                await driver.drive(a=a, b=b, opcode=opcode)
                await monitor.capture_transaction()

async def carry_sequence(driver: ALUDriver, monitor: ALUMonitor) -> None:
    cocotb.log.info("--- Starting Carry Sequence ---")
    add_carry_pairs = [(0xFF, 0x01), (0x80, 0x80), (0xFE, 0x02), (0xFF, 0xFF)]
    for a, b in add_carry_pairs:
        await driver.drive(a=a, b=b, opcode=ALUOpcode.ADD)
        await monitor.capture_transaction()

    sub_carry_pairs = [(0x00, 0x01), (0x10, 0x20), (0x00, 0xFF), (0x7F, 0x80)]
    for a, b in sub_carry_pairs:
        await driver.drive(a=a, b=b, opcode=ALUOpcode.SUB)
        await monitor.capture_transaction()

async def zero_flag_sequence(driver: ALUDriver, monitor: ALUMonitor) -> None:
    cocotb.log.info("--- Starting Zero Flag Sequence ---")
    zero_cases = [
        (0x00, 0x00, ALUOpcode.PASS_A),
        (0x80, 0x80, ALUOpcode.ADD),
        (0x42, 0x42, ALUOpcode.SUB),
        (0xFF, 0x00, ALUOpcode.INC),
        (0x01, 0x00, ALUOpcode.DEC),
        (0xF0, 0x0F, ALUOpcode.AND),
        (0x00, 0x00, ALUOpcode.OR),
        (0xFF, 0x00, ALUOpcode.NOT)
    ]
    for a, b, opcode in zero_cases:
        await driver.drive(a=a, b=b, opcode=opcode)
        await monitor.capture_transaction()

async def carryout_clearing_sequence(driver: ALUDriver, monitor: ALUMonitor) -> None:
    cocotb.log.info("--- Starting Carryout Clearing Sequence ---")
    non_arithmetic_opcodes = [ALUOpcode.PASS_A, ALUOpcode.INC, ALUOpcode.DEC, ALUOpcode.AND, ALUOpcode.OR, ALUOpcode.NOT]
    for non_arith_op in non_arithmetic_opcodes:
        await driver.drive(a=0xFF, b=0x01, opcode=ALUOpcode.ADD)
        await monitor.capture_transaction()
        await driver.drive(a=0xFF, b=0xFF, opcode=non_arith_op)
        await monitor.capture_transaction()

async def exhaustive_coverage_sequence(driver: ALUDriver, monitor: ALUMonitor) -> None:
    """Directed sequence to guarantee 100% on Result Space and Operand Patterns."""
    cocotb.log.info("--- Starting Exhaustive Coverage Sweep ---")
    
    # 1. Guarantee 100% Result Space Coverage (0 to 255)
    for i in range(256):
        await driver.drive(a=i, b=0x00, opcode=ALUOpcode.PASS_A)
        await monitor.capture_transaction()
        
    # 2. Guarantee 100% Operand Pattern Coverage
    boundary_patterns = [0x00, 0xFF, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80,
                         0xFE, 0xFD, 0xFB, 0xF7, 0xEF, 0xDF, 0xBF, 0x7F, 0x55, 0xAA]
    for p in boundary_patterns:
        # Force pattern into Operand A
        await driver.drive(a=p, b=0x00, opcode=ALUOpcode.ADD)
        await monitor.capture_transaction()
        # Force pattern into Operand B
        await driver.drive(a=0x00, b=p, opcode=ALUOpcode.ADD)
        await monitor.capture_transaction()

async def random_sequence(driver: ALUDriver, monitor: ALUMonitor, num_transactions: int = 1000) -> None:
    cocotb.log.info(f"--- Starting Constrained Random Sequence ({num_transactions} items) ---")
    opcodes = list(ALUOpcode)
    for _ in range(num_transactions):
        rand_a = random.randint(MIN_8BIT, MAX_8BIT)
        rand_b = random.randint(MIN_8BIT, MAX_8BIT)
        rand_op = random.choice(opcodes)
        await driver.drive(a=rand_a, b=rand_b, opcode=rand_op)
        await monitor.capture_transaction()
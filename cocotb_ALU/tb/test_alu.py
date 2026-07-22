"""
File: test_alu.py
Purpose: Top-level test orchestration file containing cocotb test cases.
"""
import cocotb
from driver import ALUDriver
from monitor import ALUMonitor
from scoreboard import ALUScoreboard
from coverage import ALUCoverage
import sequences

def setup_env(dut):
    driver = ALUDriver(dut)
    monitor = ALUMonitor(dut)
    scoreboard = ALUScoreboard()
    coverage = ALUCoverage()

    monitor.add_callback(scoreboard.check_transaction)
    monitor.add_callback(coverage.sample)

    return driver, monitor, scoreboard, coverage

@cocotb.test()
async def test_opcode_sweep(dut):
    driver, monitor, scoreboard, coverage = setup_env(dut)
    await sequences.opcode_sweep_sequence(driver, monitor)
    scoreboard.report()

@cocotb.test()
async def test_boundary_values(dut):
    driver, monitor, scoreboard, coverage = setup_env(dut)
    await sequences.boundary_sequence(driver, monitor)
    scoreboard.report()

@cocotb.test()
async def test_carry_and_zero_clear(dut):
    driver, monitor, scoreboard, coverage = setup_env(dut)
    await sequences.carry_sequence(driver, monitor)
    await sequences.carryout_clearing_sequence(driver, monitor)
    scoreboard.report()

@cocotb.test()
async def test_zero_flag(dut):
    driver, monitor, scoreboard, coverage = setup_env(dut)
    await sequences.zero_flag_sequence(driver, monitor)
    scoreboard.report()

@cocotb.test()
async def test_random_stimulus(dut):
    driver, monitor, scoreboard, coverage = setup_env(dut)
    await sequences.random_sequence(driver, monitor, num_transactions=1000)
    scoreboard.report()

@cocotb.test()
async def test_full_regression(dut):
    driver, monitor, scoreboard, coverage = setup_env(dut)

    await sequences.opcode_sweep_sequence(driver, monitor)
    await sequences.boundary_sequence(driver, monitor)
    await sequences.carry_sequence(driver, monitor)
    await sequences.zero_flag_sequence(driver, monitor)
    await sequences.carryout_clearing_sequence(driver, monitor)
    
    # The ultimate coverage guarantor
    await sequences.exhaustive_coverage_sequence(driver, monitor)
    
    # Keep random at 1000 for standard unpredictability
    await sequences.random_sequence(driver, monitor, num_transactions=1000)

    scoreboard.report()
    coverage.report(filename="coverage_report.txt")
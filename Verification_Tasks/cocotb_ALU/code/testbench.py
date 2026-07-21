import cocotb
import random
from cocotb.triggers import *
from cocotb.handle import Force,Release,Freeze,Deposit

# there is no clk in alu module so i used the timer
#test counters
pass_count = 0
fail_count = 0

async def drive_arthimetic(dut):
    dut.a.value = 0
    dut.b.value = 0
    dut.opcode.value = 0
    await Timer(2, units='ns')
    for i in range(10):
        dut.a.value = random.randint(0, 15)
        dut.b.value = random.randint(0, 15)
        dut.opcode.value = 0  # addition operation
        await Timer(2, units='ns')
        dut.opcode.value = 1  # subtraction operation
        await Timer(2, units='ns')

async def drive_logical(dut):
    dut.a.value = 0
    dut.b.value = 0
    dut.opcode.value = 0
    await Timer(2, units='ns')
    for i in range(10):
        dut.a.value = random.randint(0, 15)
        dut.b.value = random.randint(0, 15)
        dut.opcode.value = 2  # AND operation
        await Timer(2, units='ns')
        dut.opcode.value = 3  # XOR operation
        await Timer(2, units='ns')

async def check_results(dut):
    #to updatet he counters
    global pass_count, fail_count
    # check results every 2 ns
    while True:
        await Timer(2, units='ns')
        await ReadOnly()

        if dut.opcode.value == 0:  # addition operation
            expected_result = dut.a.value + dut.b.value
        elif dut.opcode.value == 1:  # subtraction operation
            expected_result = dut.a.value - dut.b.value
        elif dut.opcode.value == 2:  # AND operation
            expected_result = dut.a.value & dut.b.value
        elif dut.opcode.value == 3:  # XOR operation
            expected_result = dut.a.value ^ dut.b.value
        else:
            expected_result = 0 
        
        if dut.result.value == expected_result:
            pass_count += 1
            cocotb.log.info("test passed for opcode %d ,a: %d, b: %d ,result: %d", dut.opcode.value, dut.a.value, dut.b.value, dut.result.value)
        else:
            fail_count += 1
            cocotb.log.info("test failed for opcode %d, a: %d, b: %d, result: %d, expected: %d", dut.opcode.value, dut.a.value, dut.b.value, dut.result.value, expected_result)

        
@cocotb.test()
async def alu_tb(dut):
    # start the checker in the background
    checker = cocotb.start_soon(check_results(dut))
    #run arithmetic driver 
    await drive_arthimetic(dut)
    #run logical driver
    await drive_logical(dut)
    #stop the checker
    checker.kill()
    #results
    cocotb.log.info("tests passed = %d", pass_count)
    cocotb.log.info("tests failed = %d", fail_count)
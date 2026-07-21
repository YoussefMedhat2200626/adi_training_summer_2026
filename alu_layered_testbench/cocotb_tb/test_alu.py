import cocotb
from cocotb.triggers import Timer

async def drive_arithmetic(dut):
    """Coroutine to drive arithmetic operations (ADD=00, SUB=01)"""
    cocotb.log.info(" --- Starting Arithmetic Stimulus ---")
    for i in range(3):
        # ADD
        dut.A.value = 10 + i
        dut.B.value = 5
        dut.alu_op.value = 0 
        await Timer(10, unit="ns")
        
        # SUB
        dut.A.value = 20 + i
        dut.B.value = 5
        dut.alu_op.value = 1 
        await Timer(10, unit="ns")

async def drive_logical(dut):
    """Coroutine to drive logical operations (AND=10, XOR=11)"""
    cocotb.log.info(" --- Starting Logical Stimulus ---")
    for i in range(3):
        # AND
        dut.A.value = 0xFF
        dut.B.value = 0x0F
        dut.alu_op.value = 2 
        await Timer(10, unit="ns")
        
        # XOR
        dut.A.value = 0xAA
        dut.B.value = 0x55
        dut.alu_op.value = 3 
        await Timer(10, unit="ns")

async def sample_output(dut, samples=6):
    """Coroutine to passively sample and print the output"""
    cocotb.log.info(" --- Monitor Started ---")
    
    for _ in range(samples):
        # Wait for signals to settle before sampling
        await Timer(10, unit="ns")
        
        # Read the values
        a = int(dut.A.value)
        b = int(dut.B.value)
        op = int(dut.alu_op.value)
        res = int(dut.result.value)
        carry = int(dut.carry_out.value)
        zero = int(dut.zero.value)
        
        op_name = ["ADD", "SUB", "AND", "XOR"][op]
        cocotb.log.info(f"Monitor Sampled -> {op_name}: {a} op {b} = {res} (Carry={carry}, Zero={zero})")

@cocotb.test()
async def test_arithmetic(dut):
    sampler_task = cocotb.start_soon(sample_output(dut, samples=6))
    await cocotb.start_soon(drive_arithmetic(dut))
    await sampler_task

@cocotb.test()
async def test_logical(dut):
    sampler_task = cocotb.start_soon(sample_output(dut, samples=6))
    await cocotb.start_soon(drive_logical(dut))
    await sampler_task

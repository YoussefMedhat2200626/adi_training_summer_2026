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

async def sample_output(dut):
    """Coroutine to passively sample and print the output"""
    cocotb.log.info(" --- Monitor Started ---")
    
    # We will sample 12 times (6 arithmetic + 6 logical)
    for _ in range(12):
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
async def tb_top(dut):
    """Main Testbench following the start_soon() structure"""
    cocotb.log.info(" STARTING SIMULATION ")
    
    # 1. Start the sampling coroutine in the background
    sampler_task = cocotb.start_soon(sample_output(dut))
    
    # 2. Drive the arithmetic operations
    await cocotb.start_soon(drive_arithmetic(dut))
    
    # 3. Drive the logical operations
    await cocotb.start_soon(drive_logical(dut))
    
    # 4. Wait for the monitor to finish sampling
    await sampler_task
    
    cocotb.log.info(" SIMULATION FINISHED ")

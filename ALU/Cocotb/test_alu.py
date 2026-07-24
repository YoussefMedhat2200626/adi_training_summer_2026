import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

@cocotb.test()
async def alu_simple_test(dut):
    
    # Start clock on the interface's clock signal
    cocotb.start_soon(Clock(dut.vif.clk, 10, units="ns").start())

    # Reset Sequence
    dut.vif.rst_n.value = 0
    dut.vif.a.value = 0
    dut.vif.b.value = 0
    dut.vif.opcode.value = 0
    
    # Wait for 2 clock cycles
    for _ in range(2):
        await RisingEdge(dut.vif.clk)
        
    dut.vif.rst_n.value = 1
    await RisingEdge(dut.vif.clk)
    dut._log.info("Reset complete.")

    # Test Case 1: Arithmetic ADD
    # 15 + 10 = 25
    dut.vif.a.value = 15
    dut.vif.b.value = 10
    dut.vif.opcode.value = 0  # ADD
    
    await RisingEdge(dut.vif.clk)
    
    assert dut.vif.out.value == 25, f"ADD Failed! Expected 25, got {dut.vif.out.value}"
    assert dut.vif.zero.value == 0, "Zero flag mismatch!"
    dut._log.info("Test Case 1 (ADD) Passed.")

    # Test Case 2: Arithmetic SUB
    # 50 - 50 = 0
    dut.vif.a.value = 50
    dut.vif.b.value = 50
    dut.vif.opcode.value = 1  # SUB
    
    await RisingEdge(dut.vif.clk)
    
    assert dut.vif.out.value == 0, f"SUB Failed! Expected 0, got {dut.vif.out.value}"
    assert dut.vif.zero.value == 1, "Zero flag should be 1 for output 0"
    dut._log.info("Test Case 2 (SUB -> Zero Flag) Passed.")

    # Test Case 3: Logical AND
    # 0xF7 & 0x0F = 0x07
    dut.vif.a.value = 0xF7
    dut.vif.b.value = 0x0F
    dut.vif.opcode.value = 2  # AND
    
    await RisingEdge(dut.vif.clk)
    
    assert dut.vif.out.value == 0x07, f"AND Failed! Expected 7, got {dut.vif.out.value}"
    dut._log.info("Test Case 3 (AND) Passed.")
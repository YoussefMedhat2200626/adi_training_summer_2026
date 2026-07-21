import cocotb
from environment import Environment

@cocotb.test()
async def simple_alu_test(dut):
    """Testbench for simple_alu using Directed Sequences"""
    env = Environment(dut)
    
    # The environment now handles the 3 phases internally
    await env.run()
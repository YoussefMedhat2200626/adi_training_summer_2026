"""
File: driver.py
Purpose: Drives stimulus into the DUT's input ports.
"""

import cocotb
from cocotb.triggers import Timer
from constants import PROPAGATION_DELAY, DELAY_UNIT

class ALUDriver:
    def __init__(self, dut):
        self.dut = dut

    async def drive(self, a: int, b: int, opcode: int):
        # -----------------------------------------------------------
        # NEW FIX: Advance time by 1 simulator step to exit any 
        # ReadOnly phase left over from the previous monitor sample.
        # -----------------------------------------------------------
        await Timer(1, units="step")
        
        # Assign values to the DUT inputs
        self.dut.A.value = a
        self.dut.B.value = b
        self.dut.opcode.value = opcode

        cocotb.log.debug(f"Driver -> A: {a:#04x}, B: {b:#04x}, opcode: {opcode}")

        # Advance simulation time to allow combinational logic to settle
        await Timer(PROPAGATION_DELAY, units=DELAY_UNIT)
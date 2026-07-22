"""
File: monitor.py
Purpose: Monitors the DUT interface to sample actual inputs and outputs.
Responsibilities: Passively sample signals after logic propagation, package them into transactions,
                  and notify subscribers (Scoreboard, Coverage).
Interaction: Observes DUT signals. Sends transactions to registered callback functions.
"""

import cocotb
from cocotb.triggers import ReadOnly

class ALUMonitor:
    """
    Passive Monitor for the ALU environment.
    Samples input and output signals once combinational logic settles.
    """
    def __init__(self, dut):
        self.dut = dut
        self.callbacks = []

    def add_callback(self, callback):
        """
        Registers a subscriber function (e.g., scoreboard or coverage logger).
        
        Inputs:
            - callback (callable): Function accepting a transaction dictionary.
        """
        self.callbacks.append(callback)

    async def capture_transaction(self) -> dict:
        """
        Samples current signal values after yielding to the ReadOnly phase 
        to ensure combinational logic has completely evaluated.
        
        Outputs:
            - dict: Captured interface transaction.
        """
        # Yield until the simulator reaches the ReadOnly phase of the current time step
        await ReadOnly()

        # Read current hardware values from the DUT handle
        transaction = {
            'A': int(self.dut.A.value),
            'B': int(self.dut.B.value),
            'opcode': int(self.dut.opcode.value),
            'Result': int(self.dut.Result.value),
            'carryout': int(self.dut.carryout.value),
            'zero_flag': int(self.dut.zero_flag.value)
        }

        cocotb.log.debug(
            f"Monitor Captured -> A: {transaction['A']:#04x}, B: {transaction['B']:#04x}, "
            f"opcode: {transaction['opcode']}, Result: {transaction['Result']:#04x}, "
            f"carryout: {transaction['carryout']}, zero_flag: {transaction['zero_flag']}"
        )

        # Broadcast transaction to subscribers (Scoreboard, Coverage, etc.)
        for cb in self.callbacks:
            cb(transaction)

        return transaction
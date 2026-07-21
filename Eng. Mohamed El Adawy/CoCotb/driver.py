import cocotb
from cocotb.triggers import Timer

class Driver:
    def __init__(self, dut, gen2drv):
        self.dut = dut
        self.gen2drv = gen2drv

    async def run(self):
        while True:
            # Get transaction from Generator
            tx = await self.gen2drv.get()
            
            # Drive inputs to the DUT (Design Under Test)
            self.dut.A.value = tx.A
            self.dut.B.value = tx.B
            self.dut.opcode.value = tx.opcode
            
            # Wait for 5 ns for the operation to complete
            await Timer(5, units="ns")
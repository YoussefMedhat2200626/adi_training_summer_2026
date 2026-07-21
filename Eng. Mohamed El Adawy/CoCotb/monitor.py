import cocotb
from cocotb.triggers import Timer
from transaction import Transaction

class Monitor:
    def __init__(self, dut, mon2sb):
        self.dut = dut
        self.mon2sb = mon2sb

    async def run(self):
        while True:
            # Wait for 5 ns (sync with driver)
            await Timer(5, units="ns")
            
            # Sample all inputs and outputs
            tx = Transaction()
            tx.A = self.dut.A.value.integer
            tx.B = self.dut.B.value.integer
            tx.opcode = self.dut.opcode.value.integer
            
            tx.Result = self.dut.Result.value.integer
            tx.Zero = self.dut.Zero.value.integer
            tx.Carry = self.dut.Carry.value.integer
            tx.Overflow = self.dut.Overflow.value.integer
            
            # Send the sampled transaction to Scoreboard
            await self.mon2sb.put(tx)
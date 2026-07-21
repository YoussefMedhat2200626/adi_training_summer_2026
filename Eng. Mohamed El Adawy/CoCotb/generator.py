import random
from transaction import Transaction

class Generator:
    def __init__(self, gen2drv):
        self.gen2drv = gen2drv

    async def run(self, num_transactions, opcodes):
        for _ in range(num_transactions):
            tx = Transaction()
            tx.A = random.randint(0, 255)
            tx.B = random.randint(0, 255)
            # Randomly select an opcode from the provided list for this phase
            tx.opcode = random.choice(opcodes)
            await self.gen2drv.put(tx)
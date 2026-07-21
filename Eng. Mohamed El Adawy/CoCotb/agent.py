import cocotb
from cocotb.queue import Queue
from generator import Generator
from driver import Driver
from monitor import Monitor

class Agent:
    def __init__(self, dut, mon2sb):
        self.gen2drv = Queue()
        self.generator = Generator(self.gen2drv)
        self.driver = Driver(dut, self.gen2drv)
        self.monitor = Monitor(dut, mon2sb)

    def start_tasks(self):
        # Start driver and monitor as continuous parallel tasks
        cocotb.start_soon(self.driver.run())
        cocotb.start_soon(self.monitor.run())

    async def run_phase(self, num_transactions, opcodes):
        # Run generator for specific phase
        await self.generator.run(num_transactions, opcodes)
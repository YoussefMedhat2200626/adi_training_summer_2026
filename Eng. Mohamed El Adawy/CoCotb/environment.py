import cocotb
from cocotb.queue import Queue
from agent import Agent
from scoreboard import Scoreboard
from cocotb.triggers import Timer

class Environment:
    def __init__(self, dut):
        self.mon2sb = Queue()
        self.agent = Agent(dut, self.mon2sb)
        self.scoreboard = Scoreboard(self.mon2sb)

    async def run(self):
        # 1. Start continuous hardware tasks
        self.agent.start_tasks()
        
        # 2. Phase 1: ARITHMETIC (Opcodes 0, 1)
        print("\n--- STARTING ARITHMETIC TESTS ---")
        sb_task = cocotb.start_soon(self.scoreboard.run(100, "ARITHMETIC (ADD/SUB)"))
        await self.agent.run_phase(100, [0, 1])
        await sb_task
        await Timer(10, units="ns")

        # 3. Phase 2: LOGIC (Opcodes 2, 3)
        print("\n--- STARTING LOGIC TESTS ---")
        sb_task = cocotb.start_soon(self.scoreboard.run(100, "LOGIC (AND/OR)"))
        await self.agent.run_phase(100, [2, 3])
        await sb_task
        await Timer(10, units="ns")

        # 4. Phase 3: SHIFT (Opcodes 4, 5)
        print("\n--- STARTING SHIFT TESTS ---")
        sb_task = cocotb.start_soon(self.scoreboard.run(100, "SHIFT (SHL/SHR)"))
        await self.agent.run_phase(100, [4, 5])
        await sb_task
        await Timer(10, units="ns")
        
        # 5. Print Final Wrap-up
        self.scoreboard.print_final_summary()
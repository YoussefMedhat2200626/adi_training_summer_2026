import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer


@cocotb.test()
async def alu_demo(dut):

    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

  
    dut.rst_n.value = 0
    dut.A.value = 0
    dut.B.value = 0
    dut.opcode.value = 0

    await Timer(20, units="ns")

    dut.rst_n.value = 1
    await RisingEdge(dut.clk)


    dut.A.value = 7
    dut.B.value = 5
    dut.opcode.value = 0

    await RisingEdge(dut.clk)

    print("\nAddition")
    print(f"A={int(dut.A.value)}")
    print(f"B={int(dut.B.value)}")
    print(f"Result={int(dut.result.value)}")
    print(f"Carry={int(dut.carry.value)}")


    dut.A.value = 3
    dut.B.value = 5
    dut.opcode.value = 1

    await RisingEdge(dut.clk)

    print("\nSubtraction")
    print(f"A={int(dut.A.value)}")
    print(f"B={int(dut.B.value)}")
    print(f"Result={int(dut.result.value)}")
    print(f"Borrow={int(dut.carry.value)}")

    dut.A.value = 0b1100
    dut.B.value = 0b1010
    dut.opcode.value = 2

    await RisingEdge(dut.clk)

    print("\nAND")
    print(f"Result={int(dut.result.value):04b}")

    dut.A.value = 0b1100
    dut.B.value = 0b1010
    dut.opcode.value = 3

    await RisingEdge(dut.clk)

    print("\nXOR")
    print(f"Result={int(dut.result.value):04b}")

    print("\nDemo completed.")

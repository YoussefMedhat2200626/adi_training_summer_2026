import cocotb_test.simulator
from cocotb_test.simulator import run

original_tcl_value = cocotb_test.simulator.as_tcl_value
cocotb_test.simulator.as_tcl_value = lambda v: original_tcl_value(str(v))

def test_alu_wrapper():
    run(
        verilog_sources=["ALU_if.sv", "alu.sv", "tb_top.sv"],
        toplevel="tb_top",         
        module="test_alu",         
        simulator="questa"         
    )

    # Type "pytest test_runner.py -s" in the terminal to run the tests
    # Note: Ensure that QuestaSim is installed and properly configured in your system's PATH for the tests to run successfully.
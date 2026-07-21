# ALU Verification Environment (Assignment 3 & 4 - TE_ALU)

This repository contains a robust verification environment for an 8-bit Arithmetic Logic Unit (ALU). The underlying verification architecture and transaction-based methodology have been successfully designed and applied across two distinct frameworks:
1. **Class-Based SystemVerilog** (OOP verification environment using interfaces, mailboxes, agents, and scoreboard).
2. **Python-Based Cocotb** (Co-simulation framework using Python for stimulus generation, driving, monitoring, and scoreboarding).

---

##  Supported ALU Operations

The Design Under Test (`simple_alu`) supports 6 distinct operations via a 3-bit opcode:
* **`3'b000` (ADD):** 8-bit addition with Carry-out and Overflow flag detection.
* **`3'b001` (SUB):** 8-bit subtraction with Borrow/Carry tracking and Overflow flag detection.
* **`3'b010` (AND):** Bitwise AND operation.
* **`3'b011` (OR):** Bitwise OR operation.
* **`3'b100` (SHL):** Logical Shift Left (up to 7 bits).
* **`3'b101` (SHR):** Logical Shift Right (up to 7 bits).

---

##  SystemVerilog Project Architecture & File Structure

For the **Class-Based SystemVerilog** implementation, the project follows a bottom-up object-oriented structure:

```text
├── alu_if.sv        # Virtual interface binding testbench components to the DUT
├── transaction.sv   # Transaction class encapsulating rand stimulus and response fields
├── generator.sv     # Generates randomized transaction packets and synchronization events
├── driver.sv        # Pulls transactions from mailbox and drives signals onto the interface
├── monitor.sv       # Passively samples DUT inputs/outputs and streams transactions to SB
├── scoreboard.sv    # Reference model comparing actual DUT outputs against expected results
├── agent.sv         # Encapsulates generator, driver, and monitor components
├── environment.sv   # Orchestrates verification phases (pre-test reset, test, and post-test report)
├── test.sv          # Configures test scenarios (e.g., transaction count) and runs the environment
└── tb.sv            # Top-level module instantiating the DUT, interface, and clock generator

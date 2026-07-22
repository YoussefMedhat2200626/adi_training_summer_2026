"""
File: constants.py
Purpose: Defines global constants, opcodes, and configuration values for the ALU testbench.
Responsibilities: Centralize "magic numbers" to ensure consistency and readability across the environment.
Interaction: Imported by sequences, reference model, scoreboard, and top-level test files.
"""

from enum import IntEnum

class ALUOpcode(IntEnum):
    """
    Enumeration of all supported 3-bit ALU operations.
    Using IntEnum allows direct assignment to cocotb signals while remaining readable.
    """
    PASS_A = 0b000
    ADD    = 0b001
    SUB    = 0b010
    INC    = 0b011
    DEC    = 0b100
    AND    = 0b101
    OR     = 0b110
    NOT    = 0b111

# --- Data Boundaries ---
# Useful for boundary-value testing sequences
MAX_8BIT = 0xFF
MIN_8BIT = 0x00

# --- Simulation Timing ---
# Used to allow combinational logic to settle before sampling
PROPAGATION_DELAY = 1
DELAY_UNIT = "ns"
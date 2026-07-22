"""
File: reference_model.py
Purpose: Implements a pure Python golden model of the 8-bit ALU.
Responsibilities: Compute the strictly expected outputs (Result, carryout, zero_flag) based on stimulus inputs.
Interaction: Called by the scoreboard to determine the correct behavior for comparison against the DUT.
"""

from constants import ALUOpcode, MAX_8BIT

def compute_expected(a: int, b: int, opcode: int) -> dict:
    """
    Computes the expected ALU output given A, B, and opcode.
    
    Inputs:
        - a (int): 8-bit operand A
        - b (int): 8-bit operand B
        - opcode (int): 3-bit operation code
        
    Outputs:
        - dict: Contains 'Result', 'carryout', and 'zero_flag' as integers.
    """
    result = 0
    carryout = 0

    # Evaluate opcode and compute base result
    if opcode == ALUOpcode.PASS_A:
        result = a
        carryout = 0
    elif opcode == ALUOpcode.ADD:
        full_result = a + b
        result = full_result & MAX_8BIT
        carryout = (full_result >> 8) & 1
    elif opcode == ALUOpcode.SUB:
        full_result = a - b
        result = full_result & MAX_8BIT
        # Carryout acts as a borrow flag in subtraction
        carryout = 1 if a < b else 0
    elif opcode == ALUOpcode.INC:
        result = (a + 1) & MAX_8BIT
        carryout = 0
    elif opcode == ALUOpcode.DEC:
        result = (a - 1) & MAX_8BIT
        carryout = 0
    elif opcode == ALUOpcode.AND:
        result = a & b
        carryout = 0
    elif opcode == ALUOpcode.OR:
        result = a | b
        carryout = 0
    elif opcode == ALUOpcode.NOT:
        result = (~a) & MAX_8BIT
        carryout = 0
    else:
        # Default operation outputs A and clears carryout
        result = a
        carryout = 0

    # Zero flag is active high whenever Result value is 0
    zero_flag = 1 if result == 0 else 0

    return {
        'Result': result,
        'carryout': carryout,
        'zero_flag': zero_flag
    }
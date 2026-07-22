"""
File: coverage.py
Purpose: Tracks and measures functional coverage items defined in the Verification Plan.
"""

import cocotb
from constants import ALUOpcode, MAX_8BIT, MIN_8BIT


class ALUCoverage:
    def __init__(self):
        # Opcode Coverage
        self.opcodes_seen = set()
        self.all_opcodes = set(ALUOpcode)

        # Flag Coverage
        self.zero_flag_states = set()  
        self.carryout_states = set()   

        # Cross Coverage
        self.opcode_x_zero = set()     
        self.opcode_x_carry = set()    

        # Operand Boundary Value Coverage 
        self.boundary_patterns = {0x00, 0xFF, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80,
                                  0xFE, 0xFD, 0xFB, 0xF7, 0xEF, 0xDF, 0xBF, 0x7F, 0x55, 0xAA}
        self.operands_a_seen = set()
        self.operands_b_seen = set()

        # Result Values
        self.results_seen = set()
        self.result_boundaries_seen = set()  

        # Overflow / Underflow Coverage
        self.add_overflow_hit = False
        self.sub_underflow_hit = False
        self.inc_overflow_hit = False
        self.dec_underflow_hit = False

        # Immediate Carryout Clear Verification
        self.carryout_clear_after_overflow = False

        # Bit Toggle Coverage 
        self.prev_result = None
        self.bit_toggles_0_to_1 = [False] * 8
        self.bit_toggles_1_to_0 = [False] * 8

    def sample(self, transaction: dict) -> None:
        """Samples a captured transaction to update functional coverage metrics."""
        a = transaction['A']
        b = transaction['B']
        opcode = transaction['opcode']
        result = transaction['Result']
        carryout = transaction['carryout']
        zero_flag = transaction['zero_flag']

        self.opcodes_seen.add(opcode)

        self.zero_flag_states.add(zero_flag)
        self.carryout_states.add(carryout)
        self.opcode_x_zero.add((opcode, zero_flag))
        self.opcode_x_carry.add((opcode, carryout))

        if a in self.boundary_patterns:
            self.operands_a_seen.add(a)
        if b in self.boundary_patterns:
            self.operands_b_seen.add(b)

        self.results_seen.add(result)
        if result in {MIN_8BIT, MAX_8BIT}:
            self.result_boundaries_seen.add(result)

        if opcode == ALUOpcode.ADD and (a + b) > MAX_8BIT and result == 0:
            self.add_overflow_hit = True
        elif opcode == ALUOpcode.SUB and a < b and result == MAX_8BIT:
            self.sub_underflow_hit = True
        elif opcode == ALUOpcode.INC and a == MAX_8BIT and result == MIN_8BIT:
            self.inc_overflow_hit = True
        elif opcode == ALUOpcode.DEC and a == MIN_8BIT and result == MAX_8BIT:
            self.dec_underflow_hit = True

        if self.add_overflow_hit and opcode not in [ALUOpcode.ADD, ALUOpcode.SUB] and carryout == 0:
            self.carryout_clear_after_overflow = True

        if self.prev_result is not None:
            for bit in range(8):
                prev_bit = (self.prev_result >> bit) & 1
                curr_bit = (result >> bit) & 1
                if prev_bit == 0 and curr_bit == 1:
                    self.bit_toggles_0_to_1[bit] = True
                elif prev_bit == 1 and curr_bit == 0:
                    self.bit_toggles_1_to_0[bit] = True
        self.prev_result = result

    def report(self, filename="coverage_report.txt") -> None:
        """Logs a detailed functional coverage summary and exports to a text file."""
        opcode_cov = (len(self.opcodes_seen) / len(self.all_opcodes)) * 100.0
        result_val_cov = (len(self.results_seen) / 256) * 100.0
        operand_a_cov = (len(self.operands_a_seen) / len(self.boundary_patterns)) * 100.0
        operand_b_cov = (len(self.operands_b_seen) / len(self.boundary_patterns)) * 100.0
        
        toggle_01_cov = (sum(self.bit_toggles_0_to_1) / 8) * 100.0
        toggle_10_cov = (sum(self.bit_toggles_1_to_0) / 8) * 100.0

        report_lines = [
            "=========================================",
            "      FUNCTIONAL COVERAGE SUMMARY        ",
            "=========================================",
            f"Opcode Coverage              : {opcode_cov:.1f}% ({len(self.opcodes_seen)}/8)",
            f"Result Space Coverage        : {result_val_cov:.1f}% ({len(self.results_seen)}/256 values)",
            f"Operand A Pattern Coverage   : {operand_a_cov:.1f}%",
            f"Operand B Pattern Coverage   : {operand_b_cov:.1f}%",
            f"Result Bit Toggle 0->1       : {toggle_01_cov:.1f}%",
            f"Result Bit Toggle 1->0       : {toggle_10_cov:.1f}%",
            f"ADD Overflow Covered         : {'YES' if self.add_overflow_hit else 'NO'}",
            f"SUB Underflow Covered        : {'YES' if self.sub_underflow_hit else 'NO'}",
            f"INC Overflow Covered         : {'YES' if self.inc_overflow_hit else 'NO'}",
            f"DEC Underflow Covered        : {'YES' if self.dec_underflow_hit else 'NO'}",
            f"Carryout Immediate Clear     : {'YES' if self.carryout_clear_after_overflow else 'NO'}",
            "========================================="
        ]

        # Log to console
        for line in report_lines:
            cocotb.log.info(line)

        # Write to file
        with open(filename, "w") as f:
            f.write("\n".join(report_lines) + "\n")
            
        cocotb.log.info(f"-> Coverage report successfully saved to {filename}")
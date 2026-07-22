"""
File: scoreboard.py
Purpose: Compares DUT outputs sampled by the Monitor against expected values calculated by the Reference Model.
Responsibilities: Track pass/fail statistics, identify signal mismatches, and log detailed verification reports.
Interaction: Subscribes to the Monitor via callback and calls the Reference Model for expected results.
"""

import cocotb
from reference_model import compute_expected

class ALUScoreboard:
    """
    Scoreboard for the 8-bit ALU verification environment.
    Evaluates interface transactions and asserts output correctness.
    """
    def __init__(self):
        self.passed_transactions = 0
        self.failed_transactions = 0
        self.errors = []

    def check_transaction(self, transaction: dict) -> None:
        """
        Callback function executed whenever the Monitor captures a transaction.
        
        Inputs:
            - transaction (dict): Captured interface signals containing A, B, opcode, Result, carryout, zero_flag.
            
        Outputs:
            - None
        """
        a = transaction['A']
        b = transaction['B']
        opcode = transaction['opcode']
        
        actual_result = transaction['Result']
        actual_carryout = transaction['carryout']
        actual_zero_flag = transaction['zero_flag']

        # Calculate expected values using our independent Python golden model
        expected = compute_expected(a, b, opcode)

        mismatch = False
        mismatch_details = []

        # Check Result
        if actual_result != expected['Result']:
            mismatch = True
            mismatch_details.append(
                f"Result Mismatch -> Expected: {expected['Result']:#04x}, Actual: {actual_result:#04x}"
            )

        # Check Carryout
        if actual_carryout != expected['carryout']:
            mismatch = True
            mismatch_details.append(
                f"Carryout Mismatch -> Expected: {expected['carryout']}, Actual: {actual_carryout}"
            )

        # Check Zero Flag
        if actual_zero_flag != expected['zero_flag']:
            mismatch = True
            mismatch_details.append(
                f"Zero Flag Mismatch -> Expected: {expected['zero_flag']}, Actual: {actual_zero_flag}"
            )

        # Log details and update counts
        if mismatch:
            self.failed_transactions += 1
            error_msg = (
                f"[FAIL] Transaction Mismatch for A={a:#04x}, B={b:#04x}, opcode={opcode}\n" +
                "\n".join(f"       {detail}" for detail in mismatch_details)
            )
            cocotb.log.error(error_msg)
            self.errors.append(error_msg)
        else:
            self.passed_transactions += 1
            cocotb.log.info(
                f"[PASS] Opcode: {opcode} | A: {a:#04x}, B: {b:#04x} | "
                f"Result: {actual_result:#04x}, Carry: {actual_carryout}, Zero: {actual_zero_flag}"
            )

    def report(self) -> None:
        """
        Logs a summary of pass/fail counts and asserts zero failures for regression checks.
        
        Outputs:
            - None (Raises AssertionError if failed_transactions > 0)
        """
        total = self.passed_transactions + self.failed_transactions
        cocotb.log.info("=========================================")
        cocotb.log.info("           SCOREBOARD SUMMARY            ")
        cocotb.log.info("=========================================")
        cocotb.log.info(f"Total Transactions Checked : {total}")
        cocotb.log.info(f"Passed Transactions       : {self.passed_transactions}")
        cocotb.log.info(f"Failed Transactions       : {self.failed_transactions}")
        cocotb.log.info("=========================================")

        assert self.failed_transactions == 0, (
            f"Testbench FAILED with {self.failed_transactions} mismatch(es)! "
            f"First error: {self.errors[0] if self.errors else 'None'}"
        )
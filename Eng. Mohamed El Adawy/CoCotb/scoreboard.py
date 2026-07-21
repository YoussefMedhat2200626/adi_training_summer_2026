class Scoreboard:
    def __init__(self, mon2sb):
        self.mon2sb = mon2sb
        self.total_passed = 0
        self.total_failed = 0
        self.cat_passed = 0
        self.cat_failed = 0

    async def run(self, num_transactions, category_name):
        # Reset counters for the current category phase
        self.cat_passed = 0
        self.cat_failed = 0
        
        for _ in range(num_transactions):
            tx = await self.mon2sb.get()
            self.check_output(tx)
            
        # Print the category summary after finishing its tests
        print(f"\n==============================================================")
        print(f"[{category_name} SUMMARY] PASSED: {self.cat_passed} | FAILED: {self.cat_failed}")
        print(f"==============================================================\n")

    def print_final_summary(self):
        # Print the final summary for all categories combined
        print(f"\n*****************************************")
        print(f"*** FINAL TOTAL SUMMARY               ***")
        print(f"*** TOTAL PASSED: {self.total_passed}                 ***")
        print(f"*** TOTAL FAILED: {self.total_failed}                   ***")
        print(f"*****************************************\n")

    def check_output(self, tx):
        exp_Result = 0
        exp_Carry = 0
        exp_Overflow = 0
        exp_Zero = 0

        if tx.opcode == 0: # OP_ADD
            temp = tx.A + tx.B
            exp_Result = temp & 0xFF
            exp_Carry = (temp >> 8) & 1
            exp_Overflow = int(((tx.A >> 7) == (tx.B >> 7)) and (((exp_Result >> 7) != (tx.A >> 7))))
        elif tx.opcode == 1: # OP_SUB
            temp = tx.A - tx.B
            if temp < 0: temp = (1 << 9) + temp
            exp_Result = temp & 0xFF
            exp_Carry = (temp >> 8) & 1
            exp_Overflow = int(((tx.A >> 7) != (tx.B >> 7)) and (((exp_Result >> 7) != (tx.A >> 7))))
        elif tx.opcode == 2: # OP_AND
            exp_Result = tx.A & tx.B
        elif tx.opcode == 3: # OP_OR
            exp_Result = tx.A | tx.B
        elif tx.opcode == 4: # OP_SHL
            shift = tx.B & 0x7
            exp_Result = (tx.A << shift) & 0xFF
        elif tx.opcode == 5: # OP_SHR
            shift = tx.B & 0x7
            exp_Result = tx.A >> shift

        exp_Zero = int(exp_Result == 0)

        if (tx.Result == exp_Result and tx.Zero == exp_Zero and 
            tx.Carry == exp_Carry and tx.Overflow == exp_Overflow):
            self.cat_passed += 1
            self.total_passed += 1
            status = "PASS"
        else:
            self.cat_failed += 1
            self.total_failed += 1
            status = "FAIL"

        print(f"Opcode: {tx.opcode:03b} | A: {tx.A:03d} | B: {tx.B:03d} | "
              f"Res: {tx.Result:03d} (Exp: {exp_Result:03d}) | Status: {status}")
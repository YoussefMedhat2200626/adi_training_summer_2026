# Cocotb ALU Simulation Report

## 1. Methodology
The testbench relies on concurrent Coroutines:

- **`drive_arithmetic`**: A background task that drives the `ADD` and `SUB` operations.
- **`drive_logical`**: A background task that runs *simultaneously* to the arithmetic driver, driving the `AND` and `XOR` operations.
- **`sample_output`**: A passive background monitor that yields control back to the simulator, waits for the signals to settle, and samples the results directly from the DUT bus.

The main testbench `tb_top` spawns all three of these tasks simultaneously using `cocotb.start_soon()` and relies on Python's native asynchronous scheduler to handle the synchronization.

## 2. Simulation Results

```text
#      0.00ns INFO     test                                --- Monitor Started ---
#      0.00ns INFO     test                                --- Starting Arithmetic Stimulus ---
#     10.00ns INFO     test                               Monitor Sampled -> ADD: 10 op 5 = 15 (Carry=0, Zero=0)
#     20.00ns INFO     test                               Monitor Sampled -> SUB: 20 op 5 = 15 (Carry=0, Zero=0)
#     30.00ns INFO     test                               Monitor Sampled -> ADD: 11 op 5 = 16 (Carry=0, Zero=0)
#     40.00ns INFO     test                               Monitor Sampled -> SUB: 21 op 5 = 16 (Carry=0, Zero=0)
#     50.00ns INFO     test                               Monitor Sampled -> ADD: 12 op 5 = 17 (Carry=0, Zero=0)
#     60.00ns INFO     test                               Monitor Sampled -> SUB: 22 op 5 = 17 (Carry=0, Zero=0)
#     60.00ns INFO     cocotb.regression                  test_alu.test_arithmetic passed
#     60.00ns INFO     cocotb.regression                  running test_alu.test_logical (2/2)
#     60.00ns INFO     test                                --- Monitor Started ---
#     60.00ns INFO     test                                --- Starting Logical Stimulus ---
#     70.00ns INFO     test                               Monitor Sampled -> AND: 255 op 15 = 15 (Carry=0, Zero=0)
#     80.00ns INFO     test                               Monitor Sampled -> XOR: 170 op 85 = 255 (Carry=0, Zero=0)
#     90.00ns INFO     test                               Monitor Sampled -> AND: 255 op 15 = 15 (Carry=0, Zero=0)
#    100.00ns INFO     test                               Monitor Sampled -> XOR: 170 op 85 = 255 (Carry=0, Zero=0)
#    110.00ns INFO     test                               Monitor Sampled -> AND: 255 op 15 = 15 (Carry=0, Zero=0)
#    120.00ns INFO     test                               Monitor Sampled -> XOR: 170 op 85 = 255 (Carry=0, Zero=0)
#    120.00ns INFO     cocotb.regression                  test_alu.test_logical passed
#    120.00ns INFO     cocotb.regression                  **************************************************************************************
#                                                         ** TEST                          STATUS  SIM TIME (ns)  REAL TIME (s)  RATIO (ns/s) **
#                                                         **************************************************************************************
#                                                         ** test_alu.test_arithmetic       PASS          60.00           0.03       1758.25  **
#                                                         ** test_alu.test_logical          PASS          60.00           0.00      79790.18  **
#                                                         **************************************************************************************
#                                                         ** TESTS=2 PASS=2 FAIL=0 SKIP=0                120.00           0.04       3362.73  **
#                                                         **************************************************************************************
# ** Note: $finish
#    Time: 120001 ps  Iteration: 0  Instance: /alu
```

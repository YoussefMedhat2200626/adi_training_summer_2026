# Cocotb ALU Testbench

This folder contains the Cocotb Asynchronous Testbench for the 4-Op ALU, built strictly following the Analog Devices (ADI) Training Session guidelines.

## Architecture

Unlike traditional sequential testbenches, this testbench utilizes Python's `async/await` features and the `cocotb.start_soon()` method to spawn multiple concurrent tasks (Coroutines) that simulate parallel hardware behavior.

### 1. `drive_arithmetic(dut)`
A dedicated asynchronous coroutine responsible for exclusively testing the arithmetic capabilities of the ALU:
- Drives ADD (00) and SUB (01) operations.
- Yields control back to the simulator using `await Timer(10, units="ns")`.

### 2. `drive_logical(dut)`
A dedicated asynchronous coroutine responsible for testing the logical capabilities of the ALU:
- Drives AND (10) and XOR (11) operations.
- Runs concurrently alongside the arithmetic driver.

### 3. `sample_output(dut)`
An independent, passive monitor coroutine that:
- Wakes up periodically (`await Timer(10, units="ns")`) to let signals settle.
- Reads `dut.A`, `dut.B`, `dut.alu_op`, `dut.result`, `dut.carry_out`, and `dut.zero`.
- Formats and prints the results gracefully to the terminal log.

### 4. `tb_top(dut)`
The main test entry point, decorated with `@cocotb.test()`. It orchestrates the simulation by spawning the above tasks simultaneously and then awaiting the sampler so the simulation doesn't shut down prematurely:
```python
@cocotb.test()
async def tb_top(dut):
    # Spawns tasks in the background
    sampler_task = cocotb.start_soon(sample_output(dut))
    await cocotb.start_soon(drive_arithmetic(dut))
    await cocotb.start_soon(drive_logical(dut))
    
    # Block testbench from exiting until sampling is complete
    await sampler_task 
```

## How to Run

1. Open your terminal and navigate to this folder:
   ```bash
   cd ~/Desktop/alu/alu_layered_testbench/cocotb_tb
   ```

2. Activate the Python Virtual Environment and set up paths depending on your shell:

   **If you are using Bash / Zsh:**
   ```bash
   source ~/Desktop/alu/.venv/bin/activate
   export PATH=/mnt/shared/altera_pro/26.1/questa_fse/bin:$PATH
   export LM_LICENSE_FILE=~/Downloads/LR-089766_License.txt
   export MGLS_LICENSE_FILE=~/Downloads/LR-089766_License.txt
   ```

   **If you are using Fish (Your current shell!):**
   ```fish
   source ~/Desktop/alu/.venv/bin/activate.fish
   set -x PATH /mnt/shared/altera_pro/26.1/questa_fse/bin $PATH
   set -x LM_LICENSE_FILE ~/Downloads/LR-089766_License.txt
   set -x MGLS_LICENSE_FILE ~/Downloads/LR-089766_License.txt
   ```

3. Run the Simulation with Questa-compat mode:
   ```bash
   make SIM=questa-compat
   ```

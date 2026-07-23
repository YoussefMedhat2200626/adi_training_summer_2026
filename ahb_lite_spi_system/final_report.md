# Final Project Report: AHB-Lite System and SPI Slave Design

## 1. Assignment 1: AHB-Lite System

The AHB-Lite system was designed to fulfill all standard transfer requirements, including sub-word sizing, multi-beat bursts, and pipelined throughput. It consists of a custom Master, an Interconnect (Decoder and Multiplexor), and Slave Memories.

### 1.1 AHB-Lite Master (`ahb_lite_master.sv`)
The master was designed hierarchically to separate concerns and improve maintainability:

- **`ahb_master_fsm.sv`**: The core 5-state Moore machine (`IDLE`, `NONSEQ`, `SEQ`, `WAIT_RESP`, `ERROR_RSP`) controlling bus phases and response handling. The FSM dynamically calculates `HTRANS` outputs based on the current transfer stage and gracefully enters `ERROR_RSP` upon detecting `HRESP` high during a data phase, successfully canceling the remaining beats of a burst.
- **`ahb_addr_gen.sv`**: Combinational and sequential logic for address calculation. It decodes `HSIZE` to determine the address increment (1, 2, or 4 bytes). For `WRAP` bursts, it dynamically computes the wrap boundary size and utilizes a bitwise masking technique (`base_aligned | ((current_addr + increment) & wrap_mask)`) to ensure the address loops within the prescribed window.
- **`ahb_burst_counter.sv`**: Tracks remaining beats in fixed-length bursts (`INCR4`, `INCR8`, `INCR16`, `WRAP4`). It loads the total count upon the first `NONSEQ` phase and decrements purely on successful data phases (where `HREADY` is asserted).

- The Master correctly supports `HADDR` alignment, wait states (`HREADY`), error responses (`HRESP`), and pipelined data/address phases where the address of beat *N+1* is driven during the data phase of beat *N*.

### 1.2 Bonus: Interconnect (`ahb_interconnect.sv`)
To support multiple slaves efficiently without bus conflicts, an interconnect was built instead of relying on a single monolithic slave:

- **`ahb_decoder.sv`**: Decodes `HADDR[11:10]` combinatorially to generate a one-hot `HSEL` signal selecting one of 3 slaves. `2'b00` selects Slave 0, `2'b01` selects Slave 1, and `2'b10` selects Slave 2.
- **`ahb_mux.sv`**: Multiplexes `HRDATA`, `HREADYOUT`, and `HRESP` from the selected slave back to the master. Crucially, it registers the `HSEL` signal during the address phase (gated by the feedback `HREADY` signal) to guarantee that the data phase routing remains stable even when the master pipelines the next address.

### 1.3 Slave Memory (`ahb_slave_mem.sv`)
A memory slave supporting 256 words. It implements proper byte-lane enabling using `HSIZE` and `HADDR[1:0]` for byte, halfword, and word accesses, allowing precise memory modifications without overwriting adjacent bytes. It defaults to zero-wait-state responses for maximum throughput.

---

## 2. Assignment 2: SPI Slave

A standalone SPI Slave module was built to interface with an external SPI Master, operating asynchronously to the main AHB bus clock.

### 2.1 SPI Protocol (`spi_slave.sv`)
- Implements SPI Mode 0 (`CPOL=0`, `CPHA=0`). Data is sampled on the rising edge of `SCK` and shifted out on the falling edge.
- Operates on 16-bit transaction frames, carefully synchronized using a 3-stage shift register to avoid metastability issues when moving from the `SCK` domain to the internal clock domain.
  - **Byte 1**: Command (1 bit Read/Write) + Address (7 bits).
  - **Byte 2**: Data payload (8 bits).
- The shift register accumulates `MOSI` data and latches it into internal registers upon the 16th clock edge, ensuring partial frames or glitched clocks do not corrupt the register map.

### 2.2 Register Map (`spi_reg_map.sv`)
- A configurable register map instantiated inside the SPI slave.
- Implements 4 distinct 8-bit registers capable of being written to and read from via the SPI interface. The address mapping ensures `0x00` to `0x03` target valid spaces, while out-of-bounds addresses are safely ignored.

---

## 3. Verification and Testing

Extensive verification environments were created to ensure protocol compliance and correct data handling. Bus Functional Models (BFMs) were developed to simulate complex slave behaviors.

### 3.1 AHB-Lite System Testbench (`tb_ahb_lite_system.sv`)
1. **Single Accesses**: Basic read/write verifications.
2. **Back-to-Back**: Consecutive reads and writes testing the `NONSEQ` state transitions.
3. **Pipelining**: A write immediately followed by a read to test address/data phase overlap (`test_write_then_read_pipeline`).
4. **Bursts**: `INCR4`, `INCR8`, and `INCR16` bursts for both read and write operations.
5. **Wrapping Bursts**: `WRAP4` burst testing strict boundary alignment and address wrap-around.
6. **Wait States**: Random `HREADYOUT` delays (1-3 cycles) injected by the slave BFM to ensure the master stalls correctly, holding both address and data outputs stable.
7. **Error Responses**: A dedicated two-cycle `HRESP` error injection testing the FSM's ability to cancel a burst and recover gracefully to `IDLE`.
8. **Sub-Word Access**: Byte and halfword masking on writes.
9. **Mid-Transfer Reset**: Asserting `HRESETn` mid-burst to verify the master's immediate recovery.

- A timing issue was encountered with the `test_error_response` (Test 13) where race conditions between the pipelined address and data phases caused the testbench to miss the error flag. This was resolved by implementing a robust `capture_rdata()` polling mechanism that synchronizes exclusively with the `rsp_error` and `rsp_valid` flags.

### 3.2 SPI Slave Testbench (`tb_spi_slave.sv`)
A dedicated SPI Master BFM was built to stimulate the slave.
- Verified writing uniquely to all 4 registers by toggling `CS` appropriately between frames.
- Verified reading back the correct data sequentially.
- Assured correct `MISO` and `MOSI` shift register behavior by deliberately offsetting bit timings to mirror real-world parasitic delays.

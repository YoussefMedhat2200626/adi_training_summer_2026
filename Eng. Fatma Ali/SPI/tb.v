`timescale 1ns / 1ps
module tb_spi_slave;

    // ---------------- DUT signals ----------------
    reg         CSB, CLK, SDI;
    wire        SDO;
    wire [14:0] addr;
    wire        wr_en;
    wire [7:0]  wr_data;
    reg  [7:0]  rd_data;

    // ---------------- Golden register-map model (combinational read) -------
    reg [7:0] mem [0:32767];

    always @(*)          rd_data = mem[addr];
    always @(posedge CLK) if (wr_en) mem[addr] <= wr_data;

    // ---------------- DUT instantiation ----------------
    spi_slave dut (
        .CSB     (CSB),
        .CLK     (CLK),
        .SDI     (SDI),
        .SDO     (SDO),
        .addr    (addr),
        .wr_en   (wr_en),
        .wr_data (wr_data),
        .rd_data (rd_data)
    );

    // ---------------- Timing parameters ----------------
    localparam CLK_PERIOD = 20; // 50 MHz
    localparam T_LEAD     = 8;  // CSB fall  -> first CLK rise
    localparam T_LAG      = 8;  // last CLK fall -> CSB rise

    // ---------------- Scoreboard ----------------
    integer pass_count = 0;
    integer fail_count = 0;
    integer test_num   = 0;

    // ---------------- wr_en activity monitor (used by the abort test) ------
    reg wr_en_seen;
    always @(posedge wr_en) wr_en_seen = 1'b1;

    task automatic spi_bit(input bit_val, output bit_out);
        begin
            SDI = bit_val;
            #(CLK_PERIOD/2);
            bit_out = SDO;      // sample (valid since the previous negedge)
            CLK = 1;            // DUT samples SDI here
            #(CLK_PERIOD/2);
            CLK = 0;            // DUT updates SDO here (for the next bit)
        end
    endtask

    // 16-bit header: {R/W, ADDRESS[14:0]}, MSB first
    task automatic send_header(input rw, input [14:0] address);
        integer i;
        reg [15:0] hdr;
        reg junk;
        begin
            hdr = {rw, address};
            for (i = 15; i >= 0; i = i - 1)
                spi_bit(hdr[i], junk);
        end
    endtask

    // one write data byte, MSB first
    task automatic send_byte(input [7:0] data);
        integer i;
        reg junk;
        begin
            for (i = 7; i >= 0; i = i - 1)
                spi_bit(data[i], junk);
        end
    endtask

    // one read data byte, MSB first
    task automatic recv_byte(output reg [7:0] data);
        integer i;
        reg b;
        begin
            data = 8'd0;
            for (i = 7; i >= 0; i = i - 1) begin
                spi_bit(1'b0, b);
                data = {data[6:0], b};
            end
        end
    endtask

    task automatic csb_start;
        begin
            CSB = 0;
            #(T_LEAD);
        end
    endtask

    task automatic csb_end;
        begin
            #(T_LAG);
            CSB = 1;
            #(CLK_PERIOD);   // idle gap before the next transaction
        end
    endtask

    // common report helper
    task automatic report(input passed, input [8*32:1] name);
        begin
            test_num = test_num + 1;
            if (passed) begin
                pass_count = pass_count + 1;
                $display("[PASS] Test %0d: %0s", test_num, name);
            end else begin
                fail_count = fail_count + 1;
                $display("[FAIL] Test %0d: %0s", test_num, name);
            end
        end
    endtask

    
    // Test 1: single byte write
    
    task automatic test_single_write;
        begin
            csb_start;
            send_header(1'b0, 15'h0010);
            send_byte(8'hA5);
            csb_end;
            report((mem[15'h0010] === 8'hA5), "Single Write");
        end
    endtask

    
    // Test 2: single byte read
    
    task automatic test_single_read;
        reg [7:0] got;
        begin
            mem[15'h0020] = 8'h5A;
            csb_start;
            send_header(1'b1, 15'h0020);
            recv_byte(got);
            csb_end;
            report((got === 8'h5A), "Single Read");
        end
    endtask

    
    // Test 3: 4-byte write burst (auto-increment)
    
    task automatic test_write_burst;
        integer i;
        reg ok;
        reg [7:0] pattern [0:3];
        begin
            pattern[0] = 8'h11; pattern[1] = 8'h22;
            pattern[2] = 8'h33; pattern[3] = 8'h44;

            csb_start;
            send_header(1'b0, 15'h0100);
            for (i = 0; i < 4; i = i + 1)
                send_byte(pattern[i]);
            csb_end;

            ok = 1'b1;
            for (i = 0; i < 4; i = i + 1)
                if (mem[15'h0100 + i] !== pattern[i]) ok = 1'b0;
            report(ok, "Write Burst (4 bytes)");
        end
    endtask

    
    // Test 4: 4-byte read burst (auto-increment)
    
    task automatic test_read_burst;
        integer i;
        reg ok;
        reg [7:0] got;
        reg [7:0] expected [0:3];
        begin
            expected[0] = 8'hDE; expected[1] = 8'hAD;
            expected[2] = 8'hBE; expected[3] = 8'hEF;
            for (i = 0; i < 4; i = i + 1)
                mem[15'h0200 + i] = expected[i];

            csb_start;
            send_header(1'b1, 15'h0200);
            ok = 1'b1;
            for (i = 0; i < 4; i = i + 1) begin
                recv_byte(got);
                if (got !== expected[i]) ok = 1'b0;
            end
            csb_end;
            report(ok, "Read Burst (4 bytes)");
        end
    endtask

    task automatic test_csb_abort;
        integer i;
        reg junk;
        reg [15:0] hdr;
        reg recovered;
        reg no_spurious_write;
        begin
            wr_en_seen = 1'b0;
            mem[15'h0300] = 8'h00;

            CSB = 0;
            #(T_LEAD);
            hdr = {1'b0, 15'h0300};
            for (i = 15; i >= 8; i = i - 1)   // only 8 of the 16 header bits
                spi_bit(hdr[i], junk);
            CSB = 1;                          // abrupt abort, no t_lag respected
            #(CLK_PERIOD);

            // Check the abort itself right here, BEFORE running the recovery
            // write below. The recovery write is a legitimate write and will
            // correctly pulse wr_en - checking wr_en_seen after it would
            // always fail regardless of DUT correctness.
            no_spurious_write = !wr_en_seen;

            // slave must recover: run a normal clean write right after
            csb_start;
            send_header(1'b0, 15'h0300);
            send_byte(8'h77);
            csb_end;

            recovered = (mem[15'h0300] === 8'h77);
            report((no_spurious_write && recovered), "CSB Mid-Transaction Abort");
        end
    endtask

    
    // Test 6: address auto-increment wraparound (0x7FFF -> 0x0000)
    
    task automatic test_address_wraparound;
        integer i;
        reg ok;
        reg [7:0] pattern [0:3];
        reg [14:0] target_addr [0:3];
        begin
            pattern[0] = 8'hAA; pattern[1] = 8'hBB;
            pattern[2] = 8'hCC; pattern[3] = 8'hDD;
            target_addr[0] = 15'h7FFE; target_addr[1] = 15'h7FFF;
            target_addr[2] = 15'h0000; target_addr[3] = 15'h0001;

            csb_start;
            send_header(1'b0, 15'h7FFE);
            for (i = 0; i < 4; i = i + 1)
                send_byte(pattern[i]);
            csb_end;

            ok = 1'b1;
            for (i = 0; i < 4; i = i + 1)
                if (mem[target_addr[i]] !== pattern[i]) ok = 1'b0;
            report(ok, "Address Wraparound (0x7FFF->0x0000)");
        end
    endtask

    
    // Main sequence
    
    initial begin
        $dumpfile("tb_spi_slave.vcd");
        $dumpvars(0, tb_spi_slave);

        CSB = 1'b1;
        CLK = 1'b0;
        SDI = 1'b0;
        #(CLK_PERIOD);

        CSB = 1'b0;
        #(CLK_PERIOD);
        CSB = 1'b1;
        #(CLK_PERIOD);

        test_single_write;
        test_single_read;
        test_write_burst;
        test_read_burst;
        test_csb_abort;
        test_address_wraparound;

        $display("--------------------------------------------------");
        $display("TOTAL: %0d   PASS: %0d   FAIL: %0d", test_num, pass_count, fail_count);
        $display("--------------------------------------------------");
        $finish;
    end

endmodule
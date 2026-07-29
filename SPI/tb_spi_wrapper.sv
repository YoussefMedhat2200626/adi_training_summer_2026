`timescale 1ns/1ps

module tb_spi_wrapper;

    //--------------------------------------------------------------
    // Parameters
    //--------------------------------------------------------------
    parameter MEM_DEPTH   = 256;
    parameter HEADER_SIZE = 16;
    parameter DATA_WIDTH  = 8;
    parameter ADDR_WIDTH  = HEADER_SIZE - 1; // 15-bit address field

    parameter CLK_PERIOD = 20; // sclk period (ns)
    parameter T_LEAD     = 8;  // csb-to-first-clk lead time
    parameter T_LAG      = 8;  // last-clk-to-csb-deassert lag time

    //--------------------------------------------------------------
    // DUT signals
    //--------------------------------------------------------------
    logic sclk_free = 0; // underlying free-running clock, never stops
    logic clk_en    = 0; // enable that gates sclk_free -> sclk
    logic sclk;           // gated clock actually driven to the DUT
    logic rst_n;
    logic SDI;
    logic csb;
    logic SDO;

    //--------------------------------------------------------------
    // Free-running base clock
    //--------------------------------------------------------------
    always #(CLK_PERIOD/2) sclk_free = ~sclk_free;

    // Gate sclk_free with clk_en. clk_en is only ever toggled while
    // sclk_free is low (see tasks below), so this produces a clean
    // gated clock with no partial/glitched pulses.
    assign sclk = clk_en ? sclk_free : 1'b0;

    //--------------------------------------------------------------
    // DUT instance
    //--------------------------------------------------------------
    spi_wrapper #(
        .MEM_DEPTH  (MEM_DEPTH),
        .HEADER_SIZE(HEADER_SIZE),
        .DATA_WIDTH (DATA_WIDTH)
    ) dut (
        .sclk (sclk),
        .rst_n(rst_n),
        .SDI  (SDI),
        .csb  (csb),
        .SDO  (SDO)
    );

    //--------------------------------------------------------------
    // Init
    //--------------------------------------------------------------
    initial begin
        csb   = 1;
        SDI   = 0;
        rst_n = 0;
    end

    //--------------------------------------------------------------
    // Bit-level drive/sample tasks (SPI mode 0 assumed: sample @ rising
    // edge, change data @ falling edge). These sync to sclk_free so they
    // still work correctly even while clk_en is low.
    //--------------------------------------------------------------
    task automatic send_bit(input bit b);
        SDI = b;
        @(negedge sclk_free);
    endtask

    task automatic read_bit(output bit b);
        @(posedge sclk_free);
        b = SDO;
    endtask

    //--------------------------------------------------------------
    // Frame-level tasks
    //--------------------------------------------------------------
    task automatic spi_write(input [ADDR_WIDTH-1:0] address, input [DATA_WIDTH-1:0] data);
        int i;
        @(negedge sclk_free);
        clk_en = 1;
        csb    = 0;
        send_bit(1'b0); // R/W = write
        for (i = ADDR_WIDTH-1; i >= 0; i--) send_bit(address[i]);
        for (i = DATA_WIDTH-1; i >= 0; i--) send_bit(data[i]);
        @(posedge sclk_free); // let DUT sample last data bit
        @(negedge sclk_free);
        csb    = 1;
        clk_en = 0;
    endtask

    task automatic spi_write_burst(input [ADDR_WIDTH-1:0] address, input [DATA_WIDTH-1:0] data_arr[]);
        int i, j;
        @(negedge sclk_free);
        clk_en = 1;
        csb    = 0;
        send_bit(1'b0); // R/W = write
        for (i = ADDR_WIDTH-1; i >= 0; i--) send_bit(address[i]);
        for (j = 0; j < data_arr.size(); j++)
            for (i = DATA_WIDTH-1; i >= 0; i--) send_bit(data_arr[j][i]);
        @(posedge sclk_free);
        @(negedge sclk_free);
        csb    = 1;
        clk_en = 0;
    endtask

    task automatic spi_read(input [ADDR_WIDTH-1:0] address, output [DATA_WIDTH-1:0] rdata);
        int i;
        @(negedge sclk_free);
        clk_en = 1;
        csb    = 0;
        send_bit(1'b1); // R/W = read
        for (i = ADDR_WIDTH-1; i >= 0; i--) send_bit(address[i]);
        for (i = DATA_WIDTH-1; i >= 0; i--) read_bit(rdata[i]);
        @(negedge sclk_free);
        csb    = 1;
        clk_en = 0;
    endtask

    task automatic spi_read_burst(input [ADDR_WIDTH-1:0] address, input int num_bytes, output [DATA_WIDTH-1:0] rdata_arr[]);
        int i, j;
        rdata_arr = new[num_bytes];
        @(negedge sclk_free);
        clk_en = 1;
        csb    = 0;
        send_bit(1'b1); // R/W = read
        for (i = ADDR_WIDTH-1; i >= 0; i--) send_bit(address[i]);
        for (j = 0; j < num_bytes; j++)
            for (i = DATA_WIDTH-1; i >= 0; i--) read_bit(rdata_arr[j][i]);
        @(negedge sclk_free);
        csb    = 1;
        clk_en = 0;
    endtask

    //--------------------------------------------------------------
    // Monitor block - prints every time any watched signal changes
    //--------------------------------------------------------------
    initial begin
        $monitor("t=%0t | csb=%b sclk=%b clk_en=%b SDI=%b SDO=%b | addr=%h wr_en=%b wr_data=%h rd_data=%h",
                  $time, csb, sclk, clk_en, SDI, SDO,
                  dut.addr, dut.wn_en, dut.wr_data, dut.rd_data);
    end

    //--------------------------------------------------------------
    // Stimulus
    //--------------------------------------------------------------
    logic [DATA_WIDTH-1:0] rdata;
    logic [DATA_WIDTH-1:0] rdata_burst[];

    initial begin
        $dumpfile("spi_wrapper_tb.vcd");
        $dumpvars(0, tb_spi_wrapper);

        // Reset
        rst_n = 0;
        repeat (4) @(negedge sclk_free);
        rst_n = 1;
        repeat (4) @(negedge sclk_free);

        // Single-byte write: addr 0x0003, data 0xA5
        spi_write(15'h0003, 8'hA5);
        repeat (4) @(negedge sclk_free);

        // Single-byte read back from addr 0x0003
        spi_read(15'h0003, rdata);
        repeat (4) @(negedge sclk_free);

        // Multi-byte burst write starting at addr 0x0010 (auto-increment)
        spi_write_burst(15'h0010, '{8'h11, 8'h22, 8'h33, 8'h44});
        repeat (4) @(negedge sclk_free);

        // Multi-byte burst read starting at addr 0x0010
        spi_read_burst(15'h0010, 4, rdata_burst);
        repeat (4) @(negedge sclk_free);

        $finish;
    end

endmodule
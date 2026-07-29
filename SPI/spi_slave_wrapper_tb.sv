module spi_slave_wrapper_tb;

    // ------------------------------------------------------------------
    // TB signal declarations: reg for DUT inputs, logic for DUT outputs
    // ------------------------------------------------------------------
    reg SCLK;
    reg rst_n;
    reg CSB;
    reg SDI;
    logic SDO;

    // ------------------------------------------------------------------
    // DUT instantiation
    // ------------------------------------------------------------------
    spi_slave_wrapper u_dut (
        .SCLK(SCLK),
        .rst_n(rst_n),
        .CSB(CSB),
        .SDI(SDI),
        .SDO(SDO)
    );

    // ------------------------------------------------------------------
    // Clock generation: period = 10.0 ns
    // (set your `timescale directive to match the unit you intend)
    // ------------------------------------------------------------------
    initial SCLK = 0;
    always #(10.0/2) SCLK = ~SCLK;

    // ------------------------------------------------------------------
    // Reset task (active-low on 'rst_n')
    // ------------------------------------------------------------------
    task assert_reset;
        begin
            rst_n = 0;
            @(negedge SCLK);
            rst_n = 1;
        end
    endtask

    // ==================================================================
    // Building-block tasks. A transaction = start (CMD+addr) -> one or
    // more data phases -> end. Address is only ever sent once per
    // transaction; reg_map auto-increments the write address for every
    // byte after the first, so a burst is just repeated calls to
    // spi_write_byte between one spi_start_write/spi_end_txn pair.
    // ==================================================================

    // Begin a transaction and shift out CMD=0 (write) + 15-bit address.
    task automatic spi_start_write(input logic [14:0] waddr);
        integer i;
        begin
            CSB = 0;
            @(posedge SCLK);
            SDI = 0; // CMD = write
            for (i = 0; i < 15; i = i + 1) begin
                @(posedge SCLK);
                SDI = waddr[14 - i];
            end
        end
    endtask

    // Begin a transaction and shift out CMD=1 (read) + 15-bit address.
    task automatic spi_start_read(input logic [14:0] raddr);
        integer i;
        begin
            CSB = 0;
            @(posedge SCLK);
            SDI = 1; // CMD = read
            for (i = 0; i < 15; i = i + 1) begin
                @(posedge SCLK);
                SDI = raddr[14 - i];
            end
        end
    endtask

    // Shift out one write-data byte. Call once per byte; call it
    // repeatedly (without re-sending the address) for a burst write.
    task automatic spi_write_byte(input byte wdata);
        integer i;
        begin
            for (i = 0; i < 8; i = i + 1) begin
                @(negedge SCLK);
                SDI = wdata[7 - i];
            end
        end
    endtask

    // Clock out and capture one read-data byte from SDO.
    task automatic spi_read_byte(output logic [7:0] rdata);
        integer i;
        begin
            for (i = 0; i < 8; i = i + 1) begin
                @(posedge SCLK);
                #1step;
                rdata[7 - i] = SDO;
            end
        end
    endtask

    // Close out the current transaction (deassert CSB).
    task automatic spi_end_txn;
        begin
            @(negedge SCLK);
            @(negedge SCLK);
            #1step;
            CSB = 1;
            repeat (2) @(negedge SCLK);
        end
    endtask

    logic [7:0] rd_capture;

    // ------------------------------------------------------------------
    // Main stimulus
    // ------------------------------------------------------------------
    initial begin
        CSB = 1;
        SDI = 0;
        assert_reset;

        // 1) 4 back-to-back burst writes, address sent once at: addr 34
        spi_start_write(15'd34);
        spi_write_byte(8'h5A);
        spi_write_byte(8'hA1);
        spi_write_byte(8'hB2);
        spi_write_byte(8'hC3);
        spi_end_txn;


        // 3) Read the second address written in the burst (addr 36)
        spi_start_read(15'd36);
        repeat (8) @(negedge SCLK);
        spi_end_txn;
        $display("t=%0t READ addr=36 -> data=0x%0h", $time, rd_capture);

        // 4) Read the third address written in the burst (addr 37)
        spi_start_read(15'd37);
        repeat (8) @(negedge SCLK);
        spi_end_txn;
        $display("t=%0t READ addr=37 -> data=0x%0h", $time, rd_capture);

        repeat (20) @(negedge SCLK);
        $stop;
    end

    // ------------------------------------------------------------------
    // Signal monitor
    // ------------------------------------------------------------------
    initial begin
        $monitor("t=%0t rst_n=%0d CSB=%0d SDI=%0d SDO=%0d", $time, rst_n, CSB, SDI, SDO);
    end

endmodule
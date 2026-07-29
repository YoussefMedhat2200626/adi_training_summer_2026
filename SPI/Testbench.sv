module Testbench;

    //======================================================================
    // Parameters
    //======================================================================
    parameter MEM_DEPTH   = 32768;
    parameter HEADER_SIZE = 16;
    parameter DATA_WIDTH  = 8;

    parameter CLK_PERIOD  = 100;
    parameter HALF_CLK    = CLK_PERIOD/2;
    parameter T_LEAD      = CLK_PERIOD;
    parameter T_LAG       = CLK_PERIOD;

    //======================================================================
    // Testbench Signals
    //======================================================================
    logic clk;
    logic rst_n;
    logic SDI;
    logic SDO;
    logic csb;

    logic [7:0] readback;

    //======================================================================
    // Clock Idle
    //======================================================================
    initial clk = 0;

    //======================================================================
    // DUT
    //======================================================================
    spi_wrapper #(
        .MEM_DEPTH  (MEM_DEPTH),
        .HEADER_SIZE(HEADER_SIZE),
        .DATA_WIDTH (DATA_WIDTH)
    ) dut (
        .sclk (clk),
        .rst_n(rst_n),
        .SDI  (SDI),
        .SDO  (SDO),
        .csb  (csb)
    );

    //======================================================================
    // Reset Task
    //======================================================================
    task automatic reset_system;
    begin
        clk   = 0;
        csb   = 1;
        SDI   = 0;

        rst_n = 0;
        #200;

        rst_n = 1;
        #200;
    end
    endtask

    //======================================================================
    // Single SPI Clock Cycle (Mode 0)
    //======================================================================
    task automatic spi_clk_cycle;
    begin
        #HALF_CLK;
        clk = 1;

        #HALF_CLK;
        clk = 0;
    end
    endtask

    //======================================================================
    // SPI WRITE
    // Header = {R/W,address}
    // R/W = 0
    //======================================================================
    task automatic spi_write(
        input logic [14:0] address,
        input logic [7:0]  data
    );

        logic [15:0] header;

    begin
        header = {1'b0, address};

        $display("[%0t] WRITE Addr=0x%h Data=0x%h", $time, address, data);

        // Assert CSB
        csb = 0;

        // t_lead
        #(T_LEAD);

        // Send 16-bit header (MSB first)
        for (int i = 15; i >= 0; i--) begin
            SDI = header[i];
            spi_clk_cycle();
        end

        // Send 8-bit data (MSB first)
        for (int i = 7; i >= 0; i--) begin
            SDI = data[i];
            spi_clk_cycle();
        end

        // Return SDI low
        SDI = 0;

        // t_lag
        #(T_LAG);

        // Deassert CSB
        csb = 1;

        // Idle time before next transaction
        #(T_LEAD);
    end
    endtask

    //======================================================================
    // SPI READ
    // Header = {R/W,address}
    // R/W = 1
    //======================================================================
    task automatic spi_read(
        input  logic [14:0] address,
        output logic [7:0]  data
    );

        logic [15:0] header;

    begin
        header = {1'b1, address};

        $display("[%0t] READ Addr=0x%h", $time, address);

        // Assert CSB
        csb = 0;

        // t_lead
        #(T_LEAD);

        // Send 16-bit header (MSB first)
        for (int i = 15; i >= 0; i--) begin
            SDI = header[i];
            spi_clk_cycle();
        end

        // Release SDI during read phase
        SDI = 0;

        // Receive 8-bit data (sample on rising edge)
        for (int i = 7; i >= 0; i--) begin

            #HALF_CLK;
            clk = 1;

            data[i] = SDO;

            #HALF_CLK;
            clk = 0;
        end

        // t_lag
        #(T_LAG);

        // Deassert CSB
        csb = 1;

        $display("[%0t] READBACK = 0x%h", $time, data);

        #(T_LEAD);
    end
    endtask

    //======================================================================
    // Test Sequence
    //======================================================================
    initial begin

        reset_system();

        spi_write(15'h0123, 8'hAB);

        spi_read(15'h0123, readback);

        #500;

        $finish;
    end

    //======================================================================
    // Monitor
    //======================================================================
    initial begin
        $monitor(
            "T=%0t CSB=%b CLK=%b SDI=%b SDO=%b STATE=%s CNT=%0d ADDR=%h WR_EN=%b WR_DATA=%h RD_DATA=%h",
            $time,
            csb,
            clk,
            SDI,
            SDO,
            dut.u_spi_slave_interface.current_state.name(),
            dut.u_spi_slave_interface.counter,
            dut.addr,
            dut.u_spi_slave_interface.wn_en,
            dut.wr_data,
            dut.rd_data
        );
    end

    //======================================================================
    // Timeout
    //======================================================================
    initial begin
        #(CLK_PERIOD * 5000);
        $display("TIMEOUT");
        $finish;
    end

    //======================================================================
    // Waveforms
    //======================================================================
    initial begin
        $dumpfile("spi_wrapper.vcd");
        $dumpvars(0, Testbench);
    end

endmodule
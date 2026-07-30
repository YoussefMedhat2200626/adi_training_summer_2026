module wrapper_tb();

    localparam time CLK_PERIOD = 20ns;
    localparam time HALF_T = CLK_PERIOD / 2;

    logic csb;
    logic sclk;
    logic sdi;
    wire sdo;

    byte rdata;
    logic [31 : 0] burst_wdata;
    logic [31 : 0] burst_rdata;

    int error_count = 0;
    int correct_count = 0;

    spi_wrapper dut (
        .csb(csb),
        .sclk(sclk),
        .sdi(sdi),
        .sdo(sdo)
    );

    initial begin
        csb = 1'b1;
        sclk = 1'b0;
        sdi = 1'b0;

        $display("---------------------------------------------------------");
        $display("Start simulation");
        $display("---------------------------------------------------------");
        #50;

        // Test 1: single-byte write/read
        $display("%0t : single-byte write/read", $realtime);
        spi_write(15'h0010, 8'hA5);
        spi_read(15'h0010, rdata);
        check_byte("addr 0x0010 readback", rdata, 8'hA5);

        // Test 2: overwrite - write a new value, confirm the old one is gone
        $display("%0t : overwrite", $realtime);
        spi_write(15'h0010, 8'h5A);
        spi_read(15'h0010, rdata);
        check_byte("addr 0x0010 after overwrite", rdata, 8'h5A);

        spi_write(15'h7FFF, 8'hEF);
        spi_read(15'h7FFF, rdata);
        check_byte("addr 0x7FFF readback", rdata, 8'hEF);

        // Test 3: burst write/read
        $display("%0t : burst write/read", $realtime);
        burst_wdata = {8'h11, 8'h22, 8'h33, 8'h44};

        spi_write_burst(15'h0020, burst_wdata);
        spi_read_burst(15'h0020, burst_rdata);
        check_byte("burst byte 0 (addr 0x0020)", burst_rdata[31 : 24], 8'h11);
        check_byte("burst byte 1 (addr 0x0021)", burst_rdata[23 : 16], 8'h22);
        check_byte("burst byte 2 (addr 0x0022)", burst_rdata[15 : 8],  8'h33);
        check_byte("burst byte 3 (addr 0x0023)", burst_rdata[7 : 0],   8'h44);

        $display("---------------------------------------------------------");
        $display("simulation Finshed");
        $display("---------------------------------------------------------");
        $display("correct count = %0d", correct_count);
        $display("error count = %0d", error_count);
        $display("---------------------------------------------------------");

        #50;
        $stop;
    end

    task clock_bit (input logic din, output logic dout);
        sdi = din;
        #(HALF_T) sclk = 1'b1;
        #(HALF_T) dout = sdo;
        sclk = 1'b0;
    endtask

    // Write one byte
    task spi_write (input logic [14 : 0] addr, input byte data);
        logic [15 : 0] header;
        logic dummy;

        header = {1'b0, addr};
        csb = 1'b0;
        #10;
        for (int i = 15; i >= 0; i--) clock_bit(header[i], dummy);
        for (int i = 7;  i >= 0; i--) clock_bit(data[i], dummy);
        #10;
        csb = 1'b1;
        #20;
    endtask

    // Read one byte
    task spi_read (input logic [14 : 0] addr, output byte data);
        logic [15 : 0] header;
        logic dummy, bit_out;

        header = {1'b1, addr};
        csb = 1'b0;
        #10;
        for (int i = 15; i >= 0; i--) clock_bit(header[i], dummy);
        for (int i = 7;  i >= 0; i--) begin
            clock_bit(1'b0, bit_out);
            data[i] = bit_out;
        end
        #10;
        csb = 1'b1;
        #20;
    endtask

    // Write 4 bytes
    task spi_write_burst (input logic [14 : 0] addr, input logic [31:0] data);
        logic [15 : 0] header;
        logic dummy;
        byte cur_byte;

        header = {1'b0, addr};
        csb = 1'b0;
        #10;
        for (int i = 15; i >= 0; i--) clock_bit(header[i], dummy);
        for (int b = 0; b < 4; b++) begin
            cur_byte = data[31 - b*8 -: 8];
            for (int i = 7; i >= 0; i--) clock_bit(cur_byte[i], dummy);
        end
        #10;
        csb = 1'b1;
        #20;
    endtask

    // Read 4 bytes
    task spi_read_burst (input logic [14 : 0] addr, output logic [31 : 0] data);
        logic [15 : 0] header;
        logic dummy, bit_out;
        byte cur_byte;

        header = {1'b1, addr};
        csb = 1'b0;
        #10;
        for (int i = 15; i >= 0; i--) clock_bit(header[i], dummy);
        for (int b = 0; b < 4; b++) begin
            for (int i = 7; i >= 0; i--) begin
                clock_bit(1'b0, bit_out);
                cur_byte[i] = bit_out;
            end
            data[31 - b*8 -: 8] = cur_byte;
        end
        #10;
        csb = 1'b1;
        #20;
    endtask

    // Self-checking
    task check_byte (input string name, input byte got, input byte exp);
        if (got === exp) begin
            $display("PASS: %s  = 0x%02h", name, got);
            correct_count++;
        end
        else begin
            $error("FAIL: %s  got=0x%02h expected=0x%02h", name, got, exp);
            error_count++;
        end
    endtask

endmodule
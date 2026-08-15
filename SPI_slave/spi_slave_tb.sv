module tb_spi_slave;

    logic rst_n;
    logic csb;
    logic sclk;
    logic sdi;
    logic sdo;

    int errors = 0;
    int checks = 0;

    spi_slave_wrapper dut (
        .rst_n (rst_n),
        .csb   (csb),
        .sclk  (sclk),
        .sdi   (sdi),
        .sdo   (sdo)
    );


    initial sclk = 1'b0;
    always #10 sclk = ~sclk;

    byte       golden_mem[bit [14:0]];   
    bit [14:0] covered_add[$];

    initial begin
        byte wdata[];
        byte rdata[];

        reset_dut();

        // ================= DIRECTED TESTS =================

        wdata = new[1];
        wdata[0] = 8'hA5;
        spi_write(15'h0010, wdata);
        spi_read(15'h0010, 1, rdata);
        check_burst_against_golden(15'h0010, rdata);

        wdata[0] = 8'h3C;
        spi_write(15'h0020, wdata);
        spi_read(15'h0010, 1, rdata);
        check_burst_against_golden(15'h0010, rdata);
        spi_read(15'h0020, 1, rdata);
        check_burst_against_golden(15'h0020, rdata);

        wdata = new[4];
        wdata[0] = 8'h11; wdata[1] = 8'h22; wdata[2] = 8'h33; wdata[3] = 8'h44;
        spi_write(15'h0100, wdata);
        spi_read(15'h0100, 4, rdata);
        check_burst_against_golden(15'h0100, rdata);

        wdata = new[4];
        wdata[0] = 8'hDE; wdata[1] = 8'hAD; wdata[2] = 8'hBE; wdata[3] = 8'hEF;
        spi_write(15'h7FFE, wdata);
        spi_read(15'h7FFE, 4, rdata);
        check_burst_against_golden(15'h7FFE, rdata);

        spi_abort_after_header(15'h0555, 8);   // deassert after 8 of 15 addr bits
        wdata = new[1];
        wdata[0] = 8'h77;
        spi_write(15'h0666, wdata);
        spi_read(15'h0666, 1, rdata);
        check_burst_against_golden(15'h0666, rdata);

        for (int iter = 0; iter < 30; iter++) begin
            logic [14:0] a;
            int len;
            len = $urandom_range(1, 8);
            a   =  $urandom_range(0, 32767);
            wdata = rand_data(len);
            spi_write(a, wdata);
            spi_read(a, len, rdata);
            check_burst_against_golden(a, rdata);
        end

        for (int r = 0; r < 20; r++) begin
            int idx;
            logic [14:0] a;
            if (covered_add.size() == 0) break;
            idx = $urandom_range(0, covered_add.size() - 1);
            a   = covered_add[idx];
            spi_read(a, 1, rdata);
            check_burst_against_golden(a, rdata);
        end

        if (errors == 0)
            $display("ALL %0d Tests passed", checks);
        else
            $display("%0d / %0d Tests failed", errors, checks);

        $finish;
    end

    task automatic reset_dut();
        rst_n = 1'b0;
        csb   = 1'b1;
        sdi   = 1'b0;
        repeat (2) @(negedge sclk);
        rst_n = 1'b1;
        repeat (2) @(negedge sclk);
    endtask


    task automatic transfer_bit(input bit tx_bit, output bit rx_bit);
        sdi = tx_bit;          
        @(posedge sclk);       
        rx_bit = sdo;          
        @(negedge sclk);       
    endtask


    task automatic spi_write(input logic [14:0] address, input byte data[]);
        bit dummy;
        int i, b;
        logic [14:0] a;

        @(negedge sclk);
        csb = 1'b0;                            

        transfer_bit(1'b0, dummy);                 
        for (i = 14; i >= 0; i--)
            transfer_bit(address[i], dummy);       

        for (b = 0; b < data.size(); b++)
            for (i = 7; i >= 0; i--)
                transfer_bit(data[b][i], dummy);   

        csb = 1'b1;                            
        repeat (2) @(negedge sclk);            

        a = address;
        for (b = 0; b < data.size(); b++) begin
            golden_mem[a] = data[b];
            covered_add.push_back(a);
            a = a + 15'd1;                    
        end
    endtask


    task automatic spi_abort_after_header(input logic [14:0] address, input int addr_sent);
        bit dummy;
        int i;

        @(negedge sclk);
        csb = 1'b0;

        transfer_bit(1'b0, dummy);                 
        for (i = 14; i >= 15 - addr_sent; i--)
            transfer_bit(address[i], dummy);       

        csb = 1'b1;                            
        repeat (2) @(negedge sclk);
    endtask


    task automatic spi_read(input logic [14:0] address, input int num_bytes, output byte data[]);
        bit rx;
        int i, b;

        data = new[num_bytes];

        @(negedge sclk);
        csb = 1'b0;

        transfer_bit(1'b1, rx);                    
        for (i = 14; i >= 0; i--)
            transfer_bit(address[i], rx);          

        for (b = 0; b < num_bytes; b++) begin
            for (i = 7; i >= 0; i--) begin
                transfer_bit(1'b0, rx);            
                data[b][i] = rx;
            end
        end

        csb = 1'b1;
        repeat (2) @(negedge sclk);
    endtask


    task automatic check_burst_against_golden(input logic [14:0] address, input byte data[]);
        logic [14:0] a;
        int b;

        a = address;
        for (b = 0; b < data.size(); b++) begin
            checks++;
            if (!golden_mem.exists(a)) begin
                $display("[WARN] address never written, skipping");
            end else if (data[b] !== golden_mem[a]) begin
                errors++;
                $display("[FAIL] got=0x%02h exp=0x%02h", data[b], golden_mem[a]);
            end else begin
                $display("[PASS] got=0x%02h exp=0x%02h", data[b], golden_mem[a]);
            end
            a = a + 15'd1;
        end
    endtask


    typedef byte byte_queue_t[];

    function automatic byte_queue_t rand_data(input int n);
        byte_queue_t q;
        q = new[n];
        foreach (q[i]) q[i] = byte'($urandom_range(0, 255));
        return q;
    endfunction


endmodule
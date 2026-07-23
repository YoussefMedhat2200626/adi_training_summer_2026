`timescale 1ns/1ps

module tb_ahb_lite_master;

    reg HCLK, HRESETn, user_write, user_start, user_burst_mode;
    reg user_fifo_write_en, user_fifo_read_en, HREADY, HRESP;
    reg [31:0] user_addr, user_fifo_din, HRDATA;

    wire [31:0] user_fifo_dout, HADDR, HWDATA;
    wire user_fifo_empty, HWRITE, HMASTLOCK;
    wire [1:0] HTRANS;
    wire [2:0] HSIZE, HBURST;
    wire [3:0] HPROT;

    ahb_lite_master dut (.HCLK(HCLK),.HRESETn(HRESETn),.user_addr(user_addr),.user_write(user_write),.user_start(user_start),
        .user_burst_mode(user_burst_mode),.user_fifo_write_en(user_fifo_write_en),.user_fifo_din(user_fifo_din),.user_fifo_read_en(user_fifo_read_en),
        .user_fifo_dout(user_fifo_dout),.user_fifo_empty(user_fifo_empty),.HREADY(HREADY),.HRESP(HRESP),.HRDATA(HRDATA),
        .HADDR(HADDR),.HWDATA(HWDATA),.HWRITE(HWRITE),.HTRANS(HTRANS),.HSIZE(HSIZE),.HBURST(HBURST),.HPROT(HPROT),.HMASTLOCK(HMASTLOCK));

    // clok
    initial begin
        HCLK = 0;
        forever #5 HCLK = ~HCLK; 
    end

    // reset
    initial begin
        HRESETn = 0;
        #20 HRESETn = 1;
    end

    // slave tasks
    task slave_okay_response(input [31:0] rdata);
        begin
            HREADY = 1;
            HRESP  = 0;
            HRDATA = rdata;
        end
    endtask

    task slave_error_response;
        begin
            HREADY = 1;
            HRESP  = 1;
        end
    endtask

    task slave_wait_state;
        begin
            HREADY = 0;
        end
    endtask

    initial begin
        user_addr = 32'h0000_1000;
        user_write = 1;
        user_start = 0;
        user_burst_mode = 1; // incr4
        user_fifo_write_en = 0;
        user_fifo_din = 0;
        user_fifo_read_en = 0;
        HREADY = 1;
        HRESP  = 0;
        HRDATA = 32'h0;

        // wait for reset
        @(posedge HRESETn);

        //load tx fifo with 4 words
        repeat (4) begin
            @(posedge HCLK);
            user_fifo_write_en = 1;
            user_fifo_din = $random;
        end
        @(posedge HCLK);
        user_fifo_write_en = 0;

        // start a write burst
        @(posedge HCLK);
        user_start = 1;
        @(posedge HCLK);
        user_start = 0;

        // slave responds okay each beat
        repeat (4) begin
            @(posedge HCLK);
            slave_okay_response(32'h6767_6767);
        end

        // wait for bus to be idle
        wait (HTRANS == 2'b00);
        
        // now test a read burst
        @(posedge HCLK);
        user_addr = 32'h0000_2000;
        user_write = 0;
        user_burst_mode = 1;
        user_start = 1;
        @(posedge HCLK);
        user_start = 0;

        // slave returns incrementing data
        repeat (4) begin
            @(posedge HCLK);
            slave_okay_response(32'h6767_6767);
        end

        // pop data from rx fifo
        repeat (4) begin
            @(posedge HCLK);
            if (!user_fifo_empty) begin
                user_fifo_read_en = 1;
                @(posedge HCLK);
                $display("read data from rx fifo: %h", user_fifo_dout);
                user_fifo_read_en = 0;
            end
        end

        // test error response
        @(posedge HCLK);
        user_addr = 32'h0000_3000;
        user_write = 1;
        user_burst_mode = 0;
        user_start = 1;
        @(posedge HCLK);
        user_start = 0;
        @(posedge HCLK);
        slave_error_response;#100 $stop;
    end

endmodule
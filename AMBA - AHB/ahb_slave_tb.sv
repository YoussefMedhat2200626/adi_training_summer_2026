import ahb_shared_pkg :: *;
module ahb_slave_tb;

bit                           HCLK;
reg                           HRESETn;
reg                           HSEL;
reg [ADDR_WIDTH - 1:0]        HADDR;
reg                           HWRITE;
size_e                        HSIZE;
burst_e                       HBURST;
transfer_e                    HTRANS;
reg                           HREADY;
reg [DATA_WIDTH - 1:0]        HWDATA;

logic                    HREADYOUT;
logic                    HRESP;
logic [DATA_WIDTH - 1:0] HRDATA;

ahb_slave uut (.*);

always #5 HCLK = ~HCLK;

task assert_reset();
    HRESETn = 0;
    @(negedge HCLK);
    HRESETn = 1;
endtask


task automatic slave_write_burst(bit [ADDR_WIDTH-1:0] addr, size_e sz, burst_e brst, int beats, int waits = 0);
    bit [DATA_WIDTH-1:0] wdata [0:15];
    int inc;
    inc = (1 << sz);

    HSEL = 1; HREADY = 1; HWRITE = 1; HSIZE = sz; HBURST = brst;

    for (int b = 0; b <= beats; b++) begin
        if (b < beats) begin
            HADDR    = addr + b*inc;
            HTRANS   = (b == 0) ? NONSEQ : SEQ;
            wdata[b] = $urandom_range(0,5000);
        end
        if (b >= 1) begin
            HWDATA = wdata[b-1];
            $display("  WRITE beat%0d @0x%0h = 0x%0h", b-1, addr+(b-1)*inc, wdata[b-1] & ((1 << (8*inc)) - 1));
        end

        if (b == beats && waits > 0) begin
            HREADY = 0;
            repeat (waits) @(negedge HCLK);
            HREADY = 1;
        end

        @(negedge HCLK);
    end

    HSEL = 0; HTRANS = IDLE;
endtask


task automatic slave_read_burst(bit [ADDR_WIDTH-1:0] addr, size_e sz, burst_e brst, int beats, int waits = 0);
    int inc;
    inc = (1 << sz);

    HSEL = 1; HREADY = 1; HWRITE = 0; HSIZE = sz; HBURST = brst;

    for (int b = 0; b <= beats; b++) begin
        if (b < beats) begin
            HADDR  = addr + b*inc;
            HTRANS = (b == 0) ? NONSEQ : SEQ;
        end

        if (b == beats && waits > 0) begin
            HREADY = 0;
            repeat (waits) @(negedge HCLK);
            HREADY = 1;
        end

        @(negedge HCLK);

        if (b >= 1)
            $display("  READ beat%0d @0x%0h = 0x%0h", b-1, addr+(b-1)*inc, HRDATA & ((1 << (8*inc)) - 1));
    end

    HSEL = 0; HTRANS = IDLE;
endtask

// Holds HREADY low for `cycles` cycles and prints the observed
// HRESP/error_flag each cycle (2-bit wraparound counter inside the
// DUT - no expected-value comparison here, just observation).
task automatic hold_not_ready(int cycles);
    HSEL = 1; HREADY = 0;
    for (int k = 1; k <= cycles; k++) begin
        @(negedge HCLK);
        $display("  cycle %0d: HRESP=%0d error_flag=%0d", k, HRESP, uut.error_flag);
    end
    HREADY = 1;
    @(negedge HCLK);
    HSEL = 0;
endtask

initial begin
    HSEL=0; HADDR=0; HWRITE=0; HSIZE=Byte; HBURST=SINGLE; HTRANS=IDLE;
    HREADY=0; HWDATA=0;
    assert_reset;

    //----------------------------------------------------------
    // Test a : reset - read back memory, should show 0
    //----------------------------------------------------------
    $display("\n========== TEST a : POST-RESET READ, WORD, 0x10 ==========");
    slave_read_burst(32'h10, Word, SINGLE, 1);
    @(negedge HCLK);

    //----------------------------------------------------------
    // Test b : SINGLE write/read, word, 0x30
    //----------------------------------------------------------
    $display("\n========== TEST b : SINGLE WRITE/READ, WORD, 0x30 ==========");
    slave_write_burst(32'h30, Word, SINGLE, 1);
    @(negedge HCLK);
    slave_read_burst(32'h30, Word, SINGLE, 1);
    @(negedge HCLK);

    //----------------------------------------------------------
    // Test c : 4-beat write/read, word, 0x38 (INCR4-style)
    //----------------------------------------------------------
    $display("\n========== TEST c : INCR4-STYLE WRITE/READ, WORD, 0x38 ==========");
    slave_write_burst(32'h38, Word, INCR4, 4);
    @(negedge HCLK);
    slave_read_burst(32'h38, Word, INCR4, 4);
    @(negedge HCLK);

    //----------------------------------------------------------
    // Test d : 8-beat write/read, halfword, 0x50 (INCR8-style)
    //----------------------------------------------------------
    $display("\n========== TEST d : INCR8-STYLE WRITE/READ, HALFWORD, 0x50 ==========");
    slave_write_burst(32'h50, Halfword, INCR8, 8);
    @(negedge HCLK);
    slave_read_burst(32'h50, Halfword, INCR8, 8);
    @(negedge HCLK);

    //----------------------------------------------------------
    // Test e : 4-beat write/read, byte, 0x60
    //----------------------------------------------------------
    $display("\n========== TEST e : 4-BEAT WRITE/READ, BYTE, 0x60 ==========");
    slave_write_burst(32'h60, Byte, INCR4, 4);
    @(negedge HCLK);
    slave_read_burst(32'h60, Byte, INCR4, 4);
    @(negedge HCLK);

    //----------------------------------------------------------
    // Test f : byte-level partial overwrite inside an existing word
    //----------------------------------------------------------
    $display("\n========== TEST f : BYTE PARTIAL OVERWRITE INSIDE WORD @0x38 ==========");
    slave_write_burst(32'h39, Byte, SINGLE, 1);   // overwrite just byte offset 1 of the 0x38 word
    @(negedge HCLK);
    slave_read_burst(32'h38, Word, SINGLE, 1);    // whole word: 3 old bytes + 1 new byte
    @(negedge HCLK);

    //----------------------------------------------------------
    // Test g : write with 2 wait states, word, 0x70
    //----------------------------------------------------------
    $display("\n========== TEST g : WRITE, WORD, 0x70, 2 WAIT STATES ==========");
    slave_write_burst(32'h70, Word, SINGLE, 1, 2);
    @(negedge HCLK);
    slave_read_burst(32'h70, Word, SINGLE, 1);
    @(negedge HCLK);

    //----------------------------------------------------------
    // Test h : read with 1 wait state, word, 0x38
    //----------------------------------------------------------
    $display("\n========== TEST h : READ, WORD, 0x38, 1 WAIT STATE ==========");
    slave_read_burst(32'h38, Word, SINGLE, 1, 1);
    @(negedge HCLK);

    //----------------------------------------------------------
    // Test i : HSEL deasserted mid-transfer
    //----------------------------------------------------------
    $display("\n========== TEST i : HSEL=0 MID-TRANSFER ==========");
    HSEL=0; HREADY=1; HWRITE=1; HSIZE=Word; HBURST=SINGLE;
    HADDR=32'h100; HTRANS=NONSEQ; HWDATA=32'hDEAD_BEEF;
    @(negedge HCLK);
    HADDR=32'h104; HTRANS=SEQ;
    @(negedge HCLK);
    HTRANS = IDLE;
    $display("  mem[0x100] = 0x%0h",
        {uut.slave_mem[32'h103],uut.slave_mem[32'h102],uut.slave_mem[32'h101],uut.slave_mem[32'h100]});

    //----------------------------------------------------------
    // Test j : HTRANS=BUSY mid-burst
    //----------------------------------------------------------
    $display("\n========== TEST j : HTRANS=BUSY MID-BURST ==========");
    HSEL=1; HREADY=1; HWRITE=1; HSIZE=Word; HBURST=INCR;
    HADDR=32'h200; HTRANS=NONSEQ;
    @(negedge HCLK);
    HADDR=32'h204; HTRANS=BUSY; HWDATA=32'h1111_1111;
    @(negedge HCLK);
    HADDR=32'h204; HTRANS=SEQ; HWDATA=32'h2222_2222;
    @(negedge HCLK);
    HWDATA=32'h3333_3333; // flush for the beat at 0x204
    @(negedge HCLK);
    HSEL=0; HTRANS=IDLE;
    $display("  mem[0x200] = 0x%0h",
        {uut.slave_mem[32'h203],uut.slave_mem[32'h202],uut.slave_mem[32'h201],uut.slave_mem[32'h200]});

    repeat (10) @(negedge HCLK);

    $stop;
end
endmodule
import ahb_shared_pkg :: *;
module ahb_master_tb;

reg                           HCLK;
reg                           HRESETn;
reg [ADDR_WIDTH - 1:0]        addr_in;
reg [DATA_WIDTH - 1:0]        data_in;
reg                           start;

burst_e                   burst;
size_e                    size;
reg                           write;
reg                           HREADY;
reg                           HRESP;
reg [DATA_WIDTH - 1:0]        HRDATA;
reg [15:0]                    transfer_count; // for INCR
logic [ADDR_WIDTH - 1:0] HADDR;
logic                    HWRITE;
size_e                   HSIZE;
burst_e                  HBURST;
transfer_e               HTRANS;
logic [DATA_WIDTH - 1:0] HWDATA;

ahb_master uut(.*);

initial HCLK = 0;
always #5 HCLK = ~HCLK;

bit [7:0] slave_mem [1024];
bit [ADDR_WIDTH - 1:0] wr_addr [20];
int i = 0;

task assert_reset();
    HRESETn = 0;
    @(posedge HCLK);
    HRESETn = 1;
endtask

task automatic mem_write(int waits = 0);
    if (waits > 0) begin
        HREADY = 0;
        repeat (waits) @(negedge HCLK);
    end
    HREADY = 1;
    @(negedge HCLK);
    data_in = $urandom_range(0,1000);
    @(posedge HCLK);
    for (int j = 0; j < (1 << size); j++) begin
        slave_mem[wr_addr[i-1] + j] = HWDATA[(8*j) +: 8];
    end
    wr_addr[i] = HADDR;
    i++;
endtask

task automatic read_beat(int waits = 0);
    if (waits > 0) begin
        HREADY = 0;
        repeat (waits) @(negedge HCLK);
    end
    HREADY = 1;
    @(negedge HCLK);
    HRDATA = $urandom_range(0,1000);
endtask


task automatic write_burst(
    input bit [ADDR_WIDTH-1:0] addr,
    input burst_e              brst,
    input size_e               sz,
    input int                  beats,
    input int                  first_beat_waits = 0
);
    i = 0; 

    start          = 1;
    HREADY         = 1;
    write          = 1;
    addr_in        = addr;
    burst          = brst;
    size           = sz;
    transfer_count = beats; 

    @(posedge HCLK);
    wr_addr[i] = HADDR;
    i++;

    mem_write(first_beat_waits);
    if (beats > 1)
        repeat (beats - 1) mem_write();

    start = 0;
endtask

task automatic read_burst(
    input bit [ADDR_WIDTH-1:0] addr,
    input burst_e              brst,
    input size_e                sz,
    input int                  beats,
    input int                  first_beat_waits = 0
);
    start          = 1;
    HREADY         = 1;
    write          = 0;
    addr_in        = addr;
    burst          = brst;
    size           = sz;
    transfer_count = beats;

    @(negedge HCLK); 

    read_beat(first_beat_waits);
    if (beats > 1)
        repeat (beats - 1) read_beat();

    start = 0;
endtask


task automatic write_then_read_incr(
    input bit [ADDR_WIDTH-1:0] waddr,
    input size_e                wsz,
    input int                  wcount,
    input bit [ADDR_WIDTH-1:0] raddr,
    input size_e                rsz,
    input int                  rcount
);
    i = 0;

    start          = 1;
    HREADY         = 1;
    write          = 1;
    addr_in        = waddr;
    burst          = INCR;
    size           = wsz;
    transfer_count = wcount;

    @(posedge HCLK);
    wr_addr[i] = HADDR;
    i++;

    repeat (wcount - 1) mem_write();

    write          = 0;
    addr_in        = raddr;
    burst          = INCR;
    size           = rsz;
    transfer_count = rcount;

    @(negedge HCLK); 
    data_in = $urandom_range(0,1000);
    
    @(posedge HCLK);
    for (int j=0; j<(1<<size); ++j) begin
        slave_mem[wr_addr[i-1]+j] = HWDATA[(8*j) +: 8];
    end
    wr_addr[i] = HADDR;
    i++;
    repeat (rcount) read_beat();

    start = 0;
    repeat (3) @(posedge HCLK);
endtask



initial begin
    addr_in = 0;
    data_in = 0;
    start = 0;
    burst   = SINGLE;
    size    = Byte;
    write   = 0;
    HREADY  = 0;
    HRESP   = 0;
    HRDATA  = 0;
    transfer_count = 0;

    assert_reset;

    //----------------------------------------------------------
    // Test a : WRAP4 write, word, base_addr = 0x38
    //----------------------------------------------------------
    $display("\n========== TEST a : WRAP4 WRITE, WORD, 0x38 ==========");
    write_burst(32'h38, WRAP4, Word, 4);
    repeat (3) @(posedge HCLK);


    //----------------------------------------------------------
    // Test b : INCR8 write, halfword, base_addr = 0x34
    //----------------------------------------------------------
    $display("\n========== TEST b : INCR8 WRITE, HALFWORD, 0x34 ==========");
    write_burst(32'h34, INCR8, Halfword, 8);
    repeat (3) @(posedge HCLK);


    //----------------------------------------------------------
    // Test c : WRAP8 read, word, base_addr = 0x38
    //----------------------------------------------------------
    $display("\n========== TEST c : WRAP8 READ, WORD, 0x38 ==========");
    read_burst(32'h38, WRAP8, Word, 8);
    repeat (3) @(posedge HCLK);

    //----------------------------------------------------------
    // Test d : INCR8 read, halfword, base_addr = 0x34
    //----------------------------------------------------------
    $display("\n========== TEST d : INCR8 READ, HALFWORD, 0x34 ==========");
    read_burst(32'h34, INCR8, Halfword, 8);
    repeat (3) @(posedge HCLK);

    //----------------------------------------------------------
    // Test e : INCR write (count=2) -> INCR read (count=3), no gap
    //----------------------------------------------------------
    $display("\n========== TEST e : INCR WRITE(2) -> INCR READ(3) ==========");
    write_then_read_incr(32'h20, Halfword, 2, 32'h5c, Word, 3);

    //----------------------------------------------------------
    // Test f : INCR4 write, word, base_addr = 0x38, 1 wait state
    //----------------------------------------------------------
    $display("\n========== TEST f : INCR4 WRITE, WORD, 0x38, 1 WAIT ==========");
    write_burst(32'h38, INCR4, Word, 4, 1);
    repeat (3) @(posedge HCLK);

    //----------------------------------------------------------
    // Test g : WRAP4 write, word, base_addr = 0x34, 2 wait states
    //----------------------------------------------------------
    $display("\n========== TEST g : WRAP4 WRITE, WORD, 0x34, 2 WAITS ==========");
    write_burst(32'h34, WRAP4, Word, 4, 2);
    repeat (3) @(posedge HCLK);

    //----------------------------------------------------------
    // Test i : INCR4 read, word, base_addr = 0x38, 1 wait state
    //----------------------------------------------------------
    $display("\n========== TEST i : INCR4 READ, WORD, 0x38, 1 WAIT ==========");
    read_burst(32'h38, INCR4, Word, 4, 1);
    repeat (3) @(posedge HCLK);

    //----------------------------------------------------------
    // Test j : WRAP4 read, word, base_addr = 0x34, 2 wait states
    //----------------------------------------------------------
    $display("\n========== TEST j : WRAP4 READ, WORD, 0x34, 2 WAITS ==========");
    read_burst(32'h34, WRAP4, Word, 4, 2);
    repeat (3) @(posedge HCLK);




    $stop;
end
endmodule
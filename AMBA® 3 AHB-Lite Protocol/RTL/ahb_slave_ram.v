module ahb_slave_ram #(
    parameter ADDR_WIDTH     = 32,
    parameter DATA_WIDTH     = 32,
    parameter MEM_DEPTH_BYTES= 4096,
    parameter WAIT_THRESHOLD = 32'h00000100,
    parameter WAIT_CYCLES    = 2
) (
    input  wire                      hclk_i,
    input  wire                      hresetn_i,

    // AHB-Lite Slave Interface
    input  wire [ADDR_WIDTH-1:0]     haddr_i,
    input  wire [1:0]                htrans_i,
    input  wire [2:0]                hburst_i,
    input  wire [2:0]                hsize_i,
    input  wire                      hwrite_i,
    input  wire [3:0]                hprot_i,
    input  wire                      hmastlock_i,
    input  wire [DATA_WIDTH-1:0]     hwdata_i,

    output reg                       hreadyout_o,
    output wire                      hresp_o,       // Always OKAY (0)
    output reg  [DATA_WIDTH-1:0]     hrdata_o
);

    localparam [1:0] HTRANS_NONSEQ = 2'b10;
    localparam [1:0] HTRANS_SEQ    = 2'b11;
    localparam [2:0] HSIZE_HALFWORD = 3'b001;
    localparam [2:0] HSIZE_WORD     = 3'b010;

    assign hresp_o = 1'b0;

    localparam MEM_WORDS = MEM_DEPTH_BYTES / 4;
    reg [DATA_WIDTH-1:0] mem [0:MEM_WORDS-1];

    // Initialize Memory Array to 0
    integer i;
    initial begin
        for (i = 0; i < MEM_WORDS; i = i + 1) begin
            mem[i] = {DATA_WIDTH{1'b0}};
        end
    end

    // Address-Phase Pipeline Registers
    reg [ADDR_WIDTH-1:0] addr_ph_r;
    reg                  write_ph_r;
    reg [2:0]            size_ph_r;
    reg                  valid_ph_r;

    wire transfer_valid;
    assign transfer_valid = (htrans_i == HTRANS_NONSEQ) || (htrans_i == HTRANS_SEQ);

    reg [7:0] wait_cnt_r;
    reg       waiting_r;

    wire addr_needs_wait;
    assign addr_needs_wait = (haddr_i >= WAIT_THRESHOLD);

    always @(posedge hclk_i or negedge hresetn_i) begin
        if (!hresetn_i) begin
            addr_ph_r  <= {ADDR_WIDTH{1'b0}};
            write_ph_r <= 1'b0;
            size_ph_r  <= HSIZE_WORD;
            valid_ph_r <= 1'b0;
        end else if (hreadyout_o) begin
            addr_ph_r  <= haddr_i;
            write_ph_r <= hwrite_i;
            size_ph_r  <= hsize_i;
            valid_ph_r <= transfer_valid;
        end
    end

    // Dynamic Wait-State Generation
    always @(posedge hclk_i or negedge hresetn_i) begin
        if (!hresetn_i) begin
            wait_cnt_r  <= 8'd0;
            waiting_r   <= 1'b0;
            hreadyout_o <= 1'b1;
        end else begin
            if (!waiting_r) begin
                if (hreadyout_o && transfer_valid && addr_needs_wait && (WAIT_CYCLES > 0)) begin
                    waiting_r   <= 1'b1;
                    wait_cnt_r  <= WAIT_CYCLES[7:0] - 8'd1;
                    hreadyout_o <= 1'b0;
                end else begin
                    hreadyout_o <= 1'b1;
                end
            end else begin
                if (wait_cnt_r == 8'd0) begin
                    waiting_r   <= 1'b0;
                    hreadyout_o <= 1'b1;
                end else begin
                    wait_cnt_r  <= wait_cnt_r - 8'd1;
                    hreadyout_o <= 1'b0;
                end
            end
        end
    end

    wire [ADDR_WIDTH-1:0] word_index;
    assign word_index = addr_ph_r[ADDR_WIDTH-1:2];

    // Synchronous Write Operation
    always @(posedge hclk_i) begin
        if (valid_ph_r && hreadyout_o && write_ph_r) begin
            if (size_ph_r == HSIZE_WORD) begin
                mem[word_index] <= hwdata_i;
            end else if (size_ph_r == HSIZE_HALFWORD) begin
                if (addr_ph_r[1] == 1'b0)
                    mem[word_index][15:0] <= hwdata_i[15:0];
                else
                    mem[word_index][31:16] <= hwdata_i[15:0];
            end
        end
    end

    // Combinational Read Output during Data Phase
    always @(*) begin
        if (valid_ph_r && !write_ph_r) begin
            if (size_ph_r == HSIZE_WORD) begin
                hrdata_o = mem[word_index];
            end else if (size_ph_r == HSIZE_HALFWORD) begin
                if (addr_ph_r[1] == 1'b0)
                    hrdata_o = {16'b0, mem[word_index][15:0]};
                else
                    hrdata_o = {16'b0, mem[word_index][31:16]};
            end else begin
                hrdata_o = {DATA_WIDTH{1'b0}};
            end
        end else begin
            hrdata_o = {DATA_WIDTH{1'b0}};
        end
    end

endmodule
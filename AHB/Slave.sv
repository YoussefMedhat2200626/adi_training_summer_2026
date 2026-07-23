module ahb_slave_memory #(
    parameter MEM_SIZE = 1024 // Total memory size in bytes
)(
    input  logic        hclk,
    input  logic        hresetn,

    // AHB Slave Interface
    input  logic        hsel,
    input  logic [31:0] haddr,
    input  logic [1:0]  htrans,
    input  logic        hwrite,
    input  logic [2:0]  hsize,
    input  logic [2:0]  hburst,
    input  logic [3:0]  hprot,        
    input  logic        hmastlock,   
    input  logic [31:0] hwdata,
    input  logic        hready_in,

    output logic [31:0] hrdata,
    output logic        hready_out, 
    output logic        hresp       
);

    // AHB HTRANS Encoding
    localparam logic [1:0] HTRANS_IDLE   = 2'b00;
    localparam logic [1:0] HTRANS_BUSY   = 2'b01;
    localparam logic [1:0] HTRANS_NONSEQ = 2'b10;
    localparam logic [1:0] HTRANS_SEQ    = 2'b11;

    localparam logic HRESP_OKAY  = 1'b0;
    localparam logic HRESP_ERROR = 1'b1;

    // Internal Memory Array (Word Addressable)
    localparam MEM_WORDS = MEM_SIZE / 4;
    logic [31:0] mem [0:MEM_WORDS-1];

    // Address Phase Registers
    logic        data_phase_active;
    logic        latched_write;
    logic [31:0] latched_addr;
    logic [2:0]  latched_size;
    logic [3:0]  latched_prot;
    logic        latched_lock;

    logic ahb_transfer_valid;
    assign ahb_transfer_valid = hsel && hready_in && (htrans == HTRANS_NONSEQ || htrans == HTRANS_SEQ);

    // Address Phase Signals
    always_ff @(posedge hclk or negedge hresetn) begin
        if (!hresetn) begin
            data_phase_active <= 1'b0;
            latched_write     <= 1'b0;
            latched_addr      <= 32'd0;
            latched_size      <= 3'd0;
            latched_prot      <= 4'd0;
            latched_lock      <= 1'b0;
        end else begin
            if (hready_out) begin 
                data_phase_active <= ahb_transfer_valid;

                if (ahb_transfer_valid) begin
                    latched_write <= hwrite;
                    latched_addr  <= haddr;
                    latched_size  <= hsize;
                    latched_prot  <= hprot;    
                    latched_lock  <= hmastlock;
                end
            end
        end
    end

    // Data Phase Logic
    logic [29:0] word_addr;
    logic [3:0]  byte_we;    // Byte write enable

    // Word align the address
    assign word_addr = latched_addr[31:2];

    // Decode HSIZE into byte lanes based on the lower 2 bits of the address
    always_comb begin
        byte_we = 4'b0000;
        
        if (data_phase_active && latched_write) begin
            case (latched_size)
                3'b000: begin // Byte transfer
                    byte_we[latched_addr[1:0]] = 1'b1;
                end
                3'b001: begin // Halfword transfer
                    byte_we[latched_addr[1:0]]     = 1'b1;
                    byte_we[latched_addr[1:0] + 1] = 1'b1;
                end
                3'b010: begin // Word transfer
                    byte_we = 4'b1111; 
                end
                default: byte_we = 4'b1111;
            endcase
        end
    end

    // Memory Writes (Data Phase)
    always_ff @(posedge hclk) begin
       
        // Example logic block illustrating HPROT usage: 
        // If memory mapped as privileged-only, (!latched_prot[1]) could be checked  
        // here to block writes from User-mode requests.

        if (data_phase_active && latched_write && hready_out) begin
            if (byte_we[0]) mem[word_addr][7:0]   <= hwdata[7:0];
            if (byte_we[1]) mem[word_addr][15:8]  <= hwdata[15:8];
            if (byte_we[2]) mem[word_addr][23:16] <= hwdata[23:16];
            if (byte_we[3]) mem[word_addr][31:24] <= hwdata[31:24];
        end
    end

    // Memory Reads (Data Phase)
    always_comb begin // Combinational for read data to be ready by the next clock cycle
        hrdata = 32'd0; // Default read data

        if (data_phase_active && !latched_write && hready_out) begin
            hrdata = mem[word_addr];
        end
    end

    // Slave Output Responses
    
    // Assuming a zero Wait-State Slave: Memory responds immediately on the next clock cycle. 
    assign hready_out = 1'b1; 
    
    // Returns OKAY by default. 
    // If `latched_prot` indicated an illegal 
    // access to a memory block, the slave would transition to an 
    // ERROR response state machine here.
    assign hresp = HRESP_OKAY;

endmodule
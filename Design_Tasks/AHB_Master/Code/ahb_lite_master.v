module ahb_lite_master (
    input HCLK,HRESETn,
    
    // user inputs
    input   [31:0] user_addr,
    input   user_write,      // 1 = write and 0 = read
    input   user_start,      // trigger transaction
    input   user_burst_mode, // 0 = single, 1 = incr4
    
    // tx fifo controls
    input   user_fifo_write_en,
    input   [31:0] user_fifo_din,
    
    // rx fifo controls
    input   user_fifo_read_en,   // user reads data from RX FIFO
    output  [31:0] user_fifo_dout,      // read data output
    output  user_fifo_empty,     // empty flag
    
    // slave response
    input   HREADY,          // slave ready
    input   HRESP,           // 0 = okay and 1 = error
    input   [31:0] HRDATA,          // read data
    
    // master outputs
    output reg  [31:0] HADDR,
    output reg  [31:0] HWDATA,
    output reg         HWRITE,
    output reg  [1:0]  HTRANS,
    output reg  [2:0]  HSIZE,
    output reg  [2:0]  HBURST,
    output reg  [3:0]  HPROT,
    output reg         HMASTLOCK
);
    //states
    localparam IDLE  = 2'b00, ADDR  = 2'b01, DATA  = 2'b10;
    reg [1:0] state;

    reg tx_fifo_rstn, rx_fifo_rstn;
    reg [31:0] addr_reg;
    reg        write_reg;
    reg [2:0]  burst_count;

    wire [31:0] tx_fifo_dout;
    wire tx_fifo_full, tx_fifo_empty;
    reg  tx_fifo_read_en,rx_fifo_write_en;

    fifo tx_fifo (.clk(HCLK),.reset(tx_fifo_rstn),.write_en(user_fifo_write_en),.read_en(tx_fifo_read_en),.din(user_fifo_din),
    .dout(tx_fifo_dout),.full(tx_fifo_full),.empty(tx_fifo_empty));

    
    fifo rx_fifo (.clk(HCLK),.reset(rx_fifo_rstn),.write_en(rx_fifo_write_en),.read_en(user_fifo_read_en),.din(HRDATA),
    .dout(user_fifo_dout),.full(),.empty(user_fifo_empty));

    always @(posedge HCLK or negedge HRESETn) begin
        tx_fifo_rstn <= HRESETn;
        rx_fifo_rstn <= HRESETn;
        if (!HRESETn) begin
            state   <= IDLE;
            HTRANS  <= 2'b00; // IDLE state
            HWRITE  <= 1'b0;
            HADDR   <= 32'b0;
            HWDATA  <= 32'b0;
            HBURST  <= 3'b000;
            burst_count <= 0;
            tx_fifo_read_en <= 0;
            rx_fifo_write_en <= 0;
        end else begin
            tx_fifo_read_en <= 0;
            rx_fifo_write_en <= 0; 
            case (state)
                IDLE: if (user_start) begin
                    // save user inputs
                    addr_reg  <= user_addr;
                    write_reg <= user_write;

                    HADDR   <= user_addr;
                    HWRITE  <= user_write;
                    HSIZE   <= 3'b010; // word transfer
                    HBURST  <= user_burst_mode ? 3'b011 : 3'b000; // incr4 or single
                    HPROT   <= 4'b0011; // non cacheable 0 ,non bufferable 0, Privileged access 1 , data 1
                    HMASTLOCK <= 1'b0; // no lock
                    HTRANS  <= 2'b10; // NONSEQ
                    burst_count <= user_burst_mode ? 3'd4 : 3'd1;
                    state   <= ADDR;
                end

                ADDR: if (HREADY) begin
                    if (write_reg && !tx_fifo_empty) begin
                        tx_fifo_read_en <= 1;   // next word
                        HWDATA <= tx_fifo_dout; // drive data bus
                    end
                    state <= DATA;
                end

                DATA: if (HREADY) begin
                    // check slave response
                    if (HRESP == 1'b0) begin
                        // okay response
                        if (!write_reg) begin
                            // save read data into RX FIFO
                            rx_fifo_write_en <= 1;
                        end
                        burst_count <= burst_count - 1;
                        if (burst_count > 1) begin
                            // Continue burst
                            addr_reg <= addr_reg + 4; // increment by word size
                            HADDR    <= addr_reg + 4;
                            HTRANS   <= 2'b11; // SEQ
                            state    <= ADDR;
                        end else begin
                            // end of burst
                            HTRANS <= 2'b00; // IDLE
                            state  <= IDLE;
                        end
                    end else if (HRESP == 1'b1) begin
                        // error response deletes data from both fifos
                        tx_fifo_rstn <= 1'b0;
                        rx_fifo_rstn <= 1'b0;
                        HTRANS <= 2'b00; // go to idle
                        state  <= IDLE;
                    end
                end

            endcase
        end
    end
endmodule
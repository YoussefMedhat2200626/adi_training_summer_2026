

module ahb_slave_mem
    import ahb_lite_pkg::*;
#(
    parameter WAIT_STATES = 0   
)(
        input  logic        HCLK,
    input  logic        HRESETn,

        input  logic        HSEL,           
    input  logic [31:0] HADDR,          
    input  logic [31:0] HWDATA,         
    input  logic        HWRITE,         
    input  logic [2:0]  HSIZE,          
    input  logic [2:0]  HBURST,         
    input  logic [1:0]  HTRANS,         
    input  logic        HREADY,         

    output logic [31:0] HRDATA,         
    output logic        HREADYOUT,      
    output logic        HRESP           
);

    logic [31:0] mem [0:255];

    logic valid_transfer;
    assign valid_transfer = HSEL && HREADY &&
                            (HTRANS == HTRANS_NONSEQ || HTRANS == HTRANS_SEQ);

    logic        wr_en_r;           
    logic [7:0]  addr_word_r;       
    logic [2:0]  hsize_r;           
    logic [1:0]  addr_byte_r;       

    always_ff @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            wr_en_r     <= 1'b0;
            addr_word_r <= 8'd0;
            hsize_r     <= HSIZE_WORD;
            addr_byte_r <= 2'b00;
        end else if (HREADY) begin
            
            wr_en_r     <= valid_transfer && HWRITE;
            addr_word_r <= HADDR[9:2];
            hsize_r     <= HSIZE;
            addr_byte_r <= HADDR[1:0];
        end
    end

    logic [3:0] byte_en;

    always_comb begin
        byte_en = 4'b0000;
        case (hsize_r)
            HSIZE_BYTE: begin
                case (addr_byte_r)
                    2'b00: byte_en = 4'b0001;
                    2'b01: byte_en = 4'b0010;
                    2'b10: byte_en = 4'b0100;
                    2'b11: byte_en = 4'b1000;
                endcase
            end
            HSIZE_HALF: begin
                case (addr_byte_r[1])
                    1'b0: byte_en = 4'b0011;
                    1'b1: byte_en = 4'b1100;
                endcase
            end
            HSIZE_WORD: begin
                byte_en = 4'b1111;
            end
            default: byte_en = 4'b1111;
        endcase
    end

    always_ff @(posedge HCLK) begin
        if (wr_en_r && HREADYOUT) begin
            if (byte_en[0]) mem[addr_word_r][7:0]   <= HWDATA[7:0];
            if (byte_en[1]) mem[addr_word_r][15:8]  <= HWDATA[15:8];
            if (byte_en[2]) mem[addr_word_r][23:16] <= HWDATA[23:16];
            if (byte_en[3]) mem[addr_word_r][31:24] <= HWDATA[31:24];
        end
    end

    assign HRDATA = mem[addr_word_r];

    generate
        if (WAIT_STATES == 0) begin : gen_no_wait
            
            assign HREADYOUT = 1'b1;
        end else begin : gen_wait
            
            logic [3:0] wait_cnt;

            always_ff @(posedge HCLK or negedge HRESETn) begin
                if (!HRESETn) begin
                    wait_cnt <= 4'd0;
                end else if (valid_transfer && HREADYOUT) begin
                    
                    wait_cnt <= WAIT_STATES[3:0];
                end else if (wait_cnt > 0) begin
                    wait_cnt <= wait_cnt - 1;
                end
            end

            assign HREADYOUT = (wait_cnt == 0);
        end
    endgenerate

    assign HRESP = HRESP_OKAY;

endmodule

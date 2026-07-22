import ahb_shared_pkg :: *;
module ahb_master(
    input                           HCLK,
    input                           HRESETn,
    input [ADDR_WIDTH - 1:0]        addr_in,
    input [DATA_WIDTH - 1:0]        data_in,
    input                           start,
    input burst_e                   burst,
    input size_e                    size,
    input                           write,
    input [15:0]                    transfer_count, // for INCR 
    input                           HREADY,
    input                           HRESP,
    input [DATA_WIDTH - 1:0]        HRDATA,

    output logic [ADDR_WIDTH - 1:0] HADDR,
    output logic                    HWRITE,
    output size_e                   HSIZE,
    output burst_e                  HBURST,
    output transfer_e               HTRANS,
    output logic [DATA_WIDTH - 1:0] HWDATA
);

assign HWRITE = write;
assign HSIZE = size;
assign HBURST = burst;
// FSM States
state_e ps,ns;
logic [7:0] master_mem [1024];
logic [ADDR_WIDTH - 1:0] read_addr_buffer [16];
logic [3:0] addr_ptr;





// address calc
logic [6:0] addr_inc;
assign addr_inc = 1 << size;

logic [ADDR_WIDTH - 1:0] next_addr;
logic [ADDR_WIDTH - 1:0] next_addr_sel;
assign next_addr = HADDR + addr_inc;

logic [3:0] beats_count;
logic [3:0] beats;
logic [7:0] wrap_size;
logic [3:0] beats_sel;
assign beats_sel = (burst == INCR)? beats_count : beats;
assign wrap_size = addr_inc * beats_sel;

logic [ADDR_WIDTH - 1:0] wrap_base;
assign wrap_base = addr_in & ~(wrap_size - 1);



always @* begin
    case (burst)
        SINGLE: begin
            next_addr_sel = next_addr;
            beats = 1;
        end
        INCR: begin
            next_addr_sel = next_addr;
            beats = 0;
        end
        WRAP4,WRAP8,WRAP16: begin
            beats = (burst << 1);
            next_addr_sel = (next_addr == wrap_base + wrap_size)? wrap_base : next_addr;
        end
        INCR4: begin
            next_addr_sel = next_addr;
            beats = 4;
        end
        INCR8: begin
            next_addr_sel = next_addr;
            beats = 8;
        end
        INCR16: begin
            next_addr_sel = next_addr;
            beats =16;
        end
        default: begin
            next_addr_sel = next_addr;
            beats = beats;
        end
    endcase
end

always @(negedge HCLK, negedge HRESETn) begin
    if (!HRESETn) begin
        HADDR <= 0;
    end
    else if (ns == ADDR || (burst == SINGLE)) begin
        HADDR <= addr_in;
    end
    else if (ns == WAIT || ns == ERROR) begin
        HADDR <= HADDR;
    end
    else begin
        HADDR <= next_addr_sel;
    end
end



// state mem
always @(negedge HCLK, negedge HRESETn) begin
    if (!HRESETn) begin
        ps <= IDLE_S;
        HWDATA <= 0;
    end else begin
        ps <= ns;
    end
end
always @(posedge HCLK, negedge HRESETn) begin
    if (!HRESETn || ps == IDLE_S || ps == ADDR) begin
        beats_count <= 0;
    end else if (ps == DATA_W  || ps == DATA_R) begin
        beats_count <= beats_count + 1;
    end 

end


// next state
always @* begin
    case (ps)
        IDLE_S: ns = (start && HREADY)? ADDR : IDLE_S;
        ADDR: begin 
            if (HREADY) begin
                if (write) 
                    ns = DATA_W;
                else 
                    ns = DATA_R;
            end
            else begin
                if (HRESP) begin
                    ns = ERROR;
                end else begin
                    ns = WAIT;
                end
            end
        end 
        DATA_W: begin
            if (HREADY) begin
                if (write) 
                    ns = (((beats_count == beats_sel && burst != INCR) || ((burst == INCR) && transfer_count == beats_count))? IDLE_S : DATA_W);
                else 
                    ns = ADDR;
            end
            else begin
                if (HRESP) begin
                    ns = ERROR;
                end else begin
                    ns = WAIT;
                end
            end
        end 
        DATA_R: begin
            if (HREADY) begin
                if (!write) 
                    ns = (((beats_count == beats_sel && burst != INCR) || ((burst == INCR) && transfer_count == beats_count))? IDLE_S : DATA_R);

                else 
                    ns = ADDR;
            end
            else begin
                if (HRESP) begin
                    ns = ERROR;
                end else begin
                    ns = WAIT;
                end
            end
        end
        WAIT: begin 
            if (HREADY) begin
                if (write) 
                    ns = DATA_W;
                else 
                    ns = DATA_R;
            end
            else begin
                ns = WAIT;
            end
        end 
        ERROR: begin
            if (HREADY) begin
                if (write) 
                    ns = DATA_W;
                else 
                    ns = DATA_R;
            end
            else begin
                ns = ERROR;
            end
        end
        default: ns = IDLE_S;
    endcase
end

// write outputs
always @* begin
    case (ps)
        IDLE_S: begin
            HTRANS = HTRANS;
            HWDATA = HWDATA;
        end
        ADDR: begin
            HTRANS = NONSEQ;
            HWDATA = HWDATA;
        end
        DATA_W: begin
            HTRANS = SEQ;    
            HWDATA = (HREADY)? data_in : HWDATA;
        end
        DATA_R: begin
            HTRANS = SEQ;
            HWDATA = HWDATA;
        end
        WAIT: begin
            HTRANS = HTRANS;
            HWDATA = HWDATA;
        end
        ERROR: begin
            HTRANS = IDLE;
            HWDATA = HWDATA;
        end
        default: begin
            HTRANS = HTRANS;
            HWDATA = HWDATA;
        end
    endcase
end

// addr buffering
always @(posedge HCLK, negedge HRESETn) begin
    if (!HRESETn || ps == IDLE_S) begin
        addr_ptr <= 0;
        for (int i=0; i<16; ++i) begin
            read_addr_buffer[i] <= 0;
        end
    end
    else if (!write && (ps == DATA_R || ps == ADDR) ) begin
        addr_ptr <= addr_ptr + 1;
        read_addr_buffer [addr_ptr] <= HADDR;    
    end
end

always @(posedge HCLK, negedge HRESETn) begin
    if (!HRESETn) begin
        for (int i=0; i<1024; ++i) begin
            master_mem[i] <= 0;
        end
    end
    else if (ps == DATA_R) begin
        for (int i=0; i<addr_inc; ++i) begin
            master_mem[read_addr_buffer[addr_ptr - 1] + i] <= HRDATA[(8*i) +: 8];
        end
    end
end

endmodule
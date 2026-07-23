module AHB_master (HCLK, HRESETn, HRDATA, HREADY, HRESP, WDATA_S, ADDR_S, WRITE_S, BURST_S, ENABLE_S, HADDR,
                   HBURST, HMASTLOCK, HPROT, HSIZE, HTRANS, HWDATA, HWRITE);

    // address & data width
    parameter WIDTH = 32;

    // FSM states
    parameter IDLE = 2'b00;
    parameter NON_SEQ = 2'b01;
    parameter SEQ = 2'b10;

    // standard inputs
    input logic HREADY;
    input logic HRESP;
    input logic HRESETn;
    input logic HCLK;
    input logic [WIDTH - 1 : 0] HRDATA;

    // defined inputs to drive the master
    input logic [WIDTH - 1 : 0] ADDR_S;
    input logic WRITE_S;
    input logic [2 : 0] BURST_S;
    input logic ENABLE_S;
    input logic [WIDTH - 1 : 0] WDATA_S;

    // standard outputs
    output logic [WIDTH - 1 : 0] HADDR;
    output logic HWRITE;
    output logic [2 : 0] HSIZE;
    output logic [2 : 0] HBURST;
    output logic [3 : 0] HPROT;
    output logic [1 : 0] HTRANS;
    output logic HMASTLOCK;
    output logic [WIDTH - 1 : 0] HWDATA;


    // data FIFO connections
    logic valid_data;
    logic [WIDTH - 1 : 0] data_fifo_op;
    logic data_empty_flag;
    logic data_full_flag;
    
    // FSM state signals
    logic [1 : 0] cs, ns;

    // internal signals
    logic burst_done;
    logic start_s;
    logic [WIDTH - 1 : 0] ADDR_inc;
    logic [WIDTH - 1 : 0] WDATA_reg;
    logic transfer_done;
    logic transfer_done_reg;
    logic valid_data_reg1;
    logic valid_data_reg2;

    // data FIFO instantiation
    DATA_FIFO data_fifo (
        .clk(HCLK),
        .rst(HRESETn),
        .wr_en(valid_data),
        .wr_data(HRDATA),
        .rd_en(WRITE_S),
        .rd_data(data_fifo_op),
        .empty(data_empty_flag),
        .full(data_full_flag)
    );

    // next state logic
    always @ (*) begin
        case (cs)
            IDLE : begin
                if (start_s == 0) begin
                    ns = IDLE;
                end
                else begin
                    ns = NON_SEQ;
                end
            end

            NON_SEQ : begin
                if (transfer_done == 0) begin
                    ns = NON_SEQ;
                end
                else if (BURST_S == 0) begin
                    ns = IDLE;
                end
                else begin
                    ns = SEQ;
                end
            end

            SEQ : begin
                if (burst_done == 0) begin
                    ns = SEQ;
                end
                else begin
                    ns = IDLE;
                end
            end
        endcase
    end
    
    // state memory
    always @ (posedge HCLK) begin
        if (!HRESETn) begin
            cs <= IDLE;
        end
        else begin
            cs <= ns;
        end
    end

    // output logic
    always @ (posedge HCLK) begin
        if (!HRESETn) begin
            HADDR <= 32'b0;
            HWRITE <= 1'b1;
            HSIZE <= 3'b010;
            HBURST <= 3'b0;
            HPROT <= 4'b0;
            HTRANS <= 2'b00;
            HMASTLOCK = 1'b0;
            HWDATA <= 32'b0;
            WDATA_reg <= 32'b0;
            start_s <= 1'b0;
            ADDR_inc <= 32'b0;
            transfer_done <= 1'b0;
            transfer_done_reg <= 1'b0;
            valid_data <= 1'b0;
            valid_data_reg1 <= 1'b0;
            valid_data_reg2 <= 1'b0;
        end
        else begin
            case (cs)
                IDLE : begin
                    HADDR <= 32'b0;
                    HWRITE <= 1'b0;
                    HSIZE <= 3'b010;
                    HBURST <= 3'b0;
                    HPROT <= 4'b0;
                    HTRANS <= 2'b00;
                    HMASTLOCK <= 1'b0;
                    HWDATA <= 32'b0;
                    transfer_done <= 1'b0;
                    transfer_done_reg <= 1'b0;
                    start_s <= 1'b0;
                    valid_data <= 1'b0;
                    valid_data_reg1 <= 1'b0;
                    valid_data_reg2 <= 1'b0;

                    if (ENABLE_S) begin
                        start_s <= 1'b1;
                    end
                end

                NON_SEQ : begin
                    // address phase (first clock cycle)
                    HWRITE <= WRITE_S;
                    HADDR <= ADDR_S;
                    HSIZE <= 3'b010;
                    HBURST <= BURST_S;
                    HPROT <= 4'b0;
                    HTRANS <= 2'b10;
                    HMASTLOCK <= 1'b0;
                    ADDR_inc <= HADDR;
                    
                    // data phase (second clock cycle)
                    if (WRITE_S && HREADY) begin
                        WDATA_reg <= WDATA_S;
                        HWDATA <= WDATA_reg;
                        transfer_done_reg <= 1'b1;
                        transfer_done <= transfer_done_reg;
                    end
                    else if (WRITE_S == 0 && HREADY) begin
                        transfer_done_reg <= 1'b1;
                        transfer_done <= transfer_done_reg;
                        valid_data_reg1 <= 1'b1;
                        valid_data_reg2 <= valid_data_reg1;
                        valid_data <= valid_data_reg2;
                    end
                end

                SEQ : begin
                    HWRITE <= WRITE_S;
                    HSIZE <= 3'b010;
                    HBURST <= BURST_S;
                    HPROT <= 4'b0;
                    HTRANS <= 2'b11;
                    HMASTLOCK <= 1'b0;

                    if (WRITE_S && HREADY && (BURST_S == 3'b001)) begin
                        // address phase (first clock cycle)
                        ADDR_inc <= HADDR;
                        HADDR <= ADDR_inc + 32'h0004;

                        // data phase (second clock cycle)
                        WDATA_reg <= WDATA_S;
                        HWDATA <= WDATA_reg;
                    end
                    else if (WRITE_S == 0 && HREADY && (BURST_S == 3'b001)) begin
                        // address phase (first clock cycle)
                        ADDR_inc <= HADDR;
                        HADDR <= ADDR_inc + 32'h0004;
                        
                        // data phase (second clock cycle)
                        valid_data_reg1 <= 1'b1;
                        valid_data_reg2 <= valid_data_reg1;
                        valid_data <= valid_data_reg2;

                        if (valid_data) begin
                            valid_data <= 1'b0;
                        end
                    end
                end
            endcase
        end
    end
    
    //assign not_write_s = ~ WRITE_S;
    assign burst_done = (BURST_S) ? 1'b0 : 1'b1;
    
endmodule
    module spi_slave_interface #(parameter HEADER_SIZE =16, parameter DATA_WIDTH = 8)
    ( input SDI,
        input csb,

        input [DATA_WIDTH-1:0] rd_data,
        input sclk,rst_n,
        output  reg [HEADER_SIZE-2:0] addr,
        output  wire SDO,
        output  reg wn_en,
        output  reg [DATA_WIDTH-1:0] wr_data
    );

        logic [DATA_WIDTH-1:0] shift_Reg_SDO;
        logic mode;
        assign SDO = shift_Reg_SDO[DATA_WIDTH-1];
        logic [$clog2(HEADER_SIZE):0] counter=0;
        logic header_phase_end;

        logic end_of_data;
        logic addr_updated;
        assign header_phase_end = (counter == HEADER_SIZE - 2);
        assign end_of_data = (counter == DATA_WIDTH - 1);
    
    

        typedef enum  logic[1:0]
        { IDLE ,
        HEADER,
        READ, 
        WRITE
        } state_t;
        state_t current_state,next_state;
    //State_Register
        wire async_rst_n = rst_n & ~csb;  // active-low combined reset

    always_ff @(posedge sclk, negedge async_rst_n)
    begin
        if (!async_rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end
    //counter  
    always_ff @(posedge sclk, negedge async_rst_n)
    begin
        if (!async_rst_n)
            counter <= 0;
        else 
        begin
            case (current_state)
                HEADER: begin
                    if (header_phase_end)
                        counter <= 0;
                    else
                        counter <= counter + 1;
                end
                READ,
                WRITE: begin
                    if (end_of_data)
                        counter <= 0;
                    else
                        counter <= counter + 1;
                end
                default:
                    counter <= 0;
            endcase
        end
    end

    // sequential 
  logic end_of_data_d;  // delayed end_of_data flag

always_ff @(posedge sclk, negedge async_rst_n) begin 
    if (!async_rst_n) begin
        shift_Reg_SDO <= 0;
        wr_data       <= 0;
        wn_en         <= 0;
        mode          <= 0;
        addr          <= 0;
        end_of_data_d <= 0;
    end
    else begin
        end_of_data_d <= end_of_data;  // pipeline the flag by 1 cycle

        case (current_state)
            IDLE: begin
                wn_en <= 0;
                if(!csb)
                    mode <=SDI;
            end

            HEADER: begin
                
                   // if(!header_phase_end)
                    addr <= {addr[HEADER_SIZE-3:0], SDI};
            end

            READ: begin
                if (counter == 0)
                    shift_Reg_SDO <= rd_data;
                else
                    shift_Reg_SDO <= {shift_Reg_SDO[DATA_WIDTH-2:0], 1'b0};

                if (end_of_data_d && !csb)
                    addr <= addr + 1;
            end

            WRITE: begin
                wr_data <= {wr_data[DATA_WIDTH-2:0], SDI};

                if (end_of_data)
                    wn_en <= 1;
                else
                    wn_en <= 0;

                if (end_of_data_d && !csb)
                    addr <= addr + 1;
            end
        endcase   
    end     
end
    //next_state_logic_comb_out_logic
    always_comb begin
        next_state = current_state;
    
        case (current_state)
            IDLE: begin
                
                if (!csb)
                    next_state = HEADER;
            end

            HEADER: begin
                
                if (header_phase_end) begin
                    if (mode)
                        next_state = READ;
                    else begin
                        next_state = WRITE;
                    
                    end
                end
            end

            READ: begin
                
                if (csb)
                    next_state = IDLE;
            end

            WRITE: begin
            

                if (csb)
                    next_state = IDLE;
            end
        endcase
    end
    
    endmodule

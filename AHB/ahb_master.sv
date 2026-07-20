import ahb_pkg::*;
module ahb_master (
    input  logic         hclk,
    input  logic         hresetn,
    input  logic [31:0]  hrdata,
    input  logic [6:0]   i_beats_num,
    input  logic         hready,
    input  logic         hresp,

    output logic [31:0]  haddr,
    output trans_type    htrans,
    output logic         hwrite,
    output logic [2:0]   hsize,
    output logic [2:0]   hburst,
    output logic [31:0]  hwdata,
    output logic [3:0]   hprot,
    output logic         hmastlock,

    input  logic         req_valid,
    input  logic [31:0]  req_addr,
    input  logic         req_write,
    input  logic [31:0]  req_wdata,
    input  data_type     req_size,
    input  burst_type    req_burst,

    output logic [31:0]  req_rdata,
    output logic         req_done,
    output logic         req_error
);

    master_state current_state, next_state;   

    logic [6:0] beats_req;
    logic [6:0] beats_counter;
    logic [2:0] increment;
    logic       last_beat;
    logic       trans_fin;
    

    logic [31:0] addr_reg;
    data_type    size_reg;
    burst_type   burst_reg;
    logic [31:0] wdata_reg;    
    logic        write_reg;  

    assign last_beat = (beats_counter == beats_req - 1);
    assign trans_fin = last_beat && hready;
    

    always_comb begin: beats_req_proc
        case (burst_reg)
            INCR   : beats_req = i_beats_num;
            INCR4  : beats_req = 4;
            INCR8  : beats_req = 8;
            INCR16 : beats_req = 16;
            SINGLE : beats_req = 1;
            default: beats_req = 1;
        endcase
    end

    always_comb begin: used_increment_proc
        case (size_reg)
            BYTE     : increment = 1;
            HALFWORD : increment = 2;
            WORD     : increment = 4;
            default  : increment = 4;
        endcase
    end


    always_ff @(posedge hclk or negedge hresetn) begin: State_register 

        if (!hresetn) current_state <=IDLE_SYS ;
        else          current_state <= next_state;
    end



 
    always_ff  @(posedge hclk or negedge hresetn) begin:address_phase_proc
        if (!hresetn) begin
            addr_reg  <= '0;
            size_reg  <= WORD;
            burst_reg <= SINGLE;
            write_reg <=0;
           
        end
        else if (next_state == ADDR) begin
           
            addr_reg  <= req_addr;
            size_reg  <= req_size;
            write_reg <= req_write;
            burst_reg <= req_burst;
        end
        else if (current_state ==ADDR)
                wdata_reg <= req_wdata;
        else if (current_state ==WRITE && hready && !trans_fin) begin 
                addr_reg <=addr_reg+increment;
                wdata_reg <= req_wdata;
        end
        else if(current_state == READ && hready && !trans_fin) begin
                addr_reg <=addr_reg+increment;
               
        end
    end

 

    always_ff @(posedge hclk or negedge hresetn) begin :beat_count_proc
        if (!hresetn) begin
            beats_counter <= 0;
            req_done      <= 1'b0;
        end
        else begin
            req_done <= 1'b0;                      
            if (current_state == ADDR || current_state == IDLE_SYS) begin
                beats_counter <= 0;
            end
            else if(hready &&(current_state == READ || current_state == WRITE))
                    beats_counter <= beats_counter + 1;
            end
        end
       

  
    always_comb begin: state_transtion_output_proc
        req_rdata = hrdata;
        req_error = hresp;

        haddr  = addr_reg;
        next_state=current_state;
        hwdata = wdata_reg;
        hwrite = write_reg;
        hsize  = size_reg;
        hburst = burst_reg;

        case (current_state)
        IDLE_SYS: begin
        htrans=IDLE;        
            if(req_valid)
                next_state = ADDR;        
        end
        ADDR: begin
        htrans=NONSEQ;        
            if(hwrite)
                next_state = WRITE;
            else    
                next_state = READ;
        end
        WRITE:begin
        htrans=SEQ;        
            
            if (trans_fin && !req_valid)
                next_state = IDLE_SYS;    
            else if(trans_fin)
                next_state = ADDR;
            else
                next_state = READ;      

        end
            
            
        READ: begin
        htrans=NONSEQ;        

            if (trans_fin && !req_valid)
                next_state = IDLE_SYS;    
            else if(trans_fin)
                next_state = ADDR;
            else
                next_state = READ;            
        end
        endcase
    end

endmodule
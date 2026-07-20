`timescale 1ns/1ps
import ahb_pkg::*;
module ahb_master_tb;

logic hclk, hresetn;
logic [31:0] hrdata;
logic [6:0]  i_beats_num;
logic        hready, hresp;

logic [31:0] haddr;
trans_type   htrans;
logic        hwrite;
logic [2:0]  hsize;
logic [2:0]  hburst;
logic [31:0] hwdata;
logic [3:0]  hprot;       
logic        hmastlock;     

logic        req_valid;
logic [31:0] req_addr;
logic        req_write;
logic [31:0] req_wdata;
data_type    req_size;
burst_type   req_burst;
logic [31:0] rdata_reg;

int iterations;
int increment;
logic [31:0] req_rdata;
logic        req_done;
logic        req_error;

ahb_master dut (.*);
logic [7:0] mem [2**16-1:0];
logic [7:0] queue[$];
initial begin
    hclk = 0;
    forever #5 hclk = ~hclk;
end

task automatic issue_req(
    input logic [31:0] addr,
    input logic        write,
    input data_type    size,
    input burst_type   burst,
    input logic [6:0]  beats,
    input logic [31:0] wdata
);
    req_addr    = addr;
    req_write   = write;
    req_size    = size;
    req_burst   = burst;
    i_beats_num = beats;
    req_valid   = 1'b1;
    @(negedge hclk);
    req_wdata   = wdata;
    @(negedge hclk);


endtask
always_comb begin 
    
        case (req_burst)
            INCR   : iterations = i_beats_num;
            INCR4  : iterations = 4;
            INCR8  : iterations = 8;
            INCR16 : iterations = 16;
            SINGLE : iterations = 1;
            default: iterations = 1;
        endcase

end

task automatic capture_data(logic [2:0] hsize);
    int bytes;
    int j =0 ;
    
    bytes = 1 << hsize;
     req_valid = 1'b0;

    repeat(iterations) begin
    for (int i = 0; i < bytes; i++) begin
     
        mem[haddr[15:0] + i+bytes*j] = hwdata[8*i +: 8];
        $display(" [WRITE] Address=%h,Data=%h",haddr + i,hwdata[8*i +: 8]);
    end
    j++;    
        $display("");
    if(iterations!=1 && (j!=iterations))
        @(negedge hclk);    
    end
endtask
task automatic send_data();
    int bytes;
    int j;
    int base_addr=haddr;
     req_valid = 1'b0;


    bytes = 1 << hsize;
    hrdata = '0;
   repeat(iterations) begin
    for (int i = 0; i < bytes; i++) begin
     $display(" [READ] Address=%h,Data=%h",haddr + i,mem[base_addr + i]);

        hrdata[8*i +: 8] = mem[base_addr + i];
    end

    if(iterations!=1 && (j!=iterations))
    @(negedge hclk);    
   end
   


   
endtask   

initial begin
    hresetn     = 0;
    hrdata      = 32'h1234_5678;
    hready      = 1;
    hresp       = 0;
    req_valid   = 0;
    i_beats_num = 0;

    #20 hresetn = 1;
    @(negedge hclk);

    // TC1: Single word write, basic NONSEQ transfer with no wait states
    issue_req(32'h0000_0000, 1'b1, WORD, SINGLE, 1, 32'hDEAD_BEEF);
    capture_data(hsize);
    

    // TC2: Single word write immediately following TC1, back-to-back NONSEQ transfers
    issue_req(32'h0000_0004, 1'b1, WORD, SINGLE, 1, 32'hCAFE_BABE);
    capture_data(hsize);

    // TC3: Single halfword write, checks HSIZE=halfword 
    issue_req(32'h0000_0008, 1'b1, HALFWORD, SINGLE, 1, 32'h55AA_55AA);
    capture_data(hsize);

    req_valid = 1'b0;

    // TC4: 4-beat incrementing burst (INCR4), verifies fixed-length burst must complete with SEQ transfers
    issue_req(32'h0000_0010, 1'b1, WORD, INCR4, 4, 32'hA1A1_A1A1);
    capture_data(hsize);
    req_valid = 1'b0;
   

   
    // TC5: Back to Back incrementing read after write
    issue_req(32'h0000_0080, 1'b1, WORD, INCR4, 4, 32'h2F2F_2F2F);
    capture_data(hsize);
    req_valid = 1'b0;

    issue_req(32'h0000_0080, 1'b0, WORD, INCR4, 4, 32'hAFFF_ABC1);    send_data();    req_valid = 1'b0;




   
  

    // TC6: INCR4 byte write with Subordinate-inserted wait states (HREADY low), checks HTRANS held constant while waited

    issue_req(32'h0000_0020, 1'b1,BYTE, SINGLE, 1, 32'hFEED_FACE);
    hready = 1'b0;
    req_valid = 1;
    capture_data(hsize);
    repeat(3) @(negedge hclk);


    hready = 1'b1;
    
    
   

    // TC7: 7-beat incrementing burst (INCR) of halfwords of undefined length, verifies burst length and address increments by transfer size
    @(negedge hclk);
    issue_req(32'h0000_0040, 1'b1, BYTE, INCR, 8, 32'h1234_5678);
    capture_data(hsize);
    req_valid = 1'b0;
    repeat(7)@(negedge hclk);
    $stop;




end

endmodule
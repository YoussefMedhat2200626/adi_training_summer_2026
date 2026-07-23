module AHB_master (Hclk, HRESTn, start, stall, burst, size_in, Hresp, Hready, HRdata, datawrite, wrtrd_sel, addr, Haddr, Hwrite, Hsize, Hburst, Htrans, Hwdata, Hprot, Hmastlock);
 parameter [1:0] IDLE = 2'b00;
 parameter [1:0] BUSY = 2'b01;
 parameter [1:0] NONSEQ = 2'b10;
 parameter [1:0] SEQ = 2'b11;
 input Hclk, HRESTn, start, stall, burst, Hready, Hresp;
 input [31:0] HRdata; 
 input [1:0] size_in;
 input [31:0] datawrite;
 input wrtrd_sel;
 input [31:0] addr;
 output reg [31:0]  Haddr;
 output reg Hwrite; 
 output reg [2:0] Hsize; 
 output reg [2:0] Hburst;
 output reg [1:0] Htrans;
 output reg [31:0] Hwdata; 
 output [3:0] Hprot;
 output Hmastlock; 
 reg [1:0] cs, ns; 
 wire [31:0] addr_add;

 always @ (*) begin 
   case (cs)
     IDLE: begin
       if ((start && Hready) == 1)
         ns = NONSEQ; 
       else 
         ns = IDLE;
     end

     NONSEQ: begin
       if (Hready == 1) begin
         if (Hresp == 1)
           ns = IDLE;
         else if (burst == 1) begin
           if (stall == 1)
             ns = BUSY;
           else
             ns = SEQ;
         end else if (start == 0)
           ns = IDLE;
         else
           ns = NONSEQ;
       end else
         ns = NONSEQ;
     end

     SEQ: begin
       if (Hready == 1) begin
         if (Hresp == 1)
           ns = IDLE;
         else if (burst == 1) begin
           if (stall == 1)
             ns = BUSY;
           else
             ns = SEQ;
         end else if (start == 0)
           ns = IDLE;
         else
           ns = NONSEQ;
       end else
         ns = SEQ;
     end

     BUSY: begin
       if (Hready == 1) begin
         if (burst == 1) begin
           if (stall == 0)
             ns = SEQ;
           else
             ns = BUSY;
         end else if (start == 0)
           ns = IDLE;
         else
           ns = NONSEQ;
       end else
         ns = BUSY;
     end
    endcase 
 end 

 always @ (posedge Hclk or negedge HRESTn) begin 
   if (~HRESTn)
     cs <= IDLE; 
   else 
     cs <= ns;
 end 

 assign Hprot = 4'b0011;                           
 assign Hmastlock = 1'b0;
 assign addr_add = (size_in == 2'b00) ? 32'd1 : (size_in == 2'b01) ? 32'd2 : 32'd4; 

 always @ (posedge Hclk or negedge HRESTn) begin 
  if (!HRESTn) begin
        Haddr  <= 32'b0;
        Hwrite <= 0;
        Hsize  <= 3'b0; 
        Hburst <= 3'b000;
        Htrans <= IDLE;
        Hwdata <= 32'b0;   
    end else begin
        Hsize  <= {1'b0, size_in};
        case (Htrans)
          IDLE: begin 
            if (start == 1 && Hready == 1) begin 
              Htrans <= NONSEQ;
              Haddr  <= addr;
              Hburst <= burst ? 3'b001 : 3'b000;
              Hwdata <= datawrite;
              Hwrite <= wrtrd_sel;
            end else 
              Htrans <= IDLE;
          end 

          NONSEQ: begin 
            if (Hready == 1) begin
              if (Hresp == 1)
                Htrans <= IDLE;
              else if (burst == 1) begin
                Haddr  <= Haddr + addr_add;
                Hburst <= 3'b001;
                Hwdata <= datawrite;
                Hwrite <= wrtrd_sel;
                if (stall == 1)
                  Htrans <= BUSY; 
                else 
                  Htrans <= SEQ;
              end else if (start == 0)
                Htrans <= IDLE;
              else begin
                Haddr  <= addr;
                Htrans <= NONSEQ;
                Hburst <= burst ? 3'b001 : 3'b000;
                Hwdata <= datawrite;
                Hwrite <= wrtrd_sel;
              end 
            end else
              Htrans <= NONSEQ;
          end   

          SEQ: begin 
            if (Hready == 1) begin
              if (Hresp == 1)
                Htrans <= IDLE;
              else if (burst == 1) begin
                Haddr  <= Haddr + addr_add;
                Hburst <= 3'b001;
                Hwdata <= datawrite;
                Hwrite <= wrtrd_sel;
                if (stall == 1)
                  Htrans <= BUSY;
                else
                  Htrans <= SEQ;    
              end else if (start == 0)
                Htrans <= IDLE;   
              else begin
                Haddr  <= addr;
                Htrans <= NONSEQ;
                Hburst <= burst ? 3'b001 : 3'b000;
                Hwdata <= datawrite;
                Hwrite <= wrtrd_sel;
              end 
            end else
              Htrans <= SEQ;
          end 
           
          BUSY: begin 
            if (Hready == 1) begin
              if (burst == 1) begin
               // Haddr <= Haddr + addr_add;
                if (stall == 0) begin
                  Htrans <= SEQ; 
                  Hburst <= 3'b001;
                  Hwdata <= datawrite;
                  Hwrite <= wrtrd_sel;
                end else begin
                  Htrans <= BUSY;
                end
              end else if (start == 0) begin
                Haddr  <= addr;
                Htrans <= IDLE;
              end else begin
                Haddr  <= addr;
                Htrans <= NONSEQ; 
                Hburst <= burst ? 3'b001 : 3'b000;
                Hwdata <= datawrite;
                Hwrite <= wrtrd_sel;
              end 
            end else begin
              Htrans <= BUSY;
            end 
          end 
        endcase 
    end 
 end 
endmodule
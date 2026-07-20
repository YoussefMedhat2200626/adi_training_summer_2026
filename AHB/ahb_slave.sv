// import ahb_pkg::*;
// module ahb_slave #(
//     parameter ADDR_WIDTH = 32,
//     parameter DATA_WIDTH = 32,
//     parameter MEM_DEPTH  = 1024,
//     parameter WAIT_STATES = 0 
// )(

//     input  logic                     HCLK,
//     input  logic                     HRESETn,

  
//     input  logic                     HSEL,
//     input  logic [ADDR_WIDTH-1:0]    HADDR,
//     input  logic [1:0]               HTRANS,
//     input  logic                     HWRITE,
//     input  logic [2:0]               HSIZE,
//     input  logic [2:0]               HBURST,
//     input  logic [3:0]               HPROT,
//     input  logic                     HMASTLOCK,
//     input  logic                     HREADY,


//     input  logic [DATA_WIDTH-1:0]    HWDATA,


//     output logic [DATA_WIDTH-1:0]    HRDATA,
//     output logic                     HREADYOUT,
//     output logic                     HRESP
// );


//     logic [7:0] mem [0:MEM_DEPTH-1];


//     logic [ADDR_WIDTH-1:0] addr_reg;
//     logic [2:0]            size_reg;
//     logic                  write_reg;


//     assign HREADYOUT = 1'b1;   // Always ready
//     assign HRESP     = 1'b0;   // Always OKAY

 
//     always_ff @(posedge HCLK or negedge HRESETn) begin
//         if (!HRESETn) begin
//             addr_reg  <= '0;
//             size_reg  <= '0;
//             write_reg <= 1'b0;
//         end
//         else if (HSEL && HREADY && HTRANS ) begin
//             addr_reg  <= HADDR;
//             size_reg  <= HSIZE;
//             write_reg <= HWRITE;
//         end
//     end

//     always_ff @(posedge HCLK) begin
//         if (HSEL && HREADY && write_reg) begin
//             case (size_reg)

   
//                 3'b000:
//                     mem[addr_reg] <= HWDATA[7:0];

//                 // Halfword
//                 3'b001: begin
//                     mem[addr_reg]     <= HWDATA[7:0];
//                     mem[addr_reg + 1] <= HWDATA[15:8];
//                 end

//                 // Word
//                 3'b010: begin
//                     mem[addr_reg]     <= HWDATA[7:0];
//                     mem[addr_reg + 1] <= HWDATA[15:8];
//                     mem[addr_reg + 2] <= HWDATA[23:16];
//                     mem[addr_reg + 3] <= HWDATA[31:24];
//                 end

//                 default: ;
//             endcase
//         end
//     end


//     always_comb begin
//         HRDATA = 32'h00000000;

//         if (HSEL && HREADY && !HWRITE && ()) begin

//             case (HSIZE)

//                 // Byte
//                 3'b000:
//                     HRDATA[7:0] = mem[HADDR];

//                 // Halfword
//                 3'b001: begin
//                     HRDATA[7:0]  = mem[HADDR];
//                     HRDATA[15:8] = mem[HADDR + 1];
//                 end

//                 // Word
//                 3'b010: begin
//                     HRDATA[7:0]   = mem[HADDR];
//                     HRDATA[15:8]  = mem[HADDR + 1];
//                     HRDATA[23:16] = mem[HADDR + 2];
//                     HRDATA[31:24] = mem[HADDR + 3];
//                 end

//                 default: ;
//             endcase
//         end
//     end

// endmodule
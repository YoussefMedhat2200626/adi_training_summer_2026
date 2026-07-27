module spi_slave #(
parameter DATA_WIDTH = 8,
parameter ADDR_WIDTH = 15 
 )(
input rst_n,
//with master
input SCLK,CSB,SDI,
output reg SDO,
//with memory
input [DATA_WIDTH-1:0] rd_data,
output reg wr_en,
output reg [DATA_WIDTH-1:0] wr_data,
output reg [ADDR_WIDTH-1:0] addr
);

//assuming CPOL (clock polarity) = 0 and CPHA (clock phase) = 0, 
//so the data is sampled at the rising edge of the clock 
//and the data is shifted out at the falling edge of the clock

typedef enum logic {
HEADER= 1'b0,
DATA= 1'b1
} states;

states current_state,next_state;


reg [$clog2(DATA_WIDTH):0] data_bit_counter; // data bit count
reg [$clog2(ADDR_WIDTH)+1:0] header_bit_counter; //wr+address count
reg [DATA_WIDTH-1:0] data_reg;
reg [ADDR_WIDTH:0] header_reg;

//state reg
always @(posedge SCLK or negedge CSB or negedge rst_n or posedge CSB) begin
  if ((rst_n ==0)|(CSB==1'b1)) begin //when the slave is not selected
    current_state= HEADER;
    header_bit_counter= 0;
    data_bit_counter  = 0;
    wr_en = 0;
    SDO=1'bz;
    next_state = HEADER;
  end else begin
    current_state = next_state;
  end
end

//next state logic (sampling on positive edge)
always @(posedge SCLK) begin
  if (CSB==0)begin //if slave is selected
  case (current_state)
    HEADER:begin //start receiving the header
        SDO=1'bz;
        header_reg={header_reg[ADDR_WIDTH-1:0],SDI};//shift in the header bits from sdi
        header_bit_counter=header_bit_counter+1;//increse the counter
        next_state <= HEADER;//repeat
        if (header_bit_counter == (ADDR_WIDTH+1))begin //when the counter reaches all the bits  
        addr=header_reg[ADDR_WIDTH-1:0];//pass adderess to mem
        next_state <= DATA;//go to data state
        end
    end
    DATA:begin
      if (header_reg[ADDR_WIDTH]==1'b0) begin //master write
      wr_en=1'b0;//deafalt value for wr_en
        begin
         data_reg= {data_reg[DATA_WIDTH-1:0],SDI};//shift the data in from sdi
         data_bit_counter <= data_bit_counter+1;//increase the counter
         next_state <= DATA;//repeat
        if (data_bit_counter == (DATA_WIDTH-1)) begin //if a whole byte is shifted in
        wr_en=1'b1;//write enable to mem
        wr_data=data_reg;//write data 
        data_bit_counter <= 0;//reset the counter
        //increase the address by 1(for each byte) in case of bursts 
        header_reg[ADDR_WIDTH-1:0]<=header_reg[ADDR_WIDTH-1:0]+(DATA_WIDTH/8);
        addr<= header_reg[ADDR_WIDTH-1:0];//pass the new address to mem
        next_state <= DATA;//repeat
        end
        end
      end else begin //master read (the data should change on negative edge)
      wr_en=1'b0;//read signal for mem
        if (data_bit_counter == (DATA_WIDTH)) begin//if all the data is shifted out
        data_bit_counter <= 0;//reset the counter
         //increase the address by 1(for each byte) in case of bursts
        header_reg[ADDR_WIDTH-1:0]<=header_reg[ADDR_WIDTH-1:0]+(DATA_WIDTH/8);
        addr<=header_reg[ADDR_WIDTH-1:0]+(DATA_WIDTH/8);//pass the new address to mem
        next_state <= DATA;//repeat
        end else begin
        next_state <= DATA;
        end
      end
  end
default: next_state = HEADER;
endcase
end
else begin //if not selected
data_bit_counter <= 0;
next_state <= HEADER;
SDO=1'bz;
end
end
//next state logic (driving sdo on negative edge)
always@(negedge SCLK)begin
  if((next_state==DATA)&(header_reg[ADDR_WIDTH]==1'b1)&(CSB==0))begin
  SDO <= rd_data[DATA_WIDTH-data_bit_counter-1];
  data_bit_counter <= data_bit_counter+1;
  end 
end
endmodule
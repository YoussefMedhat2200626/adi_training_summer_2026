module ALU (
	input wire	[7:0]   A 			,
	input wire	[7:0]   B 			,
	input wire  [2:0]	opcode		,
	output reg			carryout 	,
	output wire			zero_flag 	,
	output reg	[7:0]	Result 		
	);
	

	always @(*) begin
		carryout = 1'b0;
		case (opcode) 
			3'b000	: Result 			= A 	;
			3'b001	: {carryout,Result} = A+B 	;
			3'b010	: {carryout,Result} = A-B 	;
			3'b011	: Result 			= A+1 	;
			3'b100	: Result 			= A-1 	;
			3'b101	: Result 			= A&B 	;
			3'b110	: Result 			= A|B 	;
			3'b111	: Result 			= ~A 	;
			default	: Result 			= A		;
		endcase
	end


	assign zero_flag = (Result==0)? 1'b1 : 1'b0 ;



endmodule
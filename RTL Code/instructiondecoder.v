module instructiondecoder (
	input  [6:0] op,
	output reg [2:0] ImmSrc);

	always @(*) begin
	case(op)
		7'b0110011: 	ImmSrc = 3'bxxx; // R-type
		7'b0010011: 	ImmSrc = 3'b000; // I-type ALU
		7'b0000011: 	ImmSrc = 3'b000; // lw / lbu
		7'b0100011: 	ImmSrc = 3'b001; // sw / sb
		7'b1100011: 	ImmSrc = 3'b010; // branches
		7'b1101111: 	ImmSrc = 3'b011; // jal
		7'b0110111: 	ImmSrc = 3'b100; // lui
		7'b1100111: 	ImmSrc = 3'b000; // jalr
		7'b0010111: 	ImmSrc = 3'b100; // auipc
		default: 	ImmSrc = 3'bxxx; // ???
	endcase
	end
endmodule

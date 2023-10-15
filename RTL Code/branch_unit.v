module branch_unit (
	input  Branch,
	input   [3:0] Flags,
	input   [2:0] funct3,
	output   taken);

	wire v, c, n, z; // Flags: overflow, carry out, negative, zero
	reg cond; // cond is 1 when condition for branch met

	assign {v, c, n, z} = Flags;
	assign taken = cond & Branch;

	always @(*) begin 
		case (funct3)
			3'b000: cond = z; // beq
			3'b001: cond = ~z; // bne
			3'b100: cond = (n ^ v); // blt
			3'b101: cond = ~(n ^ v); // bge
			3'b110: cond = ~c; // bltu
			3'b111: cond = c; // bgeu
			default: cond = 1'b0;
		endcase
	end 
endmodule

module zeroextend(	input  [7:0] a,	output  [31:0] zeroimmext);	assign zeroimmext = {24'b0, a};endmodule
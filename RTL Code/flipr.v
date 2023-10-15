module flipr #(parameter WIDTH = 8)(
			input  clk, rst_n,
			input  [WIDTH-1:0] d,
			output reg [WIDTH-1:0] q);

			always @(posedge clk, negedge rst_n) begin 
				if (!rst_n) 
					q <= 0;
				else
					q <= d;
			end 

endmodule

module registerfile(
    input clk,
    input rst_n, 
    input we3,
    input [4:0] a1, a2, a3,
    input [31:0] wd3,
    output [31:0] rd1, rd2);
 
    reg [31:0] rf[31:0];
    
    integer i; 
    always  @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin
            for(i = 0; i< 32; i = i +1) begin
                rf[i] <= 32'b0; 
            end
        end      
        if (we3) 
            rf[a3] <= wd3;
    end     
    assign rd1 = (a1 != 0) ? rf[a1] : 0;
    assign rd2 = (a2 != 0) ? rf[a2] : 0;
endmodule



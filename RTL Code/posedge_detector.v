module posedge_detect(
    input clk,
    input reset_n,
    input sclk, 
    output  is_posedge
    ); 

    reg Q; 
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) 
            Q <= 1'b0; 
        else 
            Q <= sclk; 
    end 

    assign is_posedge = ~Q & sclk; 
endmodule 
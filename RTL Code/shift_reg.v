module shift_reg #(parameter BIT_LENGTH = 32)(
    input clk, 
    input reset_n, 
    input shift_en,
    input load_en,  
    input serial_in, 
    input [BIT_LENGTH-1:0] parralel_in, 
    
    output reg [BIT_LENGTH-1:0] Q
);

    always @(posedge clk or negedge reset_n) begin

        if(!reset_n)
            Q <= 'b0; 
        else 
            Q <= load_en? parralel_in: (shift_en? {serial_in, Q[BIT_LENGTH-1 : 1]}: Q); 
    end

endmodule 

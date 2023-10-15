module cmprtr #(parameter BIT_LENGTH = 6) (
    input [BIT_LENGTH-1:0] value1, 
    input [BIT_LENGTH-1:0] value2, 
    output is_equal
); 

    assign is_equal = (value1 == value2);
endmodule

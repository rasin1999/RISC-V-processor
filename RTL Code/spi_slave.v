module spi_slave#(parameter BIT_LENGTH = 32, parameter COUNT_LENGTH = 6)(
    input clk, reset_n, 
    input ss, sclk, mosi,
	input serial_in, 
	
	output shift_en,     
    output miso, 
    output transaction_done, 
	output serial_out
); 
  
    wire [COUNT_LENGTH-1:0] count; 
	

    posedge_detect POSEDGE_DETECTOR(
        .clk(clk), 
        .reset_n(reset_n), 
        .sclk(sclk), 

        .is_posedge(is_posedge)
    ); 

    counter BIT_COUNTER(
        .clk(clk), 
        .reset_n(reset_n), 
        .clear(clear), 
        .increament(increament), 

        .count(count)
    ); 

    cmprtr #(4) COMPARE(
        .value1(count), 
        .value2(4'b1000), 

        .is_equal(bit_count_eq_8)
    ); 


    spi_fsm SPI_CONTROLLER(
        .clk(clk), 
        .reset_n(reset_n),
        .sclk_posedge(is_posedge), 
        .ss(ss),
        .bit_count_eq_8(bit_count_eq_8),  
        .shift_en(shift_en),
        .clear(clear), 
        .increament(increament),
        .transaction_done(transaction_done)
    );

    assign miso = serial_in; 
	assign serial_out = mosi; 
endmodule

module interface_top #(parameter DATA_LENGTH = 32, parameter ADDRESS_LENGTH = 32)(
    input clk, 
    input reset_n, 
    input ss, sclk, mosi, 
    input [DATA_LENGTH-1:0] ram_data_out,

    output miso,
    output mem_en, mem_rd_en, mem_wr_en,
    output [ADDRESS_LENGTH-1:0] address, data_reg_out
); 


	wire spi_serial_out; 
    wire [DATA_LENGTH-1:0] spi_reg_out, addr_reg_out;
    wire data_reg_serial_in, addr_reg_serial_in; 
    wire data_reg_shift_en, addr_reg_shift_en; 
    wire transaction_done; 
    wire tr_clear, tr_increament; 
    wire [2:0] tr_count; 
    wire data_reg_write; 
    wire read_data; 


    spi_slave SPI_SLAVE(
        .clk(clk), 
        .reset_n(reset_n), 
        .ss(ss), 
        .sclk(sclk), 
        .mosi(mosi),
 	    .serial_in(data_reg_out[0]),

        .miso(miso),
	    .shift_en(shift_en), 
        .transaction_done(transaction_done),
	    .serial_out(spi_serial_out)
    ); 


    shift_reg #(32) ADDR_REG(
        .clk(clk), 
        .reset_n(reset_n), 
        .shift_en(addr_reg_shift_en), 
        .load_en(1'b0), 
      	.serial_in(addr_reg_serial_in), 
        .parralel_in(1'b0), 

        .Q(addr_reg_out)
    ); 

    shift_reg #(32) DATA_REG(
        .clk(clk), 
        .reset_n(reset_n), 
        .shift_en(data_reg_shift_en), 
        .load_en(read_data), 
      	.serial_in(data_reg_serial_in), 
        .parralel_in(ram_data_out), 

        .Q(data_reg_out)
    );    
    
	cmprtr #(3) COMPARE_TR(
	.value1(tr_count), 
	.value2(3'b100), 

	.is_equal(tr_count_eq_4)
	); 
	
    counter #(3) TR_COUNTER(
    .clk(clk), 
    .reset_n(reset_n), 
    .clear(tr_clear), 
    .increament(tr_increament), 

    .count(tr_count)
	); 

    mem_controller MEM_CONTROLLER(
        .clk(clk), 
        .reset_n(reset_n), 
        .tr_done_4(tr_count_eq_4), 
        .read_write(read_write),
        .shift_en(shift_en),
        .transaction_done(transaction_done), 
	
		.data_reg_write(data_reg_write), 
        .mem_en(mem_en), 
        .mem_wr_en(mem_wr_en), 
        .mem_rd_en(mem_rd_en), 
        .data_reg_shift_en(data_reg_shift_en), 
        .addr_reg_shift_en(addr_reg_shift_en), 
        .tr_clear(tr_clear), 
        .tr_increament(tr_increament),
        .read_data(read_data)
    ); 
    	
	assign {data_reg_serial_in, addr_reg_serial_in}= data_reg_write ? {spi_serial_out, 1'b0}: {1'b0, spi_serial_out}; 
	assign read_write = addr_reg_out[0]; 
    assign address = {1'b0, addr_reg_out[31:1]}; 

    endmodule

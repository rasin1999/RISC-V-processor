module ultimate_top #(parameter DATA_LENGTH = 32, ADDRESS_LENGTH = 32)(
	input clk, rst_n, core_select, 
	input ss, sclk, mosi, miso); 
	
	
	wire from_core_mem_en, from_core_mem_wr_en, from_core_mem_rd_en;
	wire [ADDRESS_LENGTH-1:0] from_core_mem_address;
	wire [DATA_LENGTH-1:0] from_core_mem_data_in;
	wire [1:0] from_core_mem_data_length;
	wire [DATA_LENGTH-1:0] to_core_mem_data_out;
	
	wire from_intf_mem_ctrl_mem_en, from_intf_mem_ctrl_mem_wr_en, from_intf_mem_ctrl_mem_rd_en;
	wire [ADDRESS_LENGTH-1:0] from_intf_mem_ctrl_mem_address;
	wire [DATA_LENGTH-1:0] from_intf_mem_ctrl_mem_data_in;
	wire [1:0] from_intf_mem_ctrl_mem_data_length;
	wire [DATA_LENGTH-1:0] to_intf_mem_ctrl_mem_data_out;
	
	wire core_clk, intf_clk; 
	assign core_clk = clk & core_select; 
	assign intf_clk = clk & ~core_select; 
	
	
	// instantiate processor and memories
	riscmulticycle U_RISCV(
		.clk(core_clk), 
		.rst_n(rst_n), 
		.core_select(core_select), 
		.ReadData(to_core_mem_data_out),
		
		.MemWrite(from_core_mem_wr_en), 
		.Adr(from_core_mem_address), 
		.WriteData(from_core_mem_data_in),
 		.Mem_Data_length(from_core_mem_data_length), 
 		.MemRead(from_core_mem_rd_en), 
 		.MemEn(from_core_mem_en)
 	);
 		
 	data_memory_wrapper U_MEM_WRAPPER(
 	        .clk(clk), 
 	        .core_select(core_select), 
 	        .from_core_mem_en(from_core_mem_en), 
 	        .from_core_mem_wr_en(from_core_mem_wr_en), 
 	        .from_core_mem_rd_en(from_core_mem_rd_en), 
 	        .from_core_mem_address(from_core_mem_address), 
 	        .from_core_mem_data_in(from_core_mem_data_in), 
 	        .from_core_mem_data_length(from_core_mem_data_length), 
 	        
 	        //to core output 
 	        .to_core_mem_data_out(to_core_mem_data_out), 
 	        
 	        .from_intf_mem_ctrl_mem_en(from_intf_mem_ctrl_mem_en), 
 	        .from_intf_mem_ctrl_mem_wr_en(from_intf_mem_ctrl_mem_wr_en), 
 	        .from_intf_mem_ctrl_mem_rd_en(from_intf_mem_ctrl_mem_rd_en),
 	        .from_intf_mem_ctrl_mem_address(from_intf_mem_ctrl_mem_address), 
 	        .from_intf_mem_ctrl_mem_data_in(from_intf_mem_ctrl_mem_data_in),
	        .from_intf_mem_ctrl_mem_data_length(2'b11), 
	        
	        //to intf output   
	        .to_intf_mem_ctrl_mem_data_out(to_intf_mem_ctrl_mem_data_out));
	        
	 interface_top U_INTERFACE(
	        .clk(intf_clk), 
	        .reset_n(rst_n), 
	        .ss(ss),
	        .sclk(sclk), 
	        .mosi(mosi), 
	        .ram_data_out(to_intf_mem_ctrl_mem_data_out),
	        
	        .miso(miso),
	        .mem_en(from_intf_mem_ctrl_mem_en), 
	        .mem_rd_en(from_intf_mem_ctrl_mem_rd_en), 
	        .mem_wr_en(from_intf_mem_ctrl_mem_wr_en), 
	        .address(from_intf_mem_ctrl_mem_address),
	        .data_reg_out(from_intf_mem_ctrl_mem_data_in)); 
	        
endmodule 
	        
	  
 		

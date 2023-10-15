module mem_controller(
    input clk, 
    input reset_n, 
    input tr_done_4,
    input read_write,
    input shift_en, 
    input transaction_done,
	
    output reg data_reg_write, 
    output reg mem_en,
    output reg mem_wr_en, 
    output reg mem_rd_en,  
    output reg data_reg_shift_en, 
    output reg addr_reg_shift_en, 
    output reg tr_clear, 
    output reg tr_increament, 
    output reg read_data
); 

    reg [2:0] present_state, next_state; 
    parameter ADDR_LOAD    	= 3'b000;
    parameter DATA_LOAD    	= 3'B001; 
    parameter MEM_WRITE    	= 3'b010;  
    parameter MEM_READ     	= 3'b100;
    parameter MEM_READ_BUFF 	= 3'b110; 
    

    always @(*) begin
        begin: NSL
            case(present_state)
                ADDR_LOAD   : next_state = tr_done_4 ? ( read_write ? DATA_LOAD: MEM_READ) : ADDR_LOAD;
                DATA_LOAD       : next_state = tr_done_4 ? MEM_WRITE : DATA_LOAD; 
                MEM_WRITE       : next_state = ADDR_LOAD; 
                MEM_READ        : next_state = MEM_READ_BUFF; 
                MEM_READ_BUFF	: next_state = ADDR_LOAD; 
            endcase 
        end 

        begin: OL
            case(present_state)
                ADDR_LOAD  : begin
                                    mem_en          	= 0;
                                    mem_rd_en       	= 0; 
                                    mem_wr_en       	= 0;  
                                    data_reg_shift_en	= 0;
                                    addr_reg_shift_en	= shift_en;  
                                    tr_clear		= tr_done_4; 
                                    tr_increament 	= transaction_done; 
                                    data_reg_write	= 0; 
                                    read_data		= 0;  
                                end

                DATA_LOAD   : begin
                                    mem_en          	= 0;
                                    mem_rd_en       	= 0; 
                                    mem_wr_en       	= 0;  
                                    data_reg_shift_en	= shift_en;
                                    addr_reg_shift_en	= 0;   
                                    tr_clear		= tr_done_4; 
                                    tr_increament 	= transaction_done; 
                                    data_reg_write	= 1;  
                 	      	    read_data		= 0;      
                                end

                MEM_WRITE       : begin 
                                    mem_en          	= 1;
                                    mem_rd_en       	= 0; 
                                    mem_wr_en       	= 1;   
                                    data_reg_shift_en	= 0;
                                    addr_reg_shift_en	= 0;  
                            	    tr_clear		= 1; 
                                    tr_increament 	= 0; 
                                    data_reg_write	= 0;    
                	            read_data		= 0;    
                                end 

                MEM_READ       : begin
                                    mem_en          	= 1;
                                    mem_rd_en       	= ~read_write; 
                                    mem_wr_en       	= 0; 
                                    data_reg_shift_en	= 0;
                                    addr_reg_shift_en	= 0;  
                            	    tr_clear		= 1; 
                                    tr_increament 	= 0; 
                                    data_reg_write	= 0;   
                                    read_data		= ~read_write;  
                                     
                                end 
                                
                MEM_READ_BUFF       : begin
                                    mem_en          = 1;
                                    mem_rd_en       = 1; 
                                    mem_wr_en       = 0;  
                                end 
               endcase
        end 
    end 

    always @(posedge clk or negedge reset_n) begin
        if(!reset_n)
            present_state <= ADDR_LOAD; 
        else
            present_state <= next_state; 
    end 
    


endmodule  

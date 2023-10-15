module spi_fsm(
    input clk, 
    input reset_n,  
    input sclk_posedge, 
  	input bit_count_eq_8,
    input ss, 

    output reg shift_en, 
    output reg clear, 
    output reg increament,
    output reg transaction_done
);

    reg [1:0] present_state, next_state; 
    parameter IDLE = 2'b00; 
    parameter TRANSFER = 2'b01; 
    parameter FINISH = 2'b10; 
    parameter WAIT_SS_HIGH = 2'b11; 

    always @(*) begin
        begin: NSL
         case(present_state)
            IDLE: next_state = !ss? TRANSFER: IDLE;
            TRANSFER: next_state = !ss? (bit_count_eq_8? FINISH: TRANSFER) : IDLE; 
            FINISH: next_state = !ss? WAIT_SS_HIGH : IDLE;  
            WAIT_SS_HIGH: next_state = !ss? WAIT_SS_HIGH: IDLE; 
         endcase 
        end 

        begin: OL
        case(present_state) 
            IDLE: begin
                clear = 1; 
                increament = 0; 
                shift_en = 0; 
                transaction_done = 0; 
            end
            TRANSFER: begin
                clear = 0; 
                increament = sclk_posedge; 
                shift_en = sclk_posedge; 
                transaction_done = 0;
            end
            FINISH: begin             
                clear = 1; 
                increament = 0; 
                shift_en = 0; 
                transaction_done = 1;
            end
            WAIT_SS_HIGH: begin
                clear = 1; 
                increament = 0; 
                shift_en = 0; 
                transaction_done = 0;
            end
        endcase 
        end 
    end 

    always @(posedge clk or negedge reset_n) begin 
        if(!reset_n) 
            present_state <= IDLE; 
        else 
            present_state <= next_state; 
    end
  
endmodule 

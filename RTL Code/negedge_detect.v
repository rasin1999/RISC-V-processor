module StartDetectionUnit (
    input clk, state, signal_in,
    output trigger
    );   

    reg signal_d;

    always @(posedge clk)
        begin
            signal_d <= !signal_in;
        end
    assign trigger = !(signal_in | signal_d);
endmodule    

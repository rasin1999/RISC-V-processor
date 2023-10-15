# setting up time units

set_units -time 1ns -capacitance pF

# setting the clock period 10ns, as period = 1/freq, here, freq = 100MHz
set clock_period 10; 

set top_module "alu"

set clock_port {clk};

set reset_port {rst_n};

# setting the input ports in a list to a variable
set input_ports {[31:0] a, [31:0] b, [3:0] alucontrol} ; 

# setting the output ports in a list to a variable
set output_ports {[31:0] result, [3:0] flags} ; 

# define the clocks
create_clock -period ${clock_period} -waveform {0 6} -name func_clk 
[get_ports ${clock_port}]

# setting up constraints for the reset signal
set_multicycle_path -setup 3 -from [get_ports ${reset_port}]
set_multicycle_path -hold 2 -from [get_ports ${reset_port}]

# Define input delays
set_input_delay 0.4 -clock [get_clocks {func_clk}] ${input_ports}

# Define output delays
set_output_delay 0.6 -clock [get_clocks {func_clk}] ${output_ports}

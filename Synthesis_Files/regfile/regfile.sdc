# setting up time units

set_units -time 1ns -capacitance pF

# setting the clock period 10ns, as period = 1/freq, here, freq = 100MHz
set clock_period 10; 

set top_module "regfile"

set clock_port {clk};

set reset_port {rst_n};

# setting the input ports in a list to a variable
set input_ports { we3, a1, a2, a3, wd3} ; 

# setting the output ports in a list to a variable
set output_ports {rd1, rd2} ; 

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

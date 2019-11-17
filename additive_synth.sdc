create_clock -name clk_i -period 20 [get_ports {clk_i}]
derive_pll_clocks
derive_clocks -period 10 -waveform {0 6}
set_input_delay -clock clk_i -max 3 [all_inputs]
set_input_delay -clock clk_i -min 1 [all_inputs]


onerror {resume}
quietly virtual signal -install /osc_ctrl_tb { /osc_ctrl_tb/osc_freq(31 downto 21)} w
quietly WaveActivateNextPane {} 0
add wave -noupdate /osc_ctrl_tb/rst
add wave -noupdate /osc_ctrl_tb/clk
add wave -noupdate /osc_ctrl_tb/samp_start
add wave -noupdate -radix unsigned /osc_ctrl_tb/freq
add wave -noupdate -radix decimal /osc_ctrl_tb/osc_en
add wave -noupdate -radix decimal -childformat {{/osc_ctrl_tb/w(31) -radix decimal} {/osc_ctrl_tb/w(30) -radix decimal} {/osc_ctrl_tb/w(29) -radix decimal} {/osc_ctrl_tb/w(28) -radix decimal} {/osc_ctrl_tb/w(27) -radix decimal} {/osc_ctrl_tb/w(26) -radix decimal} {/osc_ctrl_tb/w(25) -radix decimal} {/osc_ctrl_tb/w(24) -radix decimal} {/osc_ctrl_tb/w(23) -radix decimal} {/osc_ctrl_tb/w(22) -radix decimal} {/osc_ctrl_tb/w(21) -radix decimal}} -subitemconfig {/osc_ctrl_tb/osc_freq(31) {-radix decimal} /osc_ctrl_tb/osc_freq(30) {-radix decimal} /osc_ctrl_tb/osc_freq(29) {-radix decimal} /osc_ctrl_tb/osc_freq(28) {-radix decimal} /osc_ctrl_tb/osc_freq(27) {-radix decimal} /osc_ctrl_tb/osc_freq(26) {-radix decimal} /osc_ctrl_tb/osc_freq(25) {-radix decimal} /osc_ctrl_tb/osc_freq(24) {-radix decimal} /osc_ctrl_tb/osc_freq(23) {-radix decimal} /osc_ctrl_tb/osc_freq(22) {-radix decimal} /osc_ctrl_tb/osc_freq(21) {-radix decimal}} /osc_ctrl_tb/w
add wave -noupdate -radix unsigned -childformat {{/osc_ctrl_tb/osc_freq(31) -radix unsigned} {/osc_ctrl_tb/osc_freq(30) -radix unsigned} {/osc_ctrl_tb/osc_freq(29) -radix unsigned} {/osc_ctrl_tb/osc_freq(28) -radix unsigned} {/osc_ctrl_tb/osc_freq(27) -radix unsigned} {/osc_ctrl_tb/osc_freq(26) -radix unsigned} {/osc_ctrl_tb/osc_freq(25) -radix unsigned} {/osc_ctrl_tb/osc_freq(24) -radix unsigned} {/osc_ctrl_tb/osc_freq(23) -radix unsigned} {/osc_ctrl_tb/osc_freq(22) -radix unsigned} {/osc_ctrl_tb/osc_freq(21) -radix unsigned} {/osc_ctrl_tb/osc_freq(20) -radix unsigned} {/osc_ctrl_tb/osc_freq(19) -radix unsigned} {/osc_ctrl_tb/osc_freq(18) -radix unsigned} {/osc_ctrl_tb/osc_freq(17) -radix unsigned} {/osc_ctrl_tb/osc_freq(16) -radix unsigned} {/osc_ctrl_tb/osc_freq(15) -radix unsigned} {/osc_ctrl_tb/osc_freq(14) -radix unsigned} {/osc_ctrl_tb/osc_freq(13) -radix unsigned} {/osc_ctrl_tb/osc_freq(12) -radix unsigned} {/osc_ctrl_tb/osc_freq(11) -radix unsigned} {/osc_ctrl_tb/osc_freq(10) -radix unsigned} {/osc_ctrl_tb/osc_freq(9) -radix unsigned} {/osc_ctrl_tb/osc_freq(8) -radix unsigned} {/osc_ctrl_tb/osc_freq(7) -radix unsigned} {/osc_ctrl_tb/osc_freq(6) -radix unsigned} {/osc_ctrl_tb/osc_freq(5) -radix unsigned} {/osc_ctrl_tb/osc_freq(4) -radix unsigned} {/osc_ctrl_tb/osc_freq(3) -radix unsigned} {/osc_ctrl_tb/osc_freq(2) -radix unsigned} {/osc_ctrl_tb/osc_freq(1) -radix unsigned} {/osc_ctrl_tb/osc_freq(0) -radix unsigned}} -subitemconfig {/osc_ctrl_tb/osc_freq(31) {-height 15 -radix unsigned} /osc_ctrl_tb/osc_freq(30) {-height 15 -radix unsigned} /osc_ctrl_tb/osc_freq(29) {-height 15 -radix unsigned} /osc_ctrl_tb/osc_freq(28) {-height 15 -radix unsigned} /osc_ctrl_tb/osc_freq(27) {-height 15 -radix unsigned} /osc_ctrl_tb/osc_freq(26) {-height 15 -radix unsigned} /osc_ctrl_tb/osc_freq(25) {-height 15 -radix unsigned} /osc_ctrl_tb/osc_freq(24) {-height 15 -radix unsigned} /osc_ctrl_tb/osc_freq(23) {-height 15 -radix unsigned} /osc_ctrl_tb/osc_freq(22) {-height 15 -radix unsigned} /osc_ctrl_tb/osc_freq(21) {-height 15 -radix unsigned} /osc_ctrl_tb/osc_freq(20) {-height 15 -radix unsigned} /osc_ctrl_tb/osc_freq(19) {-height 15 -radix unsigned} /osc_ctrl_tb/osc_freq(18) {-height 15 -radix unsigned} /osc_ctrl_tb/osc_freq(17) {-height 15 -radix unsigned} /osc_ctrl_tb/osc_freq(16) {-height 15 -radix unsigned} /osc_ctrl_tb/osc_freq(15) {-height 15 -radix unsigned} /osc_ctrl_tb/osc_freq(14) {-height 15 -radix unsigned} /osc_ctrl_tb/osc_freq(13) {-height 15 -radix unsigned} /osc_ctrl_tb/osc_freq(12) {-height 15 -radix unsigned} /osc_ctrl_tb/osc_freq(11) {-height 15 -radix unsigned} /osc_ctrl_tb/osc_freq(10) {-height 15 -radix unsigned} /osc_ctrl_tb/osc_freq(9) {-height 15 -radix unsigned} /osc_ctrl_tb/osc_freq(8) {-height 15 -radix unsigned} /osc_ctrl_tb/osc_freq(7) {-height 15 -radix unsigned} /osc_ctrl_tb/osc_freq(6) {-height 15 -radix unsigned} /osc_ctrl_tb/osc_freq(5) {-height 15 -radix unsigned} /osc_ctrl_tb/osc_freq(4) {-height 15 -radix unsigned} /osc_ctrl_tb/osc_freq(3) {-height 15 -radix unsigned} /osc_ctrl_tb/osc_freq(2) {-height 15 -radix unsigned} /osc_ctrl_tb/osc_freq(1) {-height 15 -radix unsigned} /osc_ctrl_tb/osc_freq(0) {-height 15 -radix unsigned}} /osc_ctrl_tb/osc_freq
add wave -noupdate /osc_ctrl_tb/DUT/main/count
add wave -noupdate -format Analog-Step -height 74 -min -16106100000.0 -radix decimal /osc_ctrl_tb/DUT/lfo_scale
add wave -noupdate -format Analog-Step -height 74 -max 22528.0 -radix decimal /osc_ctrl_tb/DUT/lfo_tri
add wave -noupdate -format Analog-Step -height 74 -max 30719.999999999996 -radix decimal /osc_ctrl_tb/DUT/lfo_saw
add wave -noupdate -radix decimal /osc_ctrl_tb/DUT/lfo
add wave -noupdate -format Analog-Step -height 74 -max 65072.0 -min -65000.0 -radix decimal /osc_ctrl_tb/DUT/amp_slope
add wave -noupdate -radix decimal -childformat {{/osc_ctrl_tb/DUT/amp_n(16) -radix decimal} {/osc_ctrl_tb/DUT/amp_n(15) -radix decimal} {/osc_ctrl_tb/DUT/amp_n(14) -radix decimal} {/osc_ctrl_tb/DUT/amp_n(13) -radix decimal} {/osc_ctrl_tb/DUT/amp_n(12) -radix decimal} {/osc_ctrl_tb/DUT/amp_n(11) -radix decimal} {/osc_ctrl_tb/DUT/amp_n(10) -radix decimal} {/osc_ctrl_tb/DUT/amp_n(9) -radix decimal} {/osc_ctrl_tb/DUT/amp_n(8) -radix decimal} {/osc_ctrl_tb/DUT/amp_n(7) -radix decimal} {/osc_ctrl_tb/DUT/amp_n(6) -radix decimal} {/osc_ctrl_tb/DUT/amp_n(5) -radix decimal} {/osc_ctrl_tb/DUT/amp_n(4) -radix decimal} {/osc_ctrl_tb/DUT/amp_n(3) -radix decimal} {/osc_ctrl_tb/DUT/amp_n(2) -radix decimal} {/osc_ctrl_tb/DUT/amp_n(1) -radix decimal} {/osc_ctrl_tb/DUT/amp_n(0) -radix decimal}} -subitemconfig {/osc_ctrl_tb/DUT/amp_n(16) {-height 15 -radix decimal} /osc_ctrl_tb/DUT/amp_n(15) {-height 15 -radix decimal} /osc_ctrl_tb/DUT/amp_n(14) {-height 15 -radix decimal} /osc_ctrl_tb/DUT/amp_n(13) {-height 15 -radix decimal} /osc_ctrl_tb/DUT/amp_n(12) {-height 15 -radix decimal} /osc_ctrl_tb/DUT/amp_n(11) {-height 15 -radix decimal} /osc_ctrl_tb/DUT/amp_n(10) {-height 15 -radix decimal} /osc_ctrl_tb/DUT/amp_n(9) {-height 15 -radix decimal} /osc_ctrl_tb/DUT/amp_n(8) {-height 15 -radix decimal} /osc_ctrl_tb/DUT/amp_n(7) {-height 15 -radix decimal} /osc_ctrl_tb/DUT/amp_n(6) {-height 15 -radix decimal} /osc_ctrl_tb/DUT/amp_n(5) {-height 15 -radix decimal} /osc_ctrl_tb/DUT/amp_n(4) {-height 15 -radix decimal} /osc_ctrl_tb/DUT/amp_n(3) {-height 15 -radix decimal} /osc_ctrl_tb/DUT/amp_n(2) {-height 15 -radix decimal} /osc_ctrl_tb/DUT/amp_n(1) {-height 15 -radix decimal} /osc_ctrl_tb/DUT/amp_n(0) {-height 15 -radix decimal}} /osc_ctrl_tb/DUT/amp_n
add wave -noupdate -format Analog-Step -height 74 -max 62904.0 -radix unsigned /osc_ctrl_tb/DUT/amp
add wave -noupdate /osc_ctrl_tb/DUT/osc_en
add wave -noupdate /osc_ctrl_tb/DUT/slope
add wave -noupdate /osc_ctrl_tb/DUT/stretch
add wave -noupdate /osc_ctrl_tb/DUT/osc_freq_n
add wave -noupdate /osc_ctrl_tb/DUT/amp_o
add wave -noupdate /osc_ctrl_tb/DUT/osc_freq_o
add wave -noupdate /osc_ctrl_tb/DUT/osc_en_o
add wave -noupdate /osc_ctrl_tb/DUT/slope_i
add wave -noupdate /osc_ctrl_tb/DUT/freq_i
add wave -noupdate /osc_ctrl_tb/DUT/stretch_i
add wave -noupdate -format Literal /osc_ctrl_tb/DUT/rst_i
add wave -noupdate -format Literal /osc_ctrl_tb/DUT/samp_start_i
add wave -noupdate /osc_ctrl_tb/DUT/num_osc_i
add wave -noupdate -format Analog-Step -height 74 -max 1948209.9999999998 -min -338801.0 -radix decimal /osc_ctrl_tb/osc_bank_inst/sum_o
add wave -noupdate -format Analog-Step -height 74 -max 524016.00000000006 -min -519488.0 -radix decimal /osc_ctrl_tb/DUT/odd_scaled
add wave -noupdate -format Analog-Step -height 74 -max 524016.00000000006 -min -519488.0 -radix decimal /osc_ctrl_tb/DUT/even_scaled
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1344757 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 226
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1000
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ms
update
WaveRestoreZoom {0 ps} {5152682 ps}

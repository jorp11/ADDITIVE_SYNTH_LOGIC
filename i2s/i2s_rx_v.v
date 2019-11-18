//
// i2s Receiver - i2s input (stereo)
//
// Written by: Andrew Kilpatrick
// Copyright 2019: Kilpatrick Audio
//
//  - clk_i         - system clock input    - rising edge
//  - rst_i         - system reset input    - active high
//  - bclk_i        - bit clock input       - 64x samplerate
//  - lrclk_i       - L/R clock input       - left/right sample select
//  - sampstart_i   - sample strobe input   - start of a sample
//  - audio_l_o     - left channel output   - left channel data 24 bits signed
//  - audio_r_o     - right channel output  - right channel data 24 bits signed
//  - tx_i          - serial i2s input      - TX data in
//
// Signal amplitudes / limits:
//  - all signals are 24 bit signed
//  - max level is 0x7fffff (23 bits on)
//
module i2s_rx_v(input clk_i, 
        input rst_i,
        input bclk_i,
        input lrclk_i,
        input sampstart_i,
        output signed [23:0]audio_l_o,
        output signed [23:0]audio_r_o,
        input tx_i);
       
    // registers
    reg [23:0]audio_l_outreg;  // left channel output reg
    reg [23:0]audio_r_outreg;  // right channel output reg
    reg [31:0]audio_l_sreg;  // left channel shift reg
    reg [31:0]audio_r_sreg;  // right channel shift reg
    reg bclk_edge;  // bclk edge history
    reg rx_bit0;  // receive bit register
    reg rx_bit1;  // receive bit register

    // wires
    wire bclk_rising;  // bclk rising edge strobe
       
    assign audio_l_o = audio_l_outreg;
    assign audio_r_o = audio_r_outreg;
       
    // shift register control
    always @(posedge clk_i) begin
      if(rst_i) begin
        audio_l_outreg <= 24'h000000;
        audio_r_outreg <= 24'h000000;
        audio_l_sreg <= 32'h00000000;
        audio_r_sreg <= 32'h00000000;
      end
      else begin
        // sample start - register input data
        if(sampstart_i) begin
            audio_l_outreg <= audio_l_sreg[30:7];
            audio_r_outreg <= audio_r_sreg[30:7];
            audio_l_sreg <= 32'h00000000;
            audio_r_sreg <= 32'h00000000;
        end
        // right channel
        else if(lrclk_i) begin
            // bclk rising - latch data
            if(bclk_rising) begin
                audio_r_sreg <= {audio_r_sreg[30:0], rx_bit1};
            end
        end
        // left channel
        else begin
            // bclk rising - latch data
            if(bclk_rising) begin
                audio_l_sreg <= {audio_l_sreg[30:0], rx_bit1};
            end
        end
      end    
    end

    // register the input data twice
    always @(posedge clk_i) begin
        rx_bit0 <= tx_i;
        rx_bit1 <= rx_bit0;
    end
    
    // detect bclk rising edge - for updating the data output
    always @(posedge clk_i) begin
        bclk_edge <= bclk_i;
    end
    assign bclk_rising = bclk_i & !bclk_edge;
       
endmodule


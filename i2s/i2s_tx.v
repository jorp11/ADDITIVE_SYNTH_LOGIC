//
// i2s Transmiiter - i2s output (stereo)
//
// Written by: Andrew Kilpatrick
// Copyright 2019: Kilpatrick Audio
//
//  - clk_i         - system clock input    - rising edge
//  - rst_i         - system reset input    - active high
//  - bclk_i        - bit clock input       - 64x samplerate
//  - lrclk_i       - L/R clock input       - left/right sample select
//  - sampstart_i   - sample strobe input   - start of a sample
//  - audio_l_i     - left channel input    - left channel data 24 bits signed
//  - audio_r_i     - right channel input   - right channel data 24 bits signed
//  - tx_o          - serial i2s output     - TX data out
//
// Signal amplitudes / limits:
//  - all signals are 24 bit signed
//  - max level is 0x7fffff (23 bits on)
//
module i2s_tx(input clk_i, 
        input rst_i,
        input bclk_i,
        input lrclk_i,
        input sampstart_i,
        input signed [23:0]audio_l_i,
        input signed [23:0]audio_r_i,
        output tx_o);
       
    // registers
    reg [31:0]audio_l;  // left channel reg
    reg [31:0]audio_r;  // right channel reg
    reg bclk_edge;  // bclk edge history
    reg tx_bit;  // the transmit bit state

    // wires
    wire bclk_falling;  // bclk falling edge strobe
        
    // shift register control
    always @(posedge clk_i) begin
        if(rst_i) begin
            tx_bit <= 1'b0;
        end
        else begin
            // sample start - register input data
            if(sampstart_i) begin
                audio_l <= {1'b00, audio_l_i[23:0], 7'b0000000};  // one fewer bit here because we are in this state at frame start
                audio_r <= {2'b00, audio_r_i[23:0], 6'b000000};  // extra bit here to handle transitioning state
                tx_bit <= 0;
            end
            // right channel
            else if(lrclk_i) begin
                // bclk falling - shift data
                if(bclk_falling) begin
                    audio_r <= {audio_r[30:0], 1'b0};
                end
                tx_bit <= audio_r[31];
            end
            // left channel
            else begin
                // bclk falling - shift data
                if(bclk_falling) begin
                    audio_l <= {audio_l[30:0], 1'b0};
                end
                tx_bit <= audio_l[31];
            end
        end    
    end
    
    // connect bit reg to output
    assign tx_o = tx_bit;
    
    // detect bclk falling edge - for updating the data output
    always @(posedge clk_i) begin
        bclk_edge <= bclk_i;
    end
    assign bclk_falling = !bclk_i & bclk_edge;
    
 endmodule
 
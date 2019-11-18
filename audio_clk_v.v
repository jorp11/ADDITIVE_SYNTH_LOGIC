//
// Audio Clock Generator - Generates clock signals for audio processing functions.
//
// Written by: Andrew Kilpatrick
// Copyright 2016: Kilpatrick Audio
//
//  - clk_i         - system clock input
//  - rst_i         - system reset input
//  - mclk_o        - MCLK output           - 256x samplerate
//  - bclk_o        - bit clock output      - 64x samplerate
//  - lrclk_o       - L/R clock output      - left/right sample select
//  - codec_rst_o   - codec reset pulse     - active low reset on startup
//  - sampstart_o   - sample strobe output  - start of a sample
//
module audio_clk_v(input clk_i, 
        input rst_i,
        output mclk_o,
        output bclk_o,
        output lrclk_o,
        output codec_rst_o,
        output sampstart_o,
		  output framestart_o
		  );
        
    // settings
    parameter MCLK_DIV_BITS = 4;  // 2 = 192kHz, 3 = 96kHz, 4 = 48kHz (default) - with 98.3333MHz clock
    
    // regs
    reg [17:0]div;  // clock divider
    reg lrclk_edge;  // lrclk edge history
    reg codec_rst;  // codec reset output - active low
	 wire frameclk;
	 reg frameclk_edge;
    assign mclk_o = div[MCLK_DIV_BITS - 2];
    assign bclk_o = div[2 + MCLK_DIV_BITS - 2];
    assign lrclk_o = div[8 + MCLK_DIV_BITS - 2];
	 assign frameclk = div[15 + MCLK_DIV_BITS - 2];

    // divide down clock
    always @(posedge clk_i) begin
        if(rst_i) begin
            div <= 10'h000;
        end
        else begin
            div <= div + 1'b1;
        end
    end

    // detect lrclk falling edge
    always @(posedge clk_i) begin
        lrclk_edge <= lrclk_o;
    end
    assign sampstart_o = !lrclk_o & lrclk_edge;
    // detect lrclk falling edge
    always @(posedge clk_i) begin
        frameclk_edge <= frameclk;
    end
	    assign framestart_o = !frameclk & frameclk_edge; 
    // reset pulse
    always @(posedge clk_i) begin
        if(rst_i) begin
            codec_rst <= 0;
        end
        else if(lrclk_o) begin
            codec_rst <= 1;
        end
    end
    assign codec_rst_o = codec_rst;
endmodule



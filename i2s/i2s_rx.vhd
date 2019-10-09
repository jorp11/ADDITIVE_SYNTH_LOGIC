--
-- i2s Receiver - i2s input (stereo)
--
-- Written by: Andrew Kilpatrick
-- Copyright 2019: Kilpatrick Audio
--
--  - clk_i         - system clock input    - rising edge
--  - rst_i         - system reset input    - active high
--  - bclk_i        - bit clock input       - 64x samplerate
--  - lrclk_i       - L/R clock input       - left/right sample select
--  - sampstart_i   - sample strobe input   - start of a sample
--  - audio_l_o     - left channel output   - left channel data 24 bits signed
--  - audio_r_o     - right channel output  - right channel data 24 bits signed
--  - tx_i          - serial i2s input      - TX data in
--
-- Signal amplitudes / limits:
--  - all signals are 24 bit signed
--  - max level is 0x7fffff (23 bits on)
--
library ieee;
use ieee.std_logic_1164.all;

entity i2s_rx is
    generic (BITDEPTH :    integer := 24);
    port (clk_i       : in std_logic;
        rst_i       : in  std_logic;
        bclk_i      : in  std_logic; -- Bit clock
        lr_ws_i     : in  std_logic; -- Word select /LR clk
        sampstart_i : in  std_logic;
        audio_l_o   : out  std_logic_vector (BITDEPTH-1 downto 0);
        audio_r_o   : out  std_logic_vector (BITDEPTH-1 downto 0);
        rx_i        : in std_logic);
end i2s_rx;

architecture behavioral of i2s_rx is
constant NUM_TX_BITS : integer := 32;
    signal audio_l : std_logic_vector (BITDEPTH-1 downto 0);
    signal audio_r : std_logic_vector (BITDEPTH-1 downto 0);
    signal rx_bit0,rx_bit1  : std_logic;
    signal bclk_n1, bclk_n2,bclk_trans : std_logic;
	 signal data_in_l 		: std_logic_vector (31 downto 0);
	 signal data_in_r 		: std_logic_vector (31 downto 0);

--------------------------------
begin
    -- wires
	 
	 audio_l_o <= audio_l;
	 audio_r_o <= audio_r;
       
    -- shift register control
	 
	 process (clk_i)
	 begin
	 if rising_edge(clk_i) then
		if (rst_i='1') then
			audio_l <= (others=>'0');
			audio_r <= (others=>'0');
			data_in_l <= (others=>'0');
			data_in_r <= (others=>'0');

		elsif (sampstart_i = '1') then
			audio_l <= data_in_l (30 downto 7);
			audio_r <= data_in_r (30 downto 7);
			data_in_l <= (others=>'0');
			data_in_r <= (others=>'0');
		elsif (lr_ws_i = '1') then
			if (bclk_trans ='1') then
					data_in_l <= data_in_l(30 downto 0) & rx_bit1;
			end if;
		else 
			if (bclk_trans ='1') then
				data_in_r <= data_in_r(30 downto 0) & rx_bit1;
			end if;
		end if;
	 end if;
	 end process;

    -- register the input data twice
	 process(clk_i)
	 begin
	 if rising_edge(clk_i) then
        rx_bit0 <= rx_i;
        rx_bit1 <= rx_bit0;
	 end if;
    end process;
    
    -- detect bclk rising edge - for updating the data output

	 process (clk_i)
	 begin
		if rising_edge(clk_i) then
			bclk_n1 <= bclk_i;
			bclk_n2 <= bclk_n1;
		end if;
	 end process;
	 
	 bclk_trans <= ((bclk_i) and (bclk_n1) and (not bclk_n2));


       
end behavioral;


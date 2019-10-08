--
-- i2s Transmiiter - i2s output (stereo)
--
-- Written by: Josh Rohs
-- Copyright 2019: 
--
--  - clk_i         - system clock input    - rising edge
--  - rst_i         - system reset input    - active high
--  - bclk_i        - bit clock input       - 64x samplerate
--  - lrclk_i       - L/R clock input       - left/right sample select
--  - sampstart_i   - sample strobe input   - start of a sample
--  - audio_l_i     - left channel input    - left channel data 24 bits signed
--  - audio_r_i     - right channel input   - right channel data 24 bits signed
--  - tx_o          - serial i2s output     - TX data out
--
-- Signal amplitudes / limits:
--  - all signals are 24 bit signed
--  - max level is 0x7fffff (23 bits on)
--
library ieee;
use ieee.std_logic_1164.all;

entity i2s_tx is
    generic (BITDEPTH :    integer := 24);
    port (clk_i       : in std_logic;
        rst_i       : in  std_logic;
        bclk_i      : in  std_logic; -- Bit clock
        lr_ws_i     : in  std_logic; -- Word select /LR clk
        sampstart_i : in  std_logic;
        audio_l_i   : in  std_logic_vector (BITDEPTH-1 downto 0);
        audio_r_i   : in  std_logic_vector (BITDEPTH-1 downto 0);
        tx_o        : out std_logic);
end i2s_tx;

architecture behavioral of i2s_tx is
constant NUM_TX_BITS : integer := 32;
    signal audio_l : std_logic_vector (31 downto 0);
    signal audio_r : std_logic_vector (31 downto 0);
    signal tx_bit  : std_logic;
    signal bclk_n1, bclk_n2,bclk_trans : std_logic;
--------------------------------
begin
    process (clk_i)
    begin
        if rising_edge(clk_i) then
            if rst_i = '1' then
                tx_bit  <= '0';
                audio_l <= (others => '0');
                audio_r <= (others => '0');
            elsif sampstart_i = '1' then
--				                audio_l <= (31 => '0', 
--									 30 downto 30-BITDEPTH+1 => audio_l_i, 
--									 others => '0');

                audio_l <= "0" & audio_l_i & "0000000"; 
                audio_r <= "00" & audio_r_i & "000000";
--					   audio_r <= (31 => "0", 
--										30 =>"0", 
--										29 downto 29-BITDEPTH+1 => audio_r_i,
--										others => "0");

                tx_bit  <= '0';
            elsif (lr_ws_i = '1')then
                -- LRclk high so shift out on right channel
                if (bclk_trans = '1') then
						  tx_bit  <= audio_r(NUM_TX_BITS-1);
                    audio_r <= audio_r(NUM_TX_BITS-2 downto 0) & "0";
                end if;
            else
					if (bclk_trans = '1') then
						tx_bit  <= audio_l(NUM_TX_BITS-1);
						audio_r <= audio_l(NUM_TX_BITS-2 downto 0) & "0";
					end if;

            end if;
        end if;
    end process;

    tx_o <= tx_bit;

    process (clk_i)
    begin
	 if rising_edge(clk_i) then
        bclk_n1 <= bclk_i;
        bclk_n2 <= bclk_n1;
		  end if;
    end process;
    bclk_trans <= ((bclk_i) nor (bclk_n1)) and ( bclk_n2);



end behavioral;
 
-- Audio Clock Generator - Generates clock signals for audio processing functions.
--
-- Written by: Josh Rohs
-- Copyright 2019
--
--  - clk_i         - system clock input
--  - rst_i         - system reset input
--  - mclk_o        - MCLK output           - 256x samplerate
--  - bclk_o        - bit clock output      - 64x samplerate
--  - lrclk_o       - L/R clock output      - left/right sample select
--  - codec_rst_o   - codec reset pulse     - active low reset on startup
--  - sampstart_o   - sample strobe output  - start of a sample
--
library ieee;
use ieee.std_logic_1164.all;
entity audio_clk is
    generic (MCLK_DIVRATIO : integer := 8;  -- 98.3MHZ/8 = 12.28 MHz Mclk (48Khz*256)
        LRCLK_DIVRATIO   : integer := 2048; -- 98.3Mhz/2048 = 48khz
        BITCLK_DIV_RATIO : integer := 32);  -- 98.3 MHz/32 = 3.072Mhz
    port (clk_i : in std_logic;
        rst_i        : in  std_logic;
        mclk_o       : out std_logic;
        bclk_o       : out std_logic;
        lrclk_o      : out std_logic;
        codec_nrst_o  : out std_logic;
        samp_start_o : out std_logic;
    );
end audio_clk;
architecture behavioral of audio_clk is
    -- settings
    --parameter MCLK_DIV_BITS = 4;  
    -- 2 = 1x92kHz, 3 = 96kHz, 4 = 48kHz (default) - with 98.3333MHz clock
    signal mtemp  : std_logic;
    signal lrtemp : std_logic;
    signal btemp  : std_logic;
------------------------ 
begin
    mclk_proc : process (clk_i, rst_i)
        variable count : integer range 0 to MCLK_DIVRATIO-1;
    begin
        if rst_i='1' then -- initialize power up reset conditions
            mtemp <= '0';
            count := 0;
        elsif rising_edge(clk_i) then
            if count=MCLK_DIVRATIO/2-1 then -- toggle at half period
                mtemp <= not mtemp;
                count := count + 1;
            elsif count=MCLK_DIVRATIO-1 then -- toggle at end 
                mtemp <= not mtemp;
                count := 0; -- reached end of clock period. reset count
            else
                count := count + 1;
            end if;
        end if;
    end process;

    mclk_o <= mtemp;
    -----------------------------------------------------------------------------------

    bitclk_proc : process (clk_i, rst_i)
        variable count : integer range 0 to BITCLK_DIVRATIO-1;
    begin
        if rst_i='1' then -- initialize power up reset conditions
            btemp <= '0';
            count := 0;
        elsif rising_edge(clk_i) then
            if count=BITCLK_DIVRATIO/2-1 then -- toggle at half period
                btemp <= not btemp;
                count := count + 1;
            elsif count=BITCLK_DIVRATIO-1 then -- toggle at end 
                btemp <= not btemp;
                count := 0; -- reached end of clock period. reset count
            else
                count := count + 1;
            end if;
        end if;
    end process;

    bclk_o <= btemp;
    -----------------------------------------------------------------------------------
    lrclk_proc : process (clk_i, rst_i)
        variable count : integer range 0 to LRCLK_DIVRATIO-1;
    begin
        if (rst_i ='1') then -- initialize power up reset conditions
            lrtemp <= '0';
            count  := 0;
        elsif rising_edge(clk_i) then
            samp_start_o <= '0';
            if count=LRCLK_DIVRATIO/2-1 then -- toggle at half period
                lrtemp <= not lrtemp;
                count  := count + 1;
            elsif count=LRCLK_DIVRATIO-1 then -- toggle at end 
                lrtemp       <= not lrtemp;
                count        := 0; -- reached end of clock period. reset count
                samp_start_o <= '1';
            else
                count := count + 1;
            end if;
        end if;
    end process;

    lrclk_o <= lrtemp;

    -- Should codec rst 
    codec_nrst : process (clk_i,rst_i)
    begin
        codec_nrst <= '1';
        if rising_edge(clk_i)then
            if (rst_i ='1') then
                codec_nrst <= '0';
            --elsif (lrclk_o = '1') then
            --    codec_rst <= '1';
            end if;
        end if;
    end process;
    codec_nrst_o <= codec_nrst;
end behavioral;



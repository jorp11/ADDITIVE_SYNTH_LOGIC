library  ieee;
use  ieee.std_logic_1164.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE ieee.math_real.log2;
USE ieee.math_real.ceil;
library work;
use work.constants_pkg.all; -- TODO rename this

entity additive_synth is 
	port (clk_i: in std_logic; -- 50 MHZ clock in
			rst_i: in std_logic; -- Rest in - N/C
			SW: in std_logic_vector (3 downto 0);
			KEY: in std_logic_vector (1 downto 0);
			LED: out std_logic_vector (7 downto 0);
			i2s_mclk_o : out std_logic;
			i2s_ws_o : out std_logic;
			i2s_tx_o: out std_logic);
	-- TODO ADD SPI/I2C/I2S interfaces
end additive_synth;

architecture behavioral of additive_synth is
----- SIGNALS --------
	signal clk_98: std_logic;
	signal rst: std_logic;
	signal clk_48k: std_logic;
	signal pll_lock: std_logic;
	signal osc_out: std_logic_vector(ROM_DATA_WIDTH-1 downto 0);
	signal mclk, bclk,lr_ws, samp_start : std_logic;
	signal audio_l, audio_r : std_logic_vector (OUT_BIT_DEPTH-1 downto 0);
	signal codec_nrst : std_logic;

	signal freq: unsigned (PA_WIDTH-1 downto 0);
	signal amp :unsigned(AMP_WIDTH-1 downto 0);
	signal stretch : integer range 0 to 1023 := 0;
 	signal slope : signed(AMP_WIDTH-2 downto 0) := (others=>'0');
	
	signal osc_en : std_logic_vector (NUM_OSC -1 downto 0);
	signal osc_freq : unsigned (PA_WIDTH-1 downto 0);
	signal sum_out : signed (23 downto 0);
	signal even_gain, odd_gain : unsigned(AMP_WIDTH-1 downto 0);
	signal lfo_rate : unsigned( AMP_WIDTH-1 downto 0);
	--------------------------------
	begin
	--- INSTANTIATIONS
		rst98Mhz :  reset_sync 
		port map (clk_i => clk_98,
				async_rst_i => key(0),
				sync_rst_o => rst
				);
	--------------------------------	
		PLL_inst: pll PORT MAP (
			areset => key(0),
			inclk0 => clk_i,
			c0 => clk_98,
			locked => pll_lock
			);
	--------------------------------	

		audio_clock : audio_clk
		generic map(MCLK_DIVRATIO => 8,  -- 98.3MHZ/8 = 12.28 MHz Mclk (48Khz*256)
			  LRCLK_DIVRATIO    => 2048, -- 98.3Mhz/2048 = 48khz
			  BITCLK_DIVRATIO => 32)  -- 98.3 MHz/32 = 3.072Mhz
		port map(clk_i 	=> clk_98,
        rst_i        => rst,
        mclk_o       => mclk,
        bclk_o       => bclk,
        lrclk_o      => lr_ws,
        codec_nrst_o  => codec_nrst,
        samp_start_o  => samp_start
    );
		i2s_ws_o <= lr_ws;
		i2s_mclk_o <= mclk;
			
		--------------------------------
		i2s_tx_inst : i2s_tx
		generic map(BITDEPTH => OUT_BIT_DEPTH )
		port map(clk_i    => clk_98,
        rst_i       	=> rst,
        bclk_i      	=> bclk, -- Bit clock
        lr_ws_i     	=> lr_ws,  -- Word select /LR clk
        sampstart_i 	=> samp_start,
        audio_l_i    => audio_l,
        audio_r_i    => audio_r,
        tx_o         => i2s_tx_o);
		  
		  audio_r <=  (others =>'0');
		  audio_l <=  (others =>'1');
		  
		  
		  DUT: osc_ctrl
	generic map(NUM_OSC => NUM_OSC,
			PA_WIDTH => PA_WIDTH,-- TODO REPLACE W CONST
			ROM_DATA_WIDTH => ROM_DATA_WIDTH,-- TODO REPLACE W CONST
			ROM_ADDR_WIDTH => ROM_ADDR_WIDTH,-- TODO REPLACE W CONST);
			AMP_WIDTH =>AMP_WIDTH)
	port map (clk_i => clk_98,
			rst_i => rst,
			samp_start_i => samp_start,
			num_osc_i => num_osc,
			freq_i => freq,
			stretch_i => stretch,
			slope_i => slope,
		lfo_rate_i => lfo_rate,
even_gain_i => even_gain,
odd_gain_i  => odd_gain,
			osc_freq_o=> osc_freq,
			osc_en_o => osc_en,
			amp_o => amp
			);
osc_bank_inst: osc_bank
	generic map(NUM_OSC => NUM_OSC,
			PA_WIDTH => PA_WIDTH,-- TODO REPLACE W CONST
			ROM_DATA_WIDTH => ROM_DATA_WIDTH,-- TODO REPLACE W CONST
			ROM_ADDR_WIDTH => ROM_ADDR_WIDTH,-- TODO REPLACE W CONST);
			AMP_WIDTH =>AMP_WIDTH)
	port map (clk_i => clk_98,
			rst_i => rst,
			freq_i => osc_freq,
			osc_en_i => osc_en,
			samp_start_i => samp_start,
			amp_i => amp,
			sum_o  => sum_out
			);
		  
		  
		  
  --------------------------------
		process (KEY)
			begin
				LED(0) <= not(KEY(0));
		end process;
	--------------------------------
	

	end behavioral;
			
			
-- osc_tb.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity i2s_tx_tb is
end i2s_tx_tb;


architecture behaviour of i2s_tx_tb is
	constant clock_period : time := 20 ns;

	constant PA_WIDTH :integer := 32;
	constant ROM_DATA_WIDTH :integer := 18;
	constant ROM_ADDR_WIDTH :integer := 14;
 constant OUT_BIT_DEPTH : integer := 24;

	component i2s_tx is
    generic (BITDEPTH :    integer );
    port (clk_i       : in std_logic;
        rst_i       : in  std_logic;
        bclk_i      : in  std_logic; -- Bit clock
        lr_ws_i     : in  std_logic; -- Word select /LR clk
        sampstart_i : in  std_logic;
        audio_l_i   : in  std_logic_vector (OUT_BIT_DEPTH-1 downto 0);
        audio_r_i   : in  std_logic_vector (OUT_BIT_DEPTH-1 downto 0);
        tx_o        : out std_logic);
end component;
	
	 component audio_clk is
    generic (MCLK_DIVRATIO : integer;  -- 98.3MHZ/8 = 12.28 MHz Mclk (48Khz*256)
        LRCLK_DIVRATIO   : integer; -- 98.3Mhz/2048 = 48khz
        BITCLK_DIVRATIO : integer);  -- 98.3 MHz/32 = 3.072Mhz
    port (clk_i : in std_logic;
        rst_i        : in  std_logic;
        mclk_o       : out std_logic;
        bclk_o       : out std_logic;
        lrclk_o      : out std_logic;
        codec_nrst_o  : out std_logic;
        samp_start_o : out std_logic
    );
	end component;
	signal mclk, bclk,lr_ws, samp_start : std_logic;
	signal audio_l, audio_r : std_logic_vector (OUT_BIT_DEPTH-1 downto 0);
	signal codec_nrst : std_logic;
	signal rst,clk : std_logic := '0';
	signal i2s_tx_o : std_logic;

	-------------------------------------------
	begin 
			audio_clock : audio_clk
		generic map(MCLK_DIVRATIO => 8,  -- 98.3MHZ/8 = 12.28 MHz Mclk (48Khz*256)
			  LRCLK_DIVRATIO    => 2048, -- 98.3Mhz/2048 = 48khz
			  BITCLK_DIVRATIO => 32)  -- 98.3 MHz/32 = 3.072Mhz
		port map(clk_i 	=> clk,
        rst_i        => rst,
        mclk_o       => mclk,
        bclk_o       => bclk,
        lrclk_o      => lr_ws,
        codec_nrst_o  => codec_nrst,
        samp_start_o  => samp_start
    );
	
		DUT : i2s_tx
		generic map(BITDEPTH => OUT_BIT_DEPTH )
		port map(clk_i    => clk,
        rst_i       	=> rst,
        bclk_i      	=> bclk, -- Bit clock
        lr_ws_i     	=> lr_ws,  -- Word select /LR clk
        sampstart_i 	=> samp_start,
        audio_l_i    => audio_l,
        audio_r_i    => audio_r,
        tx_o         => i2s_tx_o);
		  

		  
		  
	clock_process :process
	begin
	clk <= '0';
	wait for clock_period/2;
	clk <= '1';
	wait for clock_period/2;
	end process;

	simulation_process : process
        begin
            rst <= '1';
				--audio_r <=  (23 => '1',others =>'1');   
				--audio_l <=  (23 => '1', others =>'1');
		audio_r<= x"AAAAAA";
		audio_l <= x"555555";
            wait for 1000 ns;
				--audio_r <=  (23 => '1', others =>'1');
		--		audio_l <=  (23 => '1',others =>'1');    	    
				rst <= '0';
				wait for 10000 ns;
		--		audio_r <=  (23 => '1',others =>'1');   
		--		audio_l <=  (23 => '1', others =>'1');
				wait for 500000 ns;
            assert false
				report "simulation over"
				severity failure;
        end process;

end architecture behaviour;
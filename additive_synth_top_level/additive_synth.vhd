
library  ieee;
use  ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


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

 --- CONSTANTS 
 constant PA_WIDTH : integer := 32;
 constant ROM_ADDR_WIDTH : integer :=14;

 constant ROM_DATA_WIDTH : integer :=18;
 constant OUT_BIT_DEPTH : integer := 24;
---------- COMPONENT INSTANTIATION ------------
---MOVE THESE TO PACKAGE?
	component pll
	port (
	areset: in std_logic;
	inclk0 : in std_logic;
	c0 : out std_logic;
	locked: out std_logic
	);
	end component;
		
	component clk_div is 
		generic (DIVRATIO : integer);
		port (clk_i: in std_logic; --98.03 MHz Clock
				rst_i: in std_logic;
				clk_o: out std_logic);
	end component;

	component reset_sync is 
		port (clk_i: in std_logic;
				async_rst_i: in std_logic;
				sync_rst_o : out std_logic
			);
	end component;
	
	component osc is 
	generic (PA_WIDTH : integer;
			ROM_DATA_WIDTH : integer;  -- TODO REPLACE W CONST
		ROM_ADDR_WIDTH : integer);
	port (clk_i: in std_logic;
			rst_i: in std_logic;
			freq_i : in std_logic_vector (PA_WIDTH-1 downto 0);
			enable_i : in std_logic;
			sin_o : out std_logic_vector (ROM_DATA_WIDTH-1 downto 0)
			);
	end component;

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
----- SIGNALS --------
	signal clk_98: std_logic;
	signal rst: std_logic;
	signal clk_48k: std_logic;
	signal pll_lock: std_logic;
	signal osc_out: std_logic_vector(ROM_DATA_WIDTH-1 downto 0);
	signal mclk, bclk,lr_ws, samp_start : std_logic;
	signal audio_l, audio_r : std_logic_vector (OUT_BIT_DEPTH-1 downto 0);
	signal codec_nrst : std_logic;
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
		osc1 : osc 
		GENERIC MAP(PA_WIDTH => PA_WIDTH,
						ROM_DATA_WIDTH =>ROM_DATA_WIDTH,  
						ROM_ADDR_WIDTH => ROM_ADDR_WIDTH)
		PORT MAP (clk_i=>clk_98,
			rst_i => rst,
			freq_i => x"00000001",
			enable_i => '1',
			sin_o => osc_out
			);
		--------------------------------	
		clk_div_48khz :  clk_div  
		generic map(DIVRATIO => 2048)
		port map(clk_i => clk_98,
			rst_i => rst,
			clk_o =>  clk_48k
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
  --------------------------------
		process (KEY)
			begin
				LED(0) <= not(KEY(0));
		end process;
	--------------------------------
	

	end behavioral;
			
			
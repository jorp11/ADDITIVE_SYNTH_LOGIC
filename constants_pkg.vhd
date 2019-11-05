library  ieee;
use  ieee.std_logic_1164.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE ieee.math_real.log2;
USE ieee.math_real.ceil;
library work;
use work.type_pkg.all;

package constants_pkg is

 --- CONSTANTS 
 constant PA_WIDTH : integer := 32;
constant ROM_ADDR_WIDTH : integer :=14;
constant ROM_DATA_WIDTH : integer :=16;
constant OUT_BIT_DEPTH : integer := 24;
constant NUM_OSC: integer := 64;
	constant AMP_WIDTH : integer :=16;
	
	
	

component osc_ctrl is
	generic (NUM_OSC : integer := 4;
			PA_WIDTH : integer := 32;
			ROM_DATA_WIDTH :integer :=16;	
		   ROM_ADDR_WIDTH :integer := 14;		
			AMP_WIDTH : integer :=16); 
	port (clk_i : in std_logic;
		rst_i    : in  std_logic;
		samp_start_i : in std_logic;
		num_osc_i   : in integer range 0 to NUM_OSC; -- todo 512 as constant MAX osc number
		freq_i		: in unsigned(PA_WIDTH-1 downto 0);
		stretch_i 	:in integer range 0 to 1023;
		slope_i		:in signed(AMP_WIDTH-2 downto 0);
		lfo_rate_i	: in unsigned(AMP_WIDTH-1 downto 0);
		lfo_shape_i : in lfo_shape_t;
		even_gain_i 	: in unsigned(AMP_WIDTH-1 downto 0);
		odd_gain_i	: in unsigned(AMP_WIDTH-1 downto 0);
		osc_freq_o   : out  unsigned (PA_WIDTH-1 downto 0); -- phase_acc keyword 
		osc_en_o : out std_logic_vector (NUM_OSC -1 downto 0); -- ONE hot enable for oscillator bank.
		--phase_offset_o  : out std_logic_vector (PA_WIDTH-2 downto 0);
		amp_o	 : out unsigned (AMP_WIDTH-1 downto 0)
	);
end component;
	component osc_bank is 
	generic (NUM_OSC : integer := 4;
			PA_WIDTH : integer := 32;   
			ROM_DATA_WIDTH : integer := 16;  
			ROM_ADDR_WIDTH : integer := 14;
			AMP_WIDTH : integer :=18); 
	port (clk_i : in std_logic;
		rst_i    : in  std_logic;
		freq_i   : in  unsigned (PA_WIDTH-1 downto 0);
		osc_en_i : in std_logic_vector (NUM_OSC -1 downto 0); -- ONE hot enable for oscillator bank.
		samp_start_i : in std_logic;
		--phase_i  : in std_logic_vector (PA_WIDTH-1 downto 0);
		amp_i	 : in unsigned (AMP_WIDTH-1 downto 0);
		sum_o    : out signed (23 downto 0)
	);
	end component;
	


	component pll
	port (
	areset: in std_logic;
	inclk0 : in std_logic;
	c0 : out std_logic;
	locked: out std_logic
	);
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
	
component i2s_rx is
    generic (BITDEPTH :    integer := 24);
    port (clk_i       : in std_logic;
        rst_i       : in  std_logic;
        bclk_i      : in  std_logic; -- Bit clock
        lr_ws_i     : in  std_logic; -- Word select /LR clk
        sampstart_i : in  std_logic;
        audio_l_o   : out  std_logic_vector (BITDEPTH-1 downto 0);
        audio_r_o   : out  std_logic_vector (BITDEPTH-1 downto 0);
        rx_i        : in std_logic);
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

	end package constants_pkg;
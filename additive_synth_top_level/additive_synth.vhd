
library  ieee;
use  ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity additive_synth is 
	port (clk_i: in std_logic; -- 50 MHZ clock in
			rst_i: in std_logic; -- Rest in - N/C
			SW: in std_logic_vector (3 downto 0);
			KEY: in std_logic_vector (1 downto 0);
			LED: out std_logic_vector (7 downto 0));
	-- TODO ADD SPI/I2C/I2S interfaces
end additive_synth;

architecture behavioral of additive_synth is
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
	generic (WIDTH : integer);
	port (clk_i: in std_logic;
			rst_i: in std_logic;
			freq_i : in std_logic_vector (WIDTH downto 0);
			enable_i : in std_logic;
			sin_o : out std_logic_vector (WIDTH downto 0)
			);
	end component;

	
----- SIGNALS --------
	signal clk_98: std_logic;
	signal rst_98: std_logic;
	signal clk_48k: std_logic;
	signal count, count50: std_logic_vector (31 downto 0);
	signal pll_lock: std_logic;
	signal osc_out: std_logic_vector(31 downto 0);
	--------------------------------
	begin
	--- INSTANTIATIONS
		rst98Mhz :  reset_sync 
		port map (clk_i => clk_98,
				async_rst_i => key(0),
				sync_rst_o => rst_98
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
		GENERIC MAP(WIDTH => 32)
		PORT MAP (clk_i=>clk_98,
			rst_i => rst_98,
			freq_i => x"00000001",
			enable_i => '1',
			sin_o => osc_out
			);
		clk_div_48khz :  clk_div  
		generic map(DIVRATIO => 2048)
		port map(clk_i => clk_98,
			rst_i => rst_98,
			clk_o =>  clk_48k
			);	
	--------------------------------
		process (KEY)
			begin
				LED(0) <= not(KEY(0));
		end process;
	--------------------------------
		process (clk_98,rst_98)
			begin
			if (rst_98 = '1') then
				count50 <= (others => '0');
			elsif (rising_edge (clk_98)) then
				count50 <= count50 + "1";
				led(2) <= count50(27);
			end if;
		end process;
	

	end behavioral;
			
			
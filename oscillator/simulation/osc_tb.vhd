-- osc_tb.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE ieee.math_real.log2;
USE ieee.math_real.ceil;

entity osc_tb is
end osc_tb;

architecture behaviour of osc_tb is
	constant clock_period : time := 20 ns;
	constant NUM_OSC : integer :=2;
	constant PA_WIDTH :integer := 32;
	constant ROM_DATA_WIDTH :integer := 16;
	constant ROM_ADDR_WIDTH :integer := 14;
	

	component osc_bank is 
	generic (NUM_OSC : integer := 4;
			PA_WIDTH : integer := 32;   
			ROM_DATA_WIDTH : integer := 16;  
			ROM_ADDR_WIDTH : integer := 14); 
	port (clk_i : in std_logic;
		rst_i    : in  std_logic;
		freq_i   : in  unsigned (PA_WIDTH-1 downto 0);
		osc_en_i : in std_logic_vector (NUM_OSC -1 downto 0); -- ONE hot enable for oscillator bank.
		samp_start_i : in std_logic;
		--phase_i  : in std_logic_vector (PA_WIDTH-1 downto 0);
		amp_i	 : in unsigned (ROM_DATA_WIDTH-1 downto 0);
		--osc_ind_o : out integer;
		sin_o    : out signed (ROM_DATA_WIDTH-1 downto 0)
	);
	end component;

	signal rst,clk : std_logic := '0';
	signal enable : std_logic_vector (num_osc-1 downto 0);
	signal freq: unsigned (PA_WIDTH-1 downto 0);
	signal amp :unsigned(ROM_DATA_WIDTH-1 downto 0);
	signal sin_o : signed(ROM_DATA_WIDTH-1 downto 0); 
	signal samp_start: std_logic;




	-------------------------------------------
	begin 
	DUT: osc_bank
	generic map(NUM_OSC => NUM_OSC,
			PA_WIDTH => PA_WIDTH,-- TODO REPLACE W CONST
			ROM_DATA_WIDTH => ROM_DATA_WIDTH,-- TODO REPLACE W CONST
			ROM_ADDR_WIDTH => ROM_ADDR_WIDTH)-- TODO REPLACE W CONST);
	port map (clk_i => clk,
			rst_i => rst,
			freq_i => freq,
			osc_en_i => enable,
			samp_start_i => samp_start,
			amp_i => amp,
			sin_o  => sin_o
			);
	clock_process :process
	begin
	clk <= '0';
	wait for clock_period/2;
	clk <= '1';
	wait for clock_period/2;
	end process;

	
	freq_process : process
	begin
           wait until clk = '1' and clk'event;
		freq <= to_unsigned(80000000,PA_WIDTH);
		enable <=b"01";
           wait until clk = '1' and clk'event;
		freq <= to_unsigned(16000000,PA_WIDTH);
		enable <=b"10";
	end process;

	simulation_process : process
        begin
            rst <= '1';
	    amp   <= x"FFFF";
            wait for 1000 ns;        
    	    rst <= '0';
	    wait for 60000 ns;
            assert false
    	report "simulation over"
	severity failure;
        end process;

end architecture behaviour;
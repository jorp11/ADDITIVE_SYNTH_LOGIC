-- osc_tb.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity osc_tb is
end osc_tb;

architecture behaviour of osc_tb is

	constant NUM_OSC : integer :=1;
	constant PA_WIDTH :integer := 32;
	constant ROM_DATA_WIDTH :integer := 18;
	constant ROM_ADDR_WIDTH :integer := 14;

	component osc_bank is 
	generic (NUM_OSC : integer := 4;
			PA_WIDTH : integer := 32;   
			ROM_DATA_WIDTH : integer := 18;  
			ROM_ADDR_WIDTH : integer := 14); 
	port (clk_i : in std_logic;
		rst_i    : in  std_logic;
		freq_i   : in  std_logic_vector (PA_WIDTH-1 downto 0);
		osc_en_i : in std_logic_vector (NUM_OSC -1 downto 0); -- ONE hot enable for oscillator bank.
		--phase_i  : in std_logic_vector (PA_WIDTH-1 downto 0);
		amp_i	 : in std_logic_vector (ROM_DATA_WIDTH-1 downto 0);
		--osc_ind_o : out integer;
		phase_o    : out std_logic_vector (ROM_DATA_WIDTH-1 downto 0)
	);
	end component;

	signal enable, rst,clk : std_logic := '0';
	signal freq: unsigned (PA_WIDTH-1 downto 0);
	signal amp :unsigned(ROM_DATA_WIDTH-1 downto 0);
	signal sin_o : std_logic_vector(ROM_DATA_WIDTH-1 downto 0); -- TODO make signed
	constant clock_period : time := 20 ns;

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
			amp_i => amp,
			phase_o  => sin_o
			);
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
				freq <= (others => '0');
				amp   <= x"FFFF";
            wait for 1000 ns;        
            wait until clk = '0' and clk'event;
				freq <= to_unsigned(100,PA_WIDTH);
				enable <= '1';
    	    	rst <= '0';
	    wait for 50000 ns;
            assert false
    	report "simulation over"
	severity failure;
        end process;

end architecture behaviour;
-- clk_div_tb.vhd
library ieee;
use ieee.std_logic_1164.all;

entity clk_div_tb is
end clk_div_tb;


architecture behaviour of clk_div_tb is

	component clk_div is 

		generic (DIVRATIO : integer);
		port (clk_i: in std_logic; 
				rst_i: in std_logic;
				clk_o: out std_logic);
	end component;

	signal rst,clk, divclk : std_logic := '0';
	constant clock_period : time := 20 ns;

	-------------------------------------------
	begin 
	DUT: clk_div 
		generic map (DIVRATIO => 1024)
		port map(clk_i => clk,
				rst_i => rst,
				clk_o => divclk);

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
            wait for 1000 ns;
    	    rst <= '0';
	    wait for 50000 ns;
            assert false
    	report "simulation over"
	severity failure;
        end process;

end architecture behaviour;
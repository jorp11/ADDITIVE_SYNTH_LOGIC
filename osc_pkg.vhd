library ieee;
use ieee.std_logic_1164.all;

package osc_okg is
	component osc is 
	generic (WIDTH : integer);
	port (clk_i: in std_logic;
			rst_i: in std_logic;
			freq_i : in std_logic_vector (WIDTH downto 0);
			enable_i : in std_logic;
			sin_o : out std_logic_vector (WIDTH downto 0)
			);
	end component;
end package;
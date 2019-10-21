-- This module makes a frequency argument and adds it to a phase accumulator 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity phase_acc is 
	generic (PA_WIDTH : integer := 32);
	port   (clk_i: in std_logic;
			rst_i: in std_logic;
			freq_i : in unsigned (PA_WIDTH-1 downto 0);
			enable_i : in std_logic;
			phase_o : out unsigned (PA_WIDTH-1 downto 0)
			);
end phase_acc;

architecture behavioral of phase_acc is
signal phase_acc : std_logic_vector(PA_WIDTH downto 0);
	--------------------------------
	begin
	
		process (clk_i,rst_i)
		begin
		if rising_edge(clk_i) then
			if (rst_i = '1') then
				phase_acc <= (others => '0');
			elsif (enable_i = '1') then
					phase_acc <= std_logic_vector(unsigned(phase_acc) + unsigned(freq_i));
			end if;
		end if;
	end process;
	 
end behavioral;
			
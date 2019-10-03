-- This module takes a clock and generates a slower clock with an integer divisor ratio

library ieee;
use ieee.std_logic_1164.all;

entity clk_div is 
	generic (DIVRATIO : integer :=32);
	port (clk_i: in std_logic; 
			rst_i: in std_logic;
			clk_o: out std_logic);
end clk_div;

architecture behavioral of clk_div is
   signal temp : std_logic ;
	--------------------------------
	begin
	
	clkdiv_proc : process (clk_i, rst_i)
    variable count : integer range 0 to DIVRATIO-1;
    begin
        if rst_i='1' then          -- initialize power up reset conditions
            temp <= '0';
            count := 0;
        elsif rising_edge(clk_i) then
            if count=DIVRATIO/2-1 then      -- toggle at half period
                temp <= not temp;
                count := count + 1;
            elsif count=DIVRATIO-1 then     -- toggle at end 
                temp <= not temp;
                count := 0;                 -- reached end of clock period. reset count
            else
                count := count + 1;
            end if;
        end if;
    end process;
	 
	 clk_o <= temp;
	 
	end behavioral;
			
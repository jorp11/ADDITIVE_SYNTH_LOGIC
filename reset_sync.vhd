-- Reset Synchronizer module. Takes an asynchronus


library ieee;
use ieee.std_logic_1164.all;

entity reset_sync is 
	port (clk_i: in std_logic;
			async_rst_i: in std_logic;
			sync_rst_o : out std_logic
		);
end reset_sync;

architecture behavioral of reset_sync is
signal rff1 : std_logic;
	--------------------------------
	begin
	process(clk_i,async_rst_i)
	begin
	if async_rst_i = '1' then
		rff1 <= '0';
		sync_rst_o <= '0';
	elsif (rising_edge(clk_i)) then
		rff1 <= '1';
		sync_rst_o <= rff1;
		end if;
	end process;
	

end behavioral;
			
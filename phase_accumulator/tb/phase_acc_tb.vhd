-- phase_acc_tb.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity phase_acc_tb is
end phase_acc_tb;


architecture behaviour of phase_acc_tb is

	component phase_acc is 
	generic (PA_WIDTH : integer := 32); 
	port   (clk_i: in std_logic;
			rst_i: in std_logic;
			freq_i : in std_logic_vector ((PA_WIDTH-1) downto 0);
			enable_i : in std_logic;
			phase_o : out std_logic_vector ((PA_WIDTH-1) downto 0)
			);
	end component;

	constant PA_WIDTH :integer := 32;
	constant ROM_DATA_WIDTH :integer := 18;
	constant ROM_ADDR_WIDTH :integer := 14;
	signal enable, rst,clk : std_logic := '0';
	signal freq: std_logic_vector (PA_WIDTH-1 downto 0);
	signal phase_acc_o : std_logic_vector(PA_WIDTH-1 downto 0);
	constant clock_period : time := 20 ns;

	-------------------------------------------
	begin 
	DUT : phase_acc 
		GENERIC MAP(PA_WIDTH => PA_WIDTH)
		PORT MAP (clk_i=>clk,
			rst_i => rst,
			freq_i => freq,
			enable_i => enable,
			phase_o => phase_acc_o
			);
--

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
            wait for 1000 ns;
				freq <= std_logic_vector(to_signed(100,PA_WIDTH));
    	    rst <= '0';
	    wait for 50000 ns;
            assert false
    	report "simulation over"
	severity failure;
        end process;

end architecture behaviour;

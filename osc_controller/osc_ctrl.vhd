-- This module makes a frequency argument and adds it to a phase accumulator 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity osc_ctrl is
	generic (num_osc : integer := 4;
		PA_WIDTH       : integer := 32;
		ROM_DATA_WIDTH : integer := 18;
		ROM_ADDR_WIDTH : integer := 14); -- TODO REPLACE W CONST);
	port (clk_i : in std_logic;
		rst_i          : in  std_logic;
		freq_i         : in  std_logic_vector (PA_WIDTH-1 downto 0);
		enable_i       : in  std_logic;
		sample_start_i : in  std_logic;
		sin_o          : out std_logic_vector (ROM_DATA_WIDTH-1 downto 0)
	);
end osc_ctrl;

architecture behavioral of osc_ctrl is
	component osc is
		generic (PA_WIDTH : integer := 32;   -- TODO REPLACE W CONST
			ROM_DATA_WIDTH : integer := 18;  -- TODO REPLACE W CONST
			ROM_ADDR_WIDTH : integer := 14); -- TODO REPLACE W CONST);
		port (clk_i : in std_logic;
			rst_i    : in  std_logic;
			freq_i   : in  std_logic_vector (PA_WIDTH-1 downto 0);
			enable_i : in  std_logic;
			sin_o    : out std_logic_vector (ROM_DATA_WIDTH-1 downto 0)
		);
	end component;
	type osc_array_t is array (0 to num_osc-1) of std_logic_vector(ROM_DATA_WIDTH-1 downto 0);
	type freq_array_t is array (0 to num_osc-1) of std_logic_vector(ROM_ADDR_WIDTH-1 downto 0);
	type enable_array_t is array (0 to num_osc-1) of std_logic;
	signal sin_array    : osc_array_t;
	signal freq_array   : freq_array_t;
	signal enable_array : enable_array_t;
--------------------------------
begin
	gen_osc : for i in 0 to num_osc-1 generate
		--uut: FA port map (a => a(i), b => b(i), c_in => c(i), s => s(i), c_out => c(i+1));
		osc : osc
			GENERIC MAP(PA_WIDTH => PA_WIDTH,
				ROM_DATA_WIDTH => ROM_DATA_WIDTH,
				ROM_ADDR_WIDTH => ROM_ADDR_WIDTH
			)
			PORT MAP (clk_i => clk_i,
				rst_i    => rst_i,
				freq_i   => freq_array(i),
				enable_i => enable_array(i),
				sin_o    => sin_array(i)
			);
	end generate;
	-- TODO: array mixer/counter
	voice_counter : process (clk_i)
		variable count : integer range (0 to num_osc) := 0;
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' then
				count := count + 1;
			elsif count = num_osc then
				--r_Var_Done <= '1';
				count := 0;
			--else
			--	r_Var_Done <= '0';
			end if;
		end if;
	end process;
end behavioral;
	
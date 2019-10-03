-- This module makes a frequency argument and adds it to a phase accumulator 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity osc is 
	generic (PA_WIDTH : integer := 32;-- TODO REPLACE W CONST
			ROM_DATA_WIDTH : integer :=18;-- TODO REPLACE W CONST
			ROM_ADDR_WIDTH : integer := 14);-- TODO REPLACE W CONST);
	port   (clk_i: in std_logic;
			rst_i: in std_logic;
			freq_i : in std_logic_vector (PA_WIDTH-1 downto 0);
			enable_i : in std_logic;
			sin_o : out std_logic_vector (ROM_DATA_WIDTH-1 downto 0)
			);
end osc;

architecture behavioral of osc is
	component phase_acc is 
	generic (PA_WIDTH : integer := 32); 
	port   (clk_i: in std_logic;
			rst_i: in std_logic;
			freq_i : in std_logic_vector ((PA_WIDTH-1) downto 0);
			enable_i : in std_logic;
			phase_o : out std_logic_vector ((PA_WIDTH-1) downto 0)
			);
	end component;
	signal phase_acc_o : std_logic_vector(PA_WIDTH-1 downto 0);
	signal rom_phase_i: std_logic_vector(ROM_ADDR_WIDTH-1 downto 0);
	signal roma_out, romb_out : std_logic_vector(ROM_DATA_WIDTH-1 downto 0);
	--------------------------------
	begin
	
	ph_acc1 : phase_acc 
		GENERIC MAP(PA_WIDTH => PA_WIDTH)
		PORT MAP (clk_i=>clk_i,
			rst_i => rst_i,
			freq_i => freq_i,
			enable_i => enable_i,
			phase_o => phase_acc_o
			);
--
--	phase_map : phase_rom_map
--	GENERIC MAP (PA_WIDTH => PA_WIDTH,
--				ROM_WIDTH => ROM_ADDR_WIDTH)
--	PORT MAP (clk_i=> clk_i,
--			 rst_i => rst_i, 
--			 phase_i => phase_acc_out,
--			 rom_phase_o => rom_phase_i
--		);
	-- INSTANTIATE ROM and interpolator!
	--rom : sin_rom
	--GENERIC MAP (DATA_WIDTH => ROM_DATA_WIDTH;
    --				ADDR_WIDTH => ROM_ADDR_WIDTH)
	--PORT MAP (clk_i=> clk_i,
	--		 rst_i => rst_i, 
	--		 addra => rom_phase_i,
	--		 addrb => rom_phase_i +1,
	--		 roma_o => roma_out,
	--		romb_o => romb_out
	--	);
end behavioral;
			
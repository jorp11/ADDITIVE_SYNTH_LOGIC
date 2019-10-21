-- This module makes a frequency argument and adds it to a phase accumulator 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity osc_bank is
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
end osc_bank;

architecture behavioral of osc_bank is
	type enable_array_t is array (0 to num_osc-1) of std_logic;
	--type freq_array_t is array (0 to num_osc-1) of std_logic_vector(ROM_ADDR_WIDTH-1 downto 0);
	type phase_array_t is array (0 to num_osc-1) of std_logic_vector(ROM_ADDR_WIDTH-1 downto 0);

	component phase_acc is
		generic (PA_WIDTH :    integer := 32);
		port (clk_i       : in std_logic;
			rst_i    : in  std_logic;
			freq_i   : in  std_logic_vector ((PA_WIDTH-1) downto 0);
			enable_i : in  std_logic;
			phase_o  : out std_logic_vector ((PA_WIDTH-1) downto 0)
		);
	end component;

	component sin_rom is
		generic(DATA_WIDTH : integer := ROM_DATA_WIDTH;
				ADDR_WIDTH : integer := ROM_ADDR_WIDTH
				 );
		port (clk : in std_logic;
			rst : in std_logic;
		 	addra : in std_logic_vector(ROM_ADDR_WIDTH-1 downto 0);
		 	addrb : in std_logic_vector(ROM_ADDR_WIDTH-1 downto 0);
	 		roma_o : out std_logic_vector(ROM_DATA_WIDTH-1 downto 0);
	 		romb_o : out std_logic_vector(ROM_DATA_WIDTH-1 downto 0)
	 		);
		end component;
	signal phase_array    : phase_array_t;
--	signal freq_array   : freq_array_t;
	signal enable_array : enable_array_t;
	signal phase_acc_o        : std_logic_vector(PA_WIDTH-1 downto 0);
	signal sin_out 			  : std_logic_vector(ROM_DATA_WIDTH-1 downto 0);
	signal rom_addr           : std_logic_vector(ROM_ADDR_WIDTH-1 downto 0);
	signal roma_out, romb_out,roma_out_n1 : std_logic_vector(ROM_DATA_WIDTH-1 downto 0);
	signal negate             : std_logic_vector(1 downto 0); -- used to negate rom address
                                                              --------------------------------
begin
	gen_osc : for i in 0 to NUM_OSC-1 generate
	ph_acc1 : phase_acc
		GENERIC MAP(PA_WIDTH => PA_WIDTH)
		PORT MAP (clk_i      => clk_i,
			rst_i    => rst_i,
			freq_i   => freq_i,
			enable_i => osc_en_i(i),
			phase_o  => phase_acc_o(i)
		);
		end generate;


	rom_addr_map : process (clk_i)
	begin
		if rising_edge(clk_i) then
			if enable_i = '1' then
				roma_out_n1 <= roma_out; -- TODO deal with this
				negate(0)  <= phase_acc_o(PA_WIDTH-1);
				if (phase_acc_o(PA_WIDTH-2) ='1') then
					rom_addr <= phase_acc_o (PA_WIDTH-2 downto (PA_WIDTH-ROM_ADDR_WIDTH-1));
				else
					rom_addr <= not (phase_acc_o (PA_WIDTH-2 downto (PA_WIDTH-ROM_ADDR_WIDTH-1)));
				end if;
				negate(1) <= negate(0);
				if (negate(1)= '1')then
					sin_out <= roma_out_n1;-- signed(roma_out);
				else
					sin_out <= roma_out_n1;
				end if;
			end if;
		end if;
	end process;

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
	
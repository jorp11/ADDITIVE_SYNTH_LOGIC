-- This module makes a frequency argument and adds it to a phase accumulator 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity osc_bank is
	generic (NUM_OSC : integer := 4;
			PA_WIDTH : integer := 32;   
			ROM_DATA_WIDTH : integer := 16;  
			ROM_ADDR_WIDTH : integer := 14); 
	port (clk_i : in std_logic;
		rst_i    : in  std_logic;
		freq_i   : in  unsigned (PA_WIDTH-1 downto 0);
		osc_en_i : in std_logic_vector (NUM_OSC -1 downto 0); -- ONE hot enable for oscillator bank.
		--phase_i  : in std_logic_vector (PA_WIDTH-1 downto 0);
		amp_i	 : in unsigned (ROM_DATA_WIDTH-1 downto 0);
		--osc_ind_o : out integer;
		sin_o    : out signed (ROM_DATA_WIDTH-1 downto 0)
	);
end osc_bank;

architecture behavioral of osc_bank is
	type enable_array_t is array (0 to num_osc-1) of std_logic;
	--type freq_array_t is array (0 to num_osc-1) of std_logic_vector(ROM_ADDR_WIDTH-1 downto 0);
	type phase_array_t is array (0 to num_osc-1) of unsigned(PA_WIDTH-1 downto 0);

	component phase_acc is
		generic (PA_WIDTH :    integer := 32);
		port (clk_i       : in std_logic;
			rst_i    : in  std_logic;
			freq_i   : in  unsigned ((PA_WIDTH-1) downto 0);
			enable_i : in  std_logic;
			phase_o  : out unsigned ((PA_WIDTH-1) downto 0)
		);
	end component;


	component sine_rom is
--		generic(DATA_WIDTH : integer := ROM_DATA_WIDTH;
--				ADDR_WIDTH : integer := ROM_ADDR_WIDTH
--				 );
		port (
		 	address_a : in std_logic_vector(ROM_ADDR_WIDTH-1-2 downto 0);
		 	address_b : in std_logic_vector(ROM_ADDR_WIDTH-1-2 downto 0);
			clock : in std_logic;
	 		q_a : out std_logic_vector(ROM_DATA_WIDTH-1 downto 0);
	 		q_b : out std_logic_vector(ROM_DATA_WIDTH-1 downto 0)
	 		);
		end component;
		
	signal phase_array    : phase_array_t;
--	signal freq_array   : freq_array_t;
	--signal enable_array : enable_array_t;
	signal phase_acc_o        : std_logic_vector(PA_WIDTH-1 downto 0);
	signal sin_out 		  : signed(ROM_DATA_WIDTH-1 downto 0);--std_logic_vector(ROM_DATA_WIDTH-1 downto 0);
	signal rom_addr,rom_addr_n1,rom_addr_n2           : std_logic_vector(ROM_ADDR_WIDTH-1-2 downto 0); -- take off two bits for quarter table!
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
			phase_o  => phase_array(i)
		);
		end generate;

	--phase_acc_o <= std_logic_vector(phase_array(0)(31 downto 18);
	phase_acc_o <=std_logic_vector(phase_array(0));
rom_addr_map : process (clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' then
				negate <= (others => '0');
				sin_out <= (others => '0');
				rom_addr <= (others => '0');
				rom_addr_n1 <=(others => '0');
				roma_out_n1 <= (others => '0');
				rom_addr_n2 <= (others => '0');
			else
				roma_out_n1 <= roma_out; -- TODO deal with this
rom_addr_n2 <= rom_addr_n1;
rom_addr_n1 <= rom_Addr;
				negate(0)  <= phase_acc_o(PA_WIDTH-1);
				if (phase_acc_o(PA_WIDTH-2) ='1') then
					rom_addr <= not (phase_acc_o (PA_WIDTH-3 downto (PA_WIDTH-ROM_ADDR_WIDTH)));
				else
					rom_addr <=  phase_acc_o (PA_WIDTH-3 downto (PA_WIDTH-ROM_ADDR_WIDTH));
				end if;
				negate(1) <= negate(0);
				if (negate(1)= '1')then
					--sin_out <= signed(1 & std_logic_vector(roma_out_n1)
					--sin_out <= (1 & roma_out_n1(ROM_DATA_WIDTH-1dow)) + 1;-- signed(roma_out);
				sin_out <= signed(not('0' & std_logic_vector(roma_out(ROM_DATA_WIDTH-1 downto 1))))+ 1;
				else
					sin_out <= signed('0' & std_logic_vector(roma_out(ROM_DATA_WIDTH-1 downto 1)));
				end if;
			end if;
		end if;
	end process;
	
sine_rom_inst : sine_rom PORT MAP (
		address_a	 => rom_addr,
		address_b	 => (others => '0'),
		clock	 => clk_i,
		q_a	 => roma_out,
		q_b	 => romb_out
	);
sin_o <= sin_out;
end behavioral;
	
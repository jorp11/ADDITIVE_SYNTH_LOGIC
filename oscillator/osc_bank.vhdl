-- This module makes a frequency argument and adds it to a phase accumulator 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;
entity osc_bank is
	generic (NUM_OSC : integer := 4;
			PA_WIDTH : integer := 32;   
			ROM_DATA_WIDTH : integer := 16;  
			ROM_ADDR_WIDTH : integer := 14;
			AMP_WIDTH : integer :=16); 
	port (clk_i : in std_logic;
		rst_i    : in  std_logic;
		freq_i   : in  unsigned (PA_WIDTH-1 downto 0);
		osc_en_i : in std_logic_vector (NUM_OSC -1 downto 0); -- ONE hot enable for oscillator bank.
		samp_start_i : in std_logic;
		--phase_i  : in std_logic_vector (PA_WIDTH-1 downto 0);
		amp_i	 : in unsigned (AMP_WIDTH-1 downto 0);
		--osc_ind_o : out integer;
		sin_o    : out signed (ROM_DATA_WIDTH-1 downto 0)
	);
end osc_bank;

architecture behavioral of osc_bank is
	constant OSC_BITS : integer := integer(ceil(log2(real(num_osc))));
	constant AMP_DELAY : integer := 5;
	type enable_array_t is array (0 to NUM_OSC-1) of std_logic;
	type phase_array_t is array (0 to NUM_OSC-1) of unsigned(PA_WIDTH-1 downto 0);
	type amp_reg_t is array (0 to AMP_DELAY-1) of unsigned (AMP_WIDTH-1 downto 0);
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
	signal phase_acc_o        : std_logic_vector(PA_WIDTH-1 downto 0);
	signal sin_out 		  : signed(ROM_DATA_WIDTH-1 downto 0);--std_logic_vector(ROM_DATA_WIDTH-1 downto 0);
	signal rom_addr,rom_addr_n1,rom_addr_n2,romb_addr          : std_logic_vector(ROM_ADDR_WIDTH-1-2 downto 0); -- take off two bits for quarter table!
	signal roma_out, romb_out,roma_out_n1 : std_logic_vector(ROM_DATA_WIDTH-1 downto 0);
	signal negate             : std_logic_vector(1 downto 0); -- used to negate rom address
	signal osc_en_n1,osc_en_n2 : std_logic_vector(NUM_OSC-1 downto 0);
	signal sample_acc : signed(OSC_BITS + ROM_DATA_WIDTH + 1 + AMP_WIDTH +1 -1 downto 0); -- ROM data plus sign ext plus 1 bit every log2 osc
	signal sum_out : signed(23 downto 0); -- TODO add  CONSTANT DAC_BITS
        signal rom_d_val,rom_d_val_n1,rom_d_val_n2,rom_d_val_n3 : std_logic :='0';  
signal amp_delay_r : amp_reg_t;        
signal scaled_sine : signed (35 downto 0);--(ROM_DATA_WIDTH+AMP_WIDTH downto 0);                                          --------------------------------
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

	process (clk_i)
		begin
		if rising_edge(clk_i) then
		    if rst_i ='1' then
		        phase_acc_o <= (others => '0');
		    else
		        for i in 0 to num_osc -1 loop
			    if osc_en_n1(i) = '1' then
	    		        phase_acc_o <=std_logic_vector(phase_array(i));
			    end if;
			end loop;
		    end if;
		end if;
	end process;
	amp_d_proc : process (clk_i)
		begin
		if rising_edge(clk_i) then
		    if rst_i = '1' then
			for i in 0 to amp_delay-1 loop
			    amp_delay_r(i) <= (others=>'0');
			end loop;
			else
			    amp_delay_r(0) <= amp_i;
			    for i in 1 to amp_delay-1 loop
				amp_delay_r(i) <= amp_delay_r(i-1);
			    end loop;	
		    end if; 
		end if;
	end process;	
--Deal with quarter table phase manip. 
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
				osc_en_n1 <= (others => '0');
				osc_en_n2 <= (others => '0');
				rom_d_val_n1 <= '0';
				rom_d_val_n2 <= '0';
				rom_d_val_n3 <= '0';
			else
				roma_out_n1 <= roma_out; -- TODO deal with this
				rom_addr_n2 <= rom_addr_n1;
				rom_addr_n1 <= rom_Addr;
				negate(0)  <= phase_acc_o(PA_WIDTH-1);
				negate(1) <= negate(0);
				osc_en_n1 <= osc_en_i;
				osc_en_n2 <= osc_en_n1;
				rom_d_val_n1 <= rom_d_val;
				rom_d_val_n2 <= rom_d_val_n1;
				rom_d_val_n3 <= rom_d_val_n2;

				if (phase_acc_o(PA_WIDTH-2) ='1') then
				    rom_addr <= not (phase_acc_o (PA_WIDTH-3 downto (PA_WIDTH-ROM_ADDR_WIDTH)));
				else
				    rom_addr <=  phase_acc_o (PA_WIDTH-3 downto (PA_WIDTH-ROM_ADDR_WIDTH));
				end if;

				if (negate(1)= '1')then
					--sin_out <= (1 & roma_out_n1(ROM_DATA_WIDTH-1dow)) + 1;-- signed(roma_out);
				sin_out <= signed(not('0' & std_logic_vector(roma_out(ROM_DATA_WIDTH-1 downto 1))))+ 1;
				else
					sin_out <= signed('0' & std_logic_vector(roma_out(ROM_DATA_WIDTH-1 downto 1)));
				end if;
			end if;
		end if;
	end process;

rom_d_val <= '0' when osc_en_n2=(osc_en_n2'range=>'0') else '1';
romb_addr <= std_logic_vector(unsigned(rom_addr)+1);
sine_rom_inst : sine_rom PORT MAP (
		address_a	 => rom_addr,
		address_b	 => romb_addr,
		clock	 => clk_i,
		q_a	 => roma_out,
		q_b	 => romb_out
	);

	sin_o <= sin_out;

	process (clk_i)
	begin
	if rising_edge(clk_i) then
	    if rst_i = '1' then
		sample_acc <= (others => '0');
	    elsif samp_start_i = '1' then
		sample_acc <= (others => '0');
	    else
		if rom_d_val_n3= '1' then
		--sample_acc <= sample_acc + scaled_sine(scaled_sine'left downto 8); --with mult
		sample_acc <= sample_acc + scaled_sine;
--sample_Acc <= sample_acc + sin_out;
		end if;
	    end if;
	end if;	
	end process;
	-- sign extend unsigned 8 bit amplitude to 9 and convert to "signed"00"));
	scaled_sine <= signed('0' & std_logic_vector(amp_delay_r(4) & '0' ))*signed(sin_out& "00");
	process (clk_i)
	begin
	if rising_edge(clk_i) then
		if rst_i = '1' then
			sum_out <= (others =>'0');
		elsif samp_start_i = '1' then
			sum_out <= sample_acc(sample_acc'left downto sample_acc'left - 23);
		end if;
	end if;
	end process;
end behavioral;
	
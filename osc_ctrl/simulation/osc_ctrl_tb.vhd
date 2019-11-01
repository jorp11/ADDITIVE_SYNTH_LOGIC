-- osc_tb.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE ieee.math_real.log2;
USE ieee.math_real.ceil;

entity osc_ctrl_tb is
end osc_ctrl_tb;

architecture behaviour of osc_ctrl_tb is
	constant clock_period : time := 10 ns; -- assume 100Mhz clock
	constant NUM_OSC : integer :=128;
	constant PA_WIDTH :integer := 32;
	constant ROM_DATA_WIDTH :integer := 16;
	constant ROM_ADDR_WIDTH :integer := 14;
	constant AMP_WIDTH : integer :=16;

component osc_ctrl is
	generic (NUM_OSC : integer := 4;
			PA_WIDTH : integer := 32;
			ROM_DATA_WIDTH :integer :=16;	
		   ROM_ADDR_WIDTH :integer := 14;		
			AMP_WIDTH : integer :=16); 
	port (clk_i : in std_logic;
		rst_i    : in  std_logic;
		samp_start_i : in std_logic;
		num_osc_i   : in integer range 0 to 512; -- todo 512 as constant MAX osc number
		freq_i		: in unsigned(PA_WIDTH-1 downto 0);
		stretch_i 	:in integer range 0 to 1023;
		slope_i		:in signed(AMP_WIDTH-1 downto 0);
		even_gain_i 	: in unsigned(AMP_WIDTH-1 downto 0);
		odd_gain_i	: in unsigned(AMP_WIDTH-1 downto 0);
		osc_freq_o   : out  unsigned (PA_WIDTH-1 downto 0); -- phase_acc keyword 
		osc_en_o : out std_logic_vector (NUM_OSC -1 downto 0); -- ONE hot enable for oscillator bank.
		--phase_offset_o  : out std_logic_vector (PA_WIDTH-2 downto 0);
		amp_o	 : out unsigned (AMP_WIDTH-1 downto 0)
	);
end component;
	component osc_bank is 
	generic (NUM_OSC : integer := 4;
			PA_WIDTH : integer := 32;   
			ROM_DATA_WIDTH : integer := 16;  
			ROM_ADDR_WIDTH : integer := 14;
			AMP_WIDTH : integer :=18); 
	port (clk_i : in std_logic;
		rst_i    : in  std_logic;
		freq_i   : in  unsigned (PA_WIDTH-1 downto 0);
		osc_en_i : in std_logic_vector (NUM_OSC -1 downto 0); -- ONE hot enable for oscillator bank.
		samp_start_i : in std_logic;
		--phase_i  : in std_logic_vector (PA_WIDTH-1 downto 0);
		amp_i	 : in unsigned (AMP_WIDTH-1 downto 0);
		--osc_ind_o : out integer;
		sum_o    : out signed (ROM_DATA_WIDTH-1 downto 0)
	);
	end component;
	
	signal rst,clk : std_logic := '0';
	signal samp_start : std_logic :='0';
	signal freq: unsigned (PA_WIDTH-1 downto 0);
	signal amp :unsigned(AMP_WIDTH-1 downto 0);
	signal stretch : integer range 0 to 1023 := 0;
 	signal slope : signed(AMP_WIDTH-1 downto 0) := (others=>'0');
	
	signal osc_en : std_logic_vector (NUM_OSC -1 downto 0);
	signal osc_freq : unsigned (PA_WIDTH-1 downto 0);
	signal sum_out : signed (23 downto 0);
	signal even_gain, odd_gain : unsigned(AMP_WIDTH-1 downto 0);
	-------
	begin 
	DUT: osc_ctrl
	generic map(NUM_OSC => NUM_OSC,
			PA_WIDTH => PA_WIDTH,-- TODO REPLACE W CONST
			ROM_DATA_WIDTH => ROM_DATA_WIDTH,-- TODO REPLACE W CONST
			ROM_ADDR_WIDTH => ROM_ADDR_WIDTH,-- TODO REPLACE W CONST);
			AMP_WIDTH =>AMP_WIDTH)
	port map (clk_i => clk,
			rst_i => rst,
			samp_start_i => samp_start,
			num_osc_i => num_osc,
			freq_i => freq,
			stretch_i => stretch,
			slope_i => slope,
even_gain_i => even_gain,
odd_gain_i  => odd_gain,
			osc_freq_o=> osc_freq,
			osc_en_o => osc_en,
			amp_o => amp
			);
osc_bank_inst: osc_bank
	generic map(NUM_OSC => NUM_OSC,
			PA_WIDTH => PA_WIDTH,-- TODO REPLACE W CONST
			ROM_DATA_WIDTH => ROM_DATA_WIDTH,-- TODO REPLACE W CONST
			ROM_ADDR_WIDTH => ROM_ADDR_WIDTH,-- TODO REPLACE W CONST);
			AMP_WIDTH =>AMP_WIDTH)
	port map (clk_i => clk,
			rst_i => rst,
			freq_i => osc_freq,
			osc_en_i => osc_en,
			samp_start_i => samp_start,
			amp_i => amp,
			sum_o  => sum_out
			);
	clock_process :process
	begin
	clk <= '0';
	wait for clock_period/2;
	clk <= '1';
	wait for clock_period/2;
	end process;


	
	freq_process : process
	begin
	    wait until rst = '0';
	    	freq <= to_unsigned(0,PA_WIDTH);
	  	even_gain <= to_unsigned(2**AMP_WIDTH-1,AMP_WIDTH);
		odd_gain <= to_unsigned(0,AMP_WIDTH);
	    	stretch <= 0;
	    	slope <= to_signed(-1000,slope'left+1);

--	    enable <= (others => '0');
      	    wait until clk = '1' and samp_start = '1';
 	        freq <= to_unsigned(262144*8,PA_WIDTH);
--	    for i in 1 to 20 loop
-- 		slope <= to_signed(-1000+100*i,slope'left+1);
--	        wait until clk = '1' and clk'event and samp_start = '1';
--    	    end loop;
		
	end process;
	simulation_process : process
        begin
            rst <= '1';
            wait for 100 ns;   
    	    rst <= '0';
            --wait for 10000 ns;   
    	    --rst <= '1';
     --       wait for 4000 ns; 
    --	    rst <= '0';
	    wait for 2 ms;
            assert false
    	report "simulation over"
	severity failure;
        end process;

	samp_process :process (clk)
	variable count :integer range 0 to NUM_OSC+4 :=0;
	begin
	if rising_edge(clk) then
	    if rst = '1' then
	        count := 0;
	        samp_start <= '0';
	
	    else
		if count = num_osc+4 then	
    	    	    samp_start <= '1';
		    count :=0;

		else
    		    count := count + 1;
		    samp_start <= '0';
		end if;
	    end if;
		
	end if;
	end process;	

	
end architecture behaviour;
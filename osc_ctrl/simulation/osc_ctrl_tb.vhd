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
	constant NUM_OSC : integer := 32;
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
		slope_i		:in integer range 0 to 1023;
		osc_freq_o   : out  unsigned (PA_WIDTH-1 downto 0); -- phase_acc keyword 
		osc_en_o : out std_logic_vector (NUM_OSC -1 downto 0); -- ONE hot enable for oscillator bank.
		--phase_offset_o  : out std_logic_vector (PA_WIDTH-2 downto 0);
		amp_o	 : out unsigned (AMP_WIDTH-1 downto 0)
	);
end component;


	signal rst,clk : std_logic := '0';
	signal samp_start : std_logic :='0';
	signal freq: unsigned (PA_WIDTH-1 downto 0);
	signal amp :unsigned(AMP_WIDTH-1 downto 0);
	signal stretch : integer range 0 to 1023 := 0;
 	signal slope : integer range 0 to 1023 := 0;
	
	signal osc_en : std_logic_vector (NUM_OSC -1 downto 0);
	signal osc_freq : unsigned (PA_WIDTH-1 downto 0);
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
			osc_freq_o=> osc_freq,
			osc_en_o => osc_en,
			amp_o => amp
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
--		
	    freq <= to_unsigned(262144*16,PA_WIDTH);
	    amp <= (others => '0');
	    stretch <= 0;
	    slope <= 0;
--	    enable <= (others => '0');
      	    wait until clk = '1' and samp_start = '1';
--                wait until clk = '1' and clk'event;
--	    freq <= to_unsigned(262144*16,PA_WIDTH);
--	    amp   <= x"FFFF";
--	    enable <= (0 => '1', others => '0');
--            wait until clk = '1' and clk'event;
--	    for i in 2 to num_osc loop
--		freq <= to_unsigned(262144*16*i,PA_WIDTH);
--  		--freq <= to_unsigned(262144*32,PA_WIDTH);
--	    	if (integer(i) mod 2)= 0 then
--		    amp <= (others =>'0');
--		else
--		    amp <= to_unsigned(65535/i,AMP_WIDTH);
--		end if;
--		--amp <= x"ff";
--		-- Leftshift enable w/ wrap around
--		enable <= enable(num_osc-2 downto 0) & enable(num_osc-1); 
--                wait until clk = '1' and clk'event;

	end process;
	simulation_process : process
        begin
            rst <= '1';
            wait for 100 ns;   
    	    rst <= '0';
            wait for 10000 ns;   
    	    rst <= '1';
            wait for 4000 ns; 
    	    rst <= '0';
	    wait for 1000000 ns;
            assert false
    	report "simulation over"
	severity failure;
        end process;

	samp_process :process (clk)
variable count :integer range 0 to 64 :=0;
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
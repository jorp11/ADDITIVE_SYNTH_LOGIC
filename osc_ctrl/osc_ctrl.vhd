-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity osc_ctrl is
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
		stretch_i 	: in integer range 0 to 1023;
		slope_i		: in integer range 0 to 1023;
		osc_freq_o   : out  unsigned (PA_WIDTH-1 downto 0); -- phase_acc keyword 
		osc_en_o : out std_logic_vector (NUM_OSC -1 downto 0); -- ONE hot enable for oscillator bank.
		--phase_offset_o  : out std_logic_vector (PA_WIDTH-2 downto 0);
		amp_o	 : out unsigned (AMP_WIDTH-1 downto 0)
	);
end osc_ctrl;

architecture behavioral of osc_ctrl is
constant MAX_FREQ : unsigned (PA_WIDTH-1 downto 0) := (PA_WIDTH-1 => '1', others =>'0');
--RAM
-- OSC BANK
	signal osc_freq,osc_freq_n   : unsigned(PA_WIDTH-1 downto 0);--integer range 0 to 2**(PA_WIDTH-1)-1;-- std_logic_vector(PA_WIDTH-1 downto 0); 
	signal fund_freq : unsigned(PA_WIDTH-1 downto 0);-- range 0 to 2**(PA_WIDTH-1)-1;
	signal stretch : integer range 0 to 1023;
	signal slope : integer range 0 to 1023;
		
	signal osc_en : std_logic_vector (NUM_OSC-1 downto 0);
	signal freq : unsigned(PA_WIDTH-1 downto 0);

	signal amp :unsigned(AMP_WIDTH-1 downto 0);
	signal sin_o : signed(ROM_DATA_WIDTH-1 downto 0); 
	signal samp_start: std_logic;
	signal sample_count : integer :=0;
	------------------------------------

begin
	--sample input freq once per sample - could make this slower
	main: process (clk_i)
	variable count : integer range 0 to 2048:=0;
	begin
	if rising_edge(clk_i) then
		if rst_i = '1'then
			fund_freq <= (others=>'0');
			stretch <= 0;
			slope <= 0;
			count := 0;
			osc_en <= (others =>'0');
			osc_freq <= (others => '0');
			amp <=(others => '0');
		else
			if samp_start_i = '1'then
			   count := 0;
			   fund_freq <= freq_i;
			   osc_freq <= freq_i;
			   osc_freq_n <= freq_i(freq_i'left downto 1) & '0';
			   stretch <= stretch_i;
			   slope <= slope_i;
			    osc_en <= (0 => '1', others =>'0');
			else
			    osc_freq_n <= osc_freq+fund_freq; --TODO multiply by stretch/compress
			    if (osc_freq_n > MAX_FREQ) then
				amp <= (others=>'0'); 
			    else
				amp <= 
			    end if;
			osc_freq <= osc_freq_n;	
			osc_en <= osc_en(NUM_OSC-2 downto 0) & osc_en(NUM_OSC-1);
		   	end if;
			
			if count = NUM_OSC then
				count := NUM_OSC;
			else
			count := count+1;
			end if;
		end if;
		end if;
	end process;
	amp_o <= amp;
	osc_en_o <= osc_en;
	osc_freq_o <= osc_freq;
end behavioral;
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
		slope_i		:in signed(AMP_WIDTH-1 downto 0);
		even_gain_i 	: in unsigned(AMP_WIDTH-1 downto 0);
		odd_gain_i	: in unsigned(AMP_WIDTH-1 downto 0);
		osc_freq_o   : out  unsigned (PA_WIDTH-1 downto 0); -- phase_acc keyword 
		osc_en_o : out std_logic_vector (NUM_OSC -1 downto 0); -- ONE hot enable for oscillator bank.
		--phase_offset_o  : out std_logic_vector (PA_WIDTH-2 downto 0);
		amp_o	 : out unsigned (AMP_WIDTH-1 downto 0)
	);
end osc_ctrl;

architecture behavioral of osc_ctrl is
constant MAX_FREQ : unsigned (PA_WIDTH-1 downto 0) := to_unsigned(2**(PA_WIDTH-1),PA_WIDTH);--(PA_WIDTH-1 => '1', others =>'0');
constant LFO_RATE : signed (AMP_WIDTH-1 downto 0) := to_signed(2**(AMP_WIDTH-3)-1,AMP_WIDTH);
constant LFO_WIDTH : integer := AMP_WIDTH;
constant LFO_DEPTH : signed (AMP_WIDTH-1 downto 0) := (others=>'0');--to_signed(2**(AMP_WIDTH-1),AMP_WIDTH);

-- OSC BANK
	signal osc_freq,osc_freq_n   : unsigned(PA_WIDTH-1 downto 0);--integer range 0 to 2**(PA_WIDTH-1)-1;-- std_logic_vector(PA_WIDTH-1 downto 0); 
	signal fund_freq : unsigned(PA_WIDTH-1 downto 0);-- range 0 to 2**(PA_WIDTH-1)-1;
	signal stretch : integer range 0 to 1023;
	signal slope : signed(AMP_WIDTH-1 downto 0);
		
	signal osc_en : std_logic_vector (NUM_OSC-1 downto 0);
	signal freq : unsigned(PA_WIDTH-1 downto 0);

	signal amp :unsigned(AMP_WIDTH-1 downto 0);
 	signal odd_scaled,even_scaled : signed(35 downto 0);
	signal amp_slope,amp_n : signed (AMP_WIDTH-1+1 downto 0);
	signal sin_o : signed(ROM_DATA_WIDTH-1 downto 0); 
	signal samp_start: std_logic;
	signal sample_count : integer :=0;
	------------------------------------
	signal lfo,lfo_saw,lfo_tri,lfo_sq : signed (AMP_width-1 downto 0);
	signal lfo_scale : signed (35 downto 0);
begin
	--sample input freq once per sample - could make this slower
	main: process (clk_i)
	variable count : integer range 0 to 2048:=0;
	begin
	if rising_edge(clk_i) then
		if rst_i = '1'then
			fund_freq <= (others=>'0');
			stretch <= 0;
			slope <=  (others =>'0');
			count := 0;
			osc_en <= (others =>'0');
			osc_freq <= (others => '0');
			osc_freq_n <= (others=> '0');
			amp <=(others => '0');
			amp_n <=(others => '0');
			amp_slope <=(others => '0');
		else
			if samp_start_i = '1'then
	 		    count := 0;
		 	    fund_freq <= freq_i;
			    osc_freq <= freq_i;
			    osc_freq_n <= freq_i(freq_i'left-1 downto 0) & '0';
			    stretch <= stretch_i;
			    slope <= slope_i;
			    osc_en <= std_logic_vector(to_unsigned(1,NUM_OSC));
			    amp <= to_unsigned(2**(AMP_WIDTH-1),AMP_WIDTH);
			    amp_slope <= to_signed(2**(AMP_WIDTH-1),AMP_WIDTH+1) + slope_i;
			    amp_n <=to_signed(2**(AMP_WIDTH-1),AMP_WIDTH+1) + slope_i;
			else
			    osc_freq_n <= osc_freq_n+fund_freq; --TODO multiply by stretch/compress
			    osc_freq <= osc_freq_n;	
			    osc_en <= osc_en(NUM_OSC-2 downto 0) & '0';
			    amp_slope <= amp_slope + slope_i;
			    amp_n <= amp_slope+lfo;

			    if (osc_freq_n > MAX_FREQ) or count = NUM_OSC then
				amp <= (others=>'0'); 
			    elsif amp_n <0 then
			    	amp <= (others=>'0');
			    else 
				if count mod 2 = 0 then
				    amp <= unsigned(odd_scaled(19 downto 4));
   				    --amp <=unsigned(std_logic_vector(amp_n(amp_n'left-1 downto 0)));
				else			
				    --amp <=unsigned(std_logic_vector(amp_n(amp_n'left-1 downto 0)));
				  amp <= unsigned(even_scaled(19 downto 4));
				end if;
				--amp <=unsigned(std_logic_vector(amp_n(amp_n'left-1 downto 0)));
			    end if;

		   	end if;
			if count = NUM_OSC then
			    count := NUM_OSC;
			else
			    count := count+1;
			end if;
		end if;
		end if;
	end process;
        odd_scaled <=(amp_n(AMP_WIDTH-1 downto 0) & "00") * signed(odd_gain_i & "00"); 
        even_scaled <=(amp_n(AMP_WIDTH-1 downto 0) & "00") * signed(even_gain_i & "00"); 
	amp_o <= amp;
	osc_en_o <= osc_en;
	osc_freq_o <= osc_freq;

	process (clk_i)
	begin
	if rising_edge(clk_i) then
		if rst_i = '1' then
		    lfo_tri <= (others =>'0');
		else
		    if samp_start_i = '1' then
		        lfo_tri <=LFO_RATE;
		    else
			if lfo_saw < 2**(AMP_WIDTH-2) then
		    	    lfo_tri<= lfo_saw +LFO_RATE;
		        else
			    lfo_tri <=2**(AMP_WIDTH-1) - lfo_saw+LFO_RATE;
			end if;
		    end if;	
		end if;
	end if;
	end process;

	process (clk_i)
	begin
	if rising_edge(clk_i) then
		if rst_i = '1' then
		    lfo_saw <= (others =>'0');
		else
		    if samp_start_i = '1' then
			lfo_saw <=LFO_RATE;
		    else
		        lfo_saw <= (lfo_saw +LFO_RATE); 	
		    end if;	
		end if;
	end if;
	end process;

	process (clk_i)
	begin
	if rising_edge(clk_i) then
		if rst_i = '1' then
		    lfo_sq <= (others =>'0');
		else
		    if samp_start_i = '1' then
			lfo_sq <= to_signed(2**(LFO_WIDTH-1),LFO_WIDTH);
		    else
			if lfo_saw(LFO_WIDTH-1) = '0' then
		        lfo_sq <= to_signed(2**(LFO_WIDTH-1)-1,LFO_WIDTH);
			else
			    lfo_sq <=to_signed(-2**(LFO_WIDTH-1),LFO_WIDTH);
			end if;
		    end if;	
		end if;
	end if;
	end process;

	lfo_scale <=(lfo_tri & b"00" )*(lfo_depth & b"00");
	lfo<=lfo_scale (35 downto 20);
end behavioral;
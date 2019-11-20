library  ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;
library work;
use work.constants_pkg.all; -- TODO rename this
use work.type_pkg.all;

entity additive_synth is 
	port (clk_i: in std_logic; -- 50 MHZ clock in
			rst_i: in std_logic; -- Rest in - N/C
			--SW: in std_logic_vector (3 downto 0);
			KEY: in std_logic_vector (1 downto 0);
			LED: out std_logic_vector (7 downto 0);
			codec_1_mclk_o : out std_logic;
			codec_1_bclk_o : out std_logic;
			codec_1_ws_o : out std_logic;
			codec_1_rx_i : in std_logic;
			codec_1_tx_o: out std_logic;
			codec_1_rst_o : out std_logic;
			ADC_SDAT : in std_logic;
			ADC_SADDR : out std_logic;
			ADC_CS_N : out std_logic;
			ADC_SCLK : out std_logic
			
		--	codec_2_mclk_o : out std_logic;
		--	codec_2_bclk_o : out std_logic;
		--	codec_2_ws_o : out std_logic;
		--	codec_2_rx_i : in std_logic;
		--	codec_2_tx_o: out std_logic;
		--	codec_2_rst_o : out std_logic
			);
	-- TODO ADD SPI/I2C/I2S interfaces
end additive_synth;

architecture behavioral of additive_synth is

	component  audio_clk_v is 
	port(clk_i : in std_logic; 
        rst_i : in std_logic;
         mclk_o : out std_logic;
        bclk_o :out std_logic;
        lrclk_o : out std_logic;
        codec_rst_o : out std_logic;
        sampstart_o : out std_logic;
		  framestart_o : out std_logic);
	end component;	  
	
	component i2s_tx_v is
	port(
	clk_i : in std_logic;
	rst_i : in std_logic;
	bclk_i : in std_logic;
	lrclk_i : in std_logic;
	sampstart_i : in std_logic;
	audio_l_i : in std_logic_vector(23 downto 0);
	audio_r_i : in std_logic_Vector(23 downto 0);
	tx_o : out std_logic
	);	 
end component;

	component i2s_rx_v is
	port(
	clk_i : in std_logic;
	rst_i : in std_logic;
	bclk_i : in std_logic;
	lrclk_i : in std_logic;
	sampstart_i : in std_logic;
	audio_l_o : out std_logic_vector(23 downto 0);
	audio_r_o : out std_logic_Vector(23 downto 0);
	tx_i : in std_logic
	);	
end component;

----- SIGNALS --------
	signal clk_98 : std_logic :='0';
	signal rst: std_logic := '1';
	signal pll_lock: std_logic:='0';
	signal osc_out: std_logic_vector(ROM_DATA_WIDTH-1 downto 0);
	signal mclk, bclk,lr_ws, samp_start, frame_start: std_logic:='0';
	signal audio_l, audio_r : std_logic_vector (OUT_BIT_DEPTH-1 downto 0);
	signal codec_nrst : std_logic :='0';

	signal freq: unsigned (PA_WIDTH-1 downto 0) := (others=>'0'); 
	signal amp :unsigned(AMP_WIDTH-1 downto 0) := (others=>'0');
	signal stretch : unsigned(17 downto 0); -- todo constant
 	signal slope : signed(AMP_WIDTH-2 downto 0) := (others=>'0');
	
	signal osc_en : std_logic_vector (NUM_OSC -1 downto 0);
	signal osc_freq : unsigned (PA_WIDTH-1 downto 0);
	signal cutoff   : integer range 0 to NUM_OSC-1 :=0;
	signal sum_out : signed (23 downto 0);
	signal even_gain, odd_gain : unsigned(AMP_WIDTH-1 downto 0):=(others=>'1');
	signal lfo_rate : unsigned( AMP_WIDTH-1 downto 0) :=(0=>'1',others=>'0');
	signal lfo_shape : lfo_shape_t := SQUARE;
	signal sine_48 : signed(15 downto 0);
	
	signal emphasis : signed (AMP_WIDTH-2 downto 0) := (others=>'0');
	signal emp_width : integer range 0 to NUM_OSC/2 := 0;
	
	---ADC signals
	
		signal adc_addr : std_logic_vector (2 downto 0) := (others=>'0'); -- TODO : modify for all 8 adcs
		signal adc_data :std_logic_vector  (11 downto 0);
		signal adc_din : std_logic;
		signal adc_dout : std_logic;
	
	--------------------------------
	begin
	--- INSTANTIATIONS
		rst98Mhz :  reset_sync 
		port map (clk_i => clk_98,
				async_rst_i => not(KEY(0)) or not(pll_lock),
				sync_rst_o => rst
				);
	--------------------------------	
		PLL_inst: pll PORT MAP (
			areset => not(KEY(0)),
			inclk0 => clk_i,
			c0 => clk_98,
			locked => pll_lock
			);
	--------------------------------	
--
--		audio_clock : audio_clk
--		generic map(MCLK_DIVRATIO => 8,  -- 98.3MHZ/8 = 12.28 MHz Mclk (48Khz*256)
--			  LRCLK_DIVRATIO    => 2048, -- 98.3Mhz/2048 = 48khz
--			  BITCLK_DIVRATIO => 32)  -- 98.3 MHz/32 = 3.072Mhz
--		port map(clk_i 	=> clk_98,
--        rst_i        => rst,
--        mclk_o       => mclk,
--        bclk_o       => bclk,
--        lrclk_o      => lr_ws,
--        codec_nrst_o  => codec_nrst,
--        samp_start_o  => samp_start
--    );
	 
	 audio_clock_v : audio_clk_v
	 port map (clk_i 	=> clk_98,
        rst_i        => rst,
        mclk_o       => mclk,
        bclk_o       => bclk,
        lrclk_o      => lr_ws,
        codec_rst_o  => codec_nrst,
        sampstart_o  => samp_start,
		  framestart_o => frame_start
    );
	 
	 
	 
		codec_1_bclk_o <= bclk;
	--	codec_2_bclk_o <= bclk;
		codec_1_ws_o <= lr_ws;
		codec_1_mclk_o <= mclk;
	--	codec_2_mclk_o <= mclk;
			
--		--------------------------------
--		i2s_tx_inst : i2s_tx
--		generic map(BITDEPTH => OUT_BIT_DEPTH )
--		port map(clk_i    => clk_98,
--        rst_i       	=> rst,
--        bclk_i      	=> bclk, -- Bit clock
--        lr_ws_i     	=> lr_ws,  -- Word select /LR clk
--        sampstart_i 	=> samp_start,
--        audio_l_i    => std_logic_vector(sum_out),
--        audio_r_i    => std_logic_vector(sum_out),
--        tx_o         => codec_1_tx_o
--		  );
--		 		i2s_rx_inst : i2s_rx
--		generic map(BITDEPTH => OUT_BIT_DEPTH )
--		port map(clk_i    => clk_98,
--        rst_i       	=> rst,
--        bclk_i      	=> bclk, -- Bit clock
--        lr_ws_i     	=> lr_ws,  -- Word select /LR clk
--        sampstart_i 	=> samp_start,
--        audio_l_o    => audio_l,
--        audio_r_o    => audio_r,
--        rx_i         => codec_1_rx_i
--		  ); 
--		  

		i2s_tx_inst : i2s_tx_v
		port map(clk_i    => clk_98,
        rst_i       	=> rst,
        bclk_i      	=> bclk, -- Bit clock
        lrclk_i     	=> lr_ws,  -- Word select /LR clk
        sampstart_i 	=> samp_start,
        audio_l_i    => std_logic_vector(sum_out),
        audio_r_i    => std_logic_vector(sum_out),
        tx_o         => codec_1_tx_o
		  );

		i2s_rx_inst : i2s_rx_v

		port map(clk_i    => clk_98,
        rst_i       	=> rst,
        bclk_i      	=> bclk, -- Bit clock
        lrclk_i      	=> lr_ws,  -- Word select /LR clk
        sampstart_i 	=> samp_start,
        audio_l_o    => audio_l,
        audio_r_o    => audio_r,
        tx_i         => codec_1_rx_i
		  );
		  

	--------------------------------	
		osc_ctrl_inst :osc_ctrl
		generic map(NUM_OSC => NUM_OSC,
						PA_WIDTH => PA_WIDTH,-- TODO REPLACE W CONST
						ROM_DATA_WIDTH => ROM_DATA_WIDTH,-- TODO REPLACE W CONST
						ROM_ADDR_WIDTH => ROM_ADDR_WIDTH,-- TODO REPLACE W CONST);
						AMP_WIDTH =>AMP_WIDTH)
		port map (clk_i => clk_98,
					rst_i => rst,
					samp_start_i => samp_start,
					num_osc_i => num_osc,
					freq_i => freq,
					stretch_i => stretch,
					cutoff_i =>cutoff,
					slope_i => slope,
					emphasis_i => emphasis,
					emp_width_i =>emp_width,
					lfo_rate_i => lfo_rate,
					lfo_shape_i => lfo_shape,
					even_gain_i => even_gain,
					odd_gain_i  => odd_gain,
					osc_freq_o=> osc_freq,
					osc_en_o => osc_en,
					amp_o => amp
					);
	--------------------------------	
	osc_bank_inst: osc_bank
	generic map(NUM_OSC => NUM_OSC,
					PA_WIDTH => PA_WIDTH,
					ROM_DATA_WIDTH => ROM_DATA_WIDTH,
					ROM_ADDR_WIDTH => ROM_ADDR_WIDTH,
					AMP_WIDTH =>AMP_WIDTH)
	port map (clk_i => clk_98,
					rst_i => rst,
					freq_i => osc_freq,
					osc_en_i => osc_en,
					samp_start_i => samp_start,
					amp_i => amp,
					sum_o  => sum_out
					);
		
--		
--	adc_interface_inst : adc_interface 
--		port map (addr => adc_addr, -- 00 for now
--					data => adc_data,
--					sclk => bclk,
--					rst => rst, -- TODO retime reset to bclk domain.
--					din => adc_SDAT,
--					dout => adc_SADDR
--					);
  adc_sclk <= bclk;
	adc_cs_n <= (rst);
	
	adc_inst : adc
	port map (adc_addr_o => adc_addr,
			adc_data_o => adc_data,
			sclk_i => bclk,
			rst_i  => rst,
			din_i  => adc_SDAT,
			dout_o => adc_SADDR);		
	
	
  --------------------------------
--  process(clk_98)
--  variable max : unsigned (23 downto 0) :=(others=>'0');
--  variable abs_val : unsigned (23 downto 0) := (others=>'0');
--  variable gain : unsigned (17 downto 0):=  (others=>'0');
--  begin
--	if rising_edge(clk_98) then
--		if rst ='1' then
--			max := (others=>'0');
--			abs_val := (others=>'0');
--		else
--			abs_val := unsigned(abs(sum_out));
--			if abs_val >max then
--				max := abs_val;
--			end if;
--			if max < (2**23-2) then
--				gain := gain +1;
--			end if;
--		end if;
--	end if;
--  end process;
  
		process (KEY)
			begin
				LED(0) <= not(KEY(0));
		end process;
	--------------------------------
	LED(1) <= pll_lock;
	LED(7 downto 2) <= (others=>'0');
	
	codec_1_rst_o <= codec_nrst;
	--codec_2_rst_o <= codec_nrst;
	
	--TODO REPLACE this process with SPI/I2S reciever
	
	process(clk_98)
	variable count : integer range 0 to NUM_OSC*8-1 :=0;
	variable dir : integer :=1 ;
	begin
	if rising_edge(clk_98) then
		if rst = '1' then
		count :=0;
		dir :=1;
			freq <= (others=>'0');
			slope <= to_signed(-1000,slope'left+1) ;
			stretch <= (others=>'0');
			even_gain <= (others=>'0');
			odd_gain <= (others=>'0');
			lfo_shape <= TRI;
			lfo_rate <= (others=>'0');
			freq <= to_unsigned(0,PA_WIDTH); --
			else
			    if frame_start = '1' then
					freq <= to_unsigned(14396,PA_WIDTH); --

					--even_gain <= to_unsigned(2**AMP_WIDTH-1,AMP_WIDTH);
					even_gain <= even_gain + to_unsigned(30,even_gain'left+1) ;
					--odd_gain <= to_unsigned(2**AMP_WIDTH-1,AMP_WIDTH);
					odd_gain <= odd_gain - to_unsigned(30,odd_gain'left+1) ;
					stretch <= (others=>'0');
					stretch <= stretch + to_unsigned(1,stretch'left +1);
					slope <= to_signed(-5000,slope'left+1);
					--slope <= slope + to_signed(10,slope'left+1) ;
					lfo_rate <= to_unsigned(0,lfo_rate'left +1);
					cutoff <= count/8;
					count := count+dir;
					if count = NUM_OSC*8-1 then
						dir := -1;
						
					elsif count = 0 then
						dir := 1;
					end if;

				end if;
		end if;
	end if;
	
	end process;

	end behavioral;
			
			
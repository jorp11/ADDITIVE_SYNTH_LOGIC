--
-- ADC serial driver - i2s output (stereo)
--
-- Written by: Josh Rohs
-- Copyright 2019: 
--
--  - clk_i         - system clock input    - rising edge
--  - rst_i         - system reset input    - active high
--  - sclk_i        - bit clock input       - 64x samplerate
--  - lrclk_i       - L/R clock input       - left/right sample select
--  - sampstart_i   - sample strobe input   - start of a sample
--  - audio_l_i     - left channel input    - left channel data 24 bits signed
--  - audio_r_i     - right channel input   - right channel data 24 bits signed
--  - tx_o          - serial i2s output     - TX data out
--
-- Signal amplitudes / limits:
--  - all signals are 24 bit signed
--  - max level is 0x7fffff (23 bits on)


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity adc_driver is
	port ( clk_i : in std_logic;
			rst_i : in std_logic;
			rd_strobe_i : in std_logic; -- strobe
			sclk_i : in std_logic;
			cs_n_o : out std_logic;
			adc_sdin_o : out std_logic;
			adc_sdout_i : in std_logic;
			adc_dout_o : out unsigned(11 downto 0); --ADC data
			adc_addr_o : out unsigned(2 downto 0);
			adc_dval_o : out std_logic
			);  -- ADC index

--			
--    port (clk_i       : in std_logic;
--        rst_i       : in  std_logic;
--        sclk_i      : in  std_logic; -- Bit clock
--        lr_ws_i     : in  std_logic; -- Word select /LR clk
--        sampstart_i : in  std_logic;
--        audio_l_o   : out  std_logic_vector (BITDEPTH-1 downto 0);
--        audio_r_o   : out  std_logic_vector (BITDEPTH-1 downto 0);
--        rx_i        : in std_logic);	
			
end adc_driver;
		


architecture behavioral of adc_driver is


    signal rx_bit0,rx_bit1  : std_logic;
    signal sclk_n1, sclk_n2,sclk_falling,sclk_rising : std_logic;


	 signal adc_dout : unsigned (11 downto 0);
	 signal adc_addr : unsigned(2 downto 0) := (others=>'0');
	 signal adc_sdin : std_logic;
	 signal adc_dval : std_logic;
		type adc_ctrl_state_t is (IDLE,CS_SEL,ADDR_TX,DATA_RX);
		signal adc_ctrl_state : adc_ctrl_state_t;
--------------------------------
		signal sclk_count : integer range 0 to 15:=0;
begin
    -- wires
	 
	 adc_dout_o <= adc_dout;
	adc_addr_o <= adc_addr;
	adc_sdin_o<= adc_sdin;
	adc_dval_o <= adc_dval;
    -- shift register control
	 
	 process (clk_i)
	 begin
	 if rising_edge(clk_i) then
		if (rst_i='1') then
			adc_dout <= (others=>'0');
			adc_ctrl_state <=IDLE;		
			cs_n_o <= '1';
		else 
			adc_dval <='0';
			case adc_ctrl_state is
			when IDLE =>
				adc_dout <= (others=>'0');
				if rd_strobe_i ='1'then
					adc_ctrl_state <= CS_SEL;
					cs_n_o <= '0';
					adc_addr <= (others=>'0');
					else
					cs_n_o <= '1';
				end if;
			when CS_SEL =>
				if sclk_falling = '1' then
					adc_ctrl_state <=ADDR_TX;
					sclk_count <= 1;
				end if;

			when ADDR_TX =>
				adc_dout <= (others=>'0');

		  	  -- adc_sdin <= '0';
				if sclk_falling = '1' then
					case sclk_count is
						when 1 => adc_sdin <= adc_addr(2);
						when 2 => adc_sdin <= adc_addr(1);
						when 3 => adc_sdin <= adc_addr(0);
						when others => adc_sdin <= '0';
					end case;

					sclk_count <= sclk_count +1;
					if sclk_count = 4 then
						adc_sdin <= '0';
				adc_dout <= adc_dout(10 downto 0) & rx_bit1;
						adc_ctrl_state <=DATA_RX;		
					end if;
				end if;
			when DATA_RX =>
			if sclk_rising = '1' then
				adc_dout <= adc_dout(10 downto 0) & rx_bit1;
				if sclk_count  = 15 then
					adc_dval <='1';
				end if;
			end if;
				if sclk_falling= '1' then
					sclk_count <= sclk_count +1;
					if sclk_count  = 15 then
					--	adc_dout <= (others=>'0');
						adc_dval <='0';
						adc_ctrl_state <=ADDR_TX;
						sclk_count <= 0;
						if adc_addr = "111" then
							adc_ctrl_state <=IDLE;
							adc_addr <= "000";
							adc_dout <= (others=>'0');
						else
							adc_addr <= adc_addr + 1;
						end if;
					end if;
					
				end if;
				
			when others => 
				adc_ctrl_state <=IDLE;				
	
			end case;
		end if;
	end if;
	end process;

	
	
	
	

    -- register the input data twice
	 process(clk_i)
	 begin
	 if rising_edge(clk_i) then
        rx_bit0 <= adc_sdout_i;
        rx_bit1 <= rx_bit0;
	 end if;
    end process;
    
    -- detect sclk falling edge - for updating the data output
    process (clk_i)
    begin
	 if rising_edge(clk_i) then
        sclk_n1 <= sclk_i;
		  end if;
    end process;
    sclk_falling <= not(sclk_i) and sclk_n1;
	 sclk_rising <= not(sclk_n1) and sclk_i;

       
end behavioral;


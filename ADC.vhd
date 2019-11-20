library  ieee;
use  ieee.std_logic_1164.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity adc is
	port (adc_addr_o : out std_logic_vector (2 downto 0);
			adc_data_o : out std_logic_vector(11 downto 0); 
			sclk_i : in std_logic;
			rst_i  : in std_logic;
			din_i  : in std_logic;
			dout_o : out std_logic);
end adc;
		
architecture behavioral of adc is
signal sclk_count : integer := 0;
signal din_reg : std_logic_vector (11 downto 0);
signal adc_addr : std_logic_vector (2 downto 0);
begin

process(sclk_i)
begin
if rising_edge(sclk_i) then
	if rst_i = '1' then
		sclk_count <= 0;
	else
		if sclk_count = 15 then
		sclk_count <= 0;
		else
			sclk_count <= sclk_count + 1;
end if;
	end if;
end if;
end process;

process(sclk_i)
begin
if rising_edge(sclk_i) then
	if rst_i = '1' then
		adc_addr <= (others=>'0');
	else
		if sclk_count = 15 then
			adc_addr <= std_logic_vector(unsigned(adc_addr)+1);
	end if;
end if;
end if;
end process;

process(sclk_i)
begin
if falling_edge(sclk_i) then
	case sclk_count is
	when 2 => dout_o <= adc_addr(2);
	when 3 => dout_o <= adc_addr(1);
	when 4 => dout_o <= adc_addr(0);
	when others => dout_o <= '0';
	end case;
end if;
end process;



process(sclk_i)
begin
if rising_edge(sclk_i) then
   if rst_i = '1' then
		din_reg <= (others=>'0');
	else
		if sclk_count < 3 then
			din_reg <= (others=>'0');
		else
		    din_reg <= din_reg(10 downto 0) & din_i;
		end if;
		if sclk_count = 0 then
			adc_data_o <= din_reg;
			adc_addr_o <= adc_addr;
		end if;
	end if;
end if; 
end process;


--process(sclk_i)
--begin
--if falling_edge(sclk_i) then
--	if rst_i ='1' then
--	cs_n_o <= '1';
--	else
--	cs_n_o <='0';
--	end if;
--	end if;
--end process;


	
end behavioral;
 
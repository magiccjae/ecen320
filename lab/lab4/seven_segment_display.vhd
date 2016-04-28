library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seven_segment_display is
	generic(
		COUNTER_BITS: natural := 15
	);	
	port(
		clk: in std_logic;
		data_in: in std_logic_vector(15 downto 0);
		dp_in: in std_logic_Vector(3 downto 0);
		blank: in std_logic_vector(3 downto 0);
		seg : out std_logic_vector(6 downto 0);
		dp : out std_logic;
		an : out std_logic_vector(3 downto 0)
	);
end seven_segment_display;

architecture seven_arch of seven_segment_display is
	
	signal myseg: std_logic_vector(3 downto 0);
	signal r_reg: unsigned(COUNTER_BITS-1 downto 0):=(others=>'0');
	signal r_next: unsigned(COUNTER_BITS-1 downto 0);	
	signal anode_select: std_logic_vector(1 downto 0);
	signal an_temp: std_logic_vector(3 downto 0);
	begin	
		
		with myseg select
		seg <= "1000000" when "0000",
				 "1111001" when "0001",
				 "0100100" when "0010",
				 "0110000" when "0011",
				 "0011001" when "0100",
				 "0010010" when "0101",
				 "0000010" when "0110",
				 "1111000" when "0111",
				 "0000000" when "1000",
				 "0010000" when "1001",
				 "0001000" when "1010",
				 "0000011" when "1011",
				 "1000110" when "1100",
				 "0100001" when "1101",
				 "0000110" when "1110",
				 "0001110" when others;
		myseg <= data_in(3 downto 0) when anode_select="00" else
					data_in(7 downto 4) when anode_select="01" else
					data_in(11 downto 8) when anode_select="10" else
					data_in(15 downto 12);
			
		-- register
		process(clk)
		begin
			if(clk'event and clk='1') then
				r_reg <= r_next;
			end if;
		end process;
		-- next state
		process(r_reg)
		begin
			r_next <= r_reg+1;
		end process;
		anode_select <= std_logic_vector(r_reg(COUNTER_BITS-1 downto COUNTER_BITS-2));
		
		dp <= not dp_in(0) when anode_select="00" else
				not dp_in(1) when anode_select="01" else
				not dp_in(2) when anode_select="10" else
				not dp_in(3);
		
		an_temp <= "1110" when anode_select="00" else
					  "1101" when anode_select="01" else
					  "1011" when anode_select="10" else
					  "0111" when anode_select="11" else
					  "0000";
		an <= an_temp or blank;
		
end seven_arch;

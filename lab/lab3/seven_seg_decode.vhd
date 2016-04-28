library ieee;
use ieee.std_logic_1164.all;

entity seven_seg_decode is
	port(
		sw : in std_logic_vector(7 downto 0);
		btn : in std_logic_vector(3 downto 0);
		seg : out std_logic_vector(6 downto 0);
		dp : out std_logic;
		an : out std_logic_vector(3 downto 0)
	);
end seven_seg_decode;

architecture seven_arch of seven_seg_decode is
	signal myseg: std_logic_vector(3 downto 0);
	signal myoption: std_logic_vector(3 downto 0);

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
		myoption <= sw(3 downto 0) when (btn(1 downto 0)="00") else
						sw(7 downto 4) when (btn(1 downto 0)="01") else
						sw(3 downto 0) xor sw(7 downto 4) when (btn(1 downto 0)="10") else
						sw(1)&sw(0)&sw(3)&sw(2);		
		
		process(sw,btn,myoption)
		begin
			dp <= '1';
			myseg <= myoption;

			if(btn(3) = '1') then
				an <= "0000";
				dp <= '0';
				myseg <= "1000";
			elsif(btn(2) ='1') then
				an <= "1111";
			else
				if(btn = "0000") then
					an <= "1110";
				elsif(btn = "0001") then
					an <= "1101";
				elsif(btn = "0010") then
					an <= "1011";
				else
					an <= "0111";	
				end if;
			end if;			
		end process;
end seven_arch;

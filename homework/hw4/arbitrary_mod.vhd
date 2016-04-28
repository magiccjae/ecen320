library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity arbitrary_mod is
	port(
		clk, reset: in std_logic;
		q: out std_logic_vector(2 downto 0)
	);
end arbitrary_mod;

architecture mod_arch of arbitrary_mod is
	signal r_reg: unsigned(2 downto 0);
	signal counter, counter_next: unsigned(2 downto 0);
begin
	process(clk,reset)
	begin
		if(reset='1') then
			counter <= (others=>'0');
		elsif(clk'event and clk='1') then
			counter <= counter_next;
		end if;
	end process;
	
	-- next state logic
	counter_next <= (others=>'0') when counter=4 else
						 counter+1;
						 
	r_reg <= "000" when counter_next=4 else 
				 "011" when counter_next=0 else
				 "110" when counter_next=1 else
				 "101" when counter_next=2 else
				 "111";
				 
	-- output logic
	q <= std_logic_vector(r_reg);
	
end mod_arch;
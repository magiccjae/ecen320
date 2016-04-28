library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sync_counter is
	port(
		clk: in std_logic;
		y: out std_logic
	);
end sync_counter;

architecture sync_arch of sync_counter is

	signal q2, q3, q4: std_logic := '0';
	signal q1: std_logic := '0';
	signal en1, en2, en3: std_logic;

begin
	process(clk)
	begin
		if(clk'event and clk='1') then
			q1 <= not q1;
			q2 <= q2;
			q3 <= q3;
			q4 <= q4;
			if(en1='1') then
				q2 <= not q2;
			end if;
			if(en2='1' and en1='1') then
				q3 <= not q3;
			end if;
			if(en3='1' and en2='1' and en1='1') then
				q4 <= not q4;
			end if;
		end if;
	end process;

	
	en1 <= '1' when q1='1' else
			 '0';
	en2 <= '1' when q2='1' else
			 '0';
	en3 <= '1' when q3='1' else
			 '0';
			 
	y <= q4;
	
end sync_arch;
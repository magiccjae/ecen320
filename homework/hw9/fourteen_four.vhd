
-- 14.4

library ieee;
use ieee.std_logic_1164.all;
entity inc_conditional is
	generic(WIDTH: natural);
	port(
		a: in std_logic_vector(WIDTH-1 downto 0);
		s: out std_logic_vector(WIDTH-1 downto 0);
		cin: in std_logic;
		cout: out std_logic
	);
end inc_conditional;

architecture inc_arch of inc_conditional is
	signal tmp: std_logic_vector(WIDTH downto 0); 
	
begin

	loop_name: for i in 0 downto WIDTH-1 generate
		first_bound:
		if i = 0 generate
			tmp(i) <= cin;
		end generate;
		s(i) <= tmp(i) xor a(i);
		tmp(i+1) <= a(i) xor tmp(i);
		last_bound:
		if i = WIDTH-1 generate
			cout <= tmp(WIDTH);
		end generate;		
	end generate;
	
end inc_arch;
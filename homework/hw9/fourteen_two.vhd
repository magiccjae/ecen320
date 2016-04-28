
-- 14.2

library ieee;
use ieee.std_logic_1164.all;
entity inc_generic is
	generic(WIDTH: natural);
	port(
		a: in std_logic_vector(WIDTH-1 downto 0);
		s: out std_logic_vector(WIDTH-1 downto 0);
		cin: in std_logic;
		cout: out std_logic
	);
end inc_generic;

architecture inc_arch of inc_generic is
	signal tmp: std_logic_vector(WIDTH downto 0); 
	
begin

	loop_name: for i in 0 downto WIDTH-1 generate
		s(i) <= tmp(i) xor a(i);
		tmp(i+1) <= a(i) xor tmp(i);
	end generate;
	tmp(0) <= cin;
	cout <= tmp(WIDTH);
	
end inc_arch;
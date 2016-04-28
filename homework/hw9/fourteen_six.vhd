
-- 14.6

library ieee;
use ieee.std_logic_1164.all;
entity inc_clever is
	generic(WIDTH: natural);
	port(
		a: in std_logic_vector;
		s: out std_logic_vector;
		cin: std_logic;
		cout: out std_logic
	);
end inc_clever;

architecture inc_arch of inc_clever is

	signal tmp: std_logic_vector(WIDTH downto 0);
	
begin
	tmp(0) <= cin;
	s <= a xor tmp(WIDTH-1 downto 0);
	tmp(WIDTH downto 1) <= tmp(WIDTH-1 downto 0) and a;
	
end inc_arch;
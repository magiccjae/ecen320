
-- 14.5

library ieee;
use ieee.std_logic_1164.all;
entity inc_forloop is
	generic(WIDTH: natural);
	port(
		a: in std_logic_vector(WIDTH-1 downto 0);
		s: out std_logic_vector(WIDTH-1 downto 0);
		cin: in std_logic;
		cout: out std_logic
	);
end inc_forloop;

architecture inc_arch of inc_forloop is
	signal tmp: std_logic_vector(WIDTH downto 0);
	
begin
	process(a,tmp)
	begin
		tmp(0) <= cin;
		for i in 1 to (WIDTH) loop
			tmp(i) <= tmp(i-1) and a(i-1);
			s(i-1) <= tmp(i-1) xor a(i-1);
		end loop;
	end process;
	cout <= tmp(WIDTH);
	
end inc_arch;
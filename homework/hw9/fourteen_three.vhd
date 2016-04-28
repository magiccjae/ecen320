
-- 14.3

library ieee;
use ieee.std_logic_1164.all;
entity inc_component is
	generic(WIDTH: natural);
	port(
		a: in std_logic_vector(WIDTH-1 downto 0);
		s: out std_logic_vector(WIDTH-1 downto 0);
		cin: in std_logic;
		cout: out std_logic
	);
end inc_component;

architecture inc_arch of inc_component is

	signal tmp: std_logic_vector(WIDTH downto 0);
	
begin
	tmp(0) <= cin;
	loop_name: for i in 1 to (WIDTH) generate
		each_module: entity work.fourteen_one(rtl)
		port map(a=>a(i-1),cin=>tmp(i-1),cout=>tmp(i),s=>s(i-1));
	end generate;
	cout <= tmp(WIDTH);
	
end inc_arch;

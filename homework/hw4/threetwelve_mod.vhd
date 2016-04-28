library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity threetwelve_mod is
	port(
		clk: in std_logic;
		q: out std_logic_vector(3 downto 0)
	);
end threetwelve_mod;

architecture tm_arch of threetwelve_mod is
	signal r_reg: unsigned(3 downto 0);
	signal r_next, r_inc: unsigned(3 downto 0);
begin
	process(clk)
	begin
		if(clk'event and clk='1') then
			r_reg <= r_next;
		end if;
	end process;
	
	-- next state logic
	r_inc <= r_reg + 1;
	r_next <= "0011" when r_inc = 5*2 else -- this is mod 5 counter !!
				 r_inc;
				 
	-- output logic
	q <= std_logic_vector(r_reg);
	
end tm_arch;
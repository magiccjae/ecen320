library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity threetwelve is
	port(
		clk: in std_logic;
		q: out std_logic_vector(3 downto 0)
	);
end threetwelve;

architecture tt_arch of threetwelve is
	signal r_reg: unsigned(3 downto 0);
	signal r_next: unsigned(3 downto 0);
begin
	process(clk)
	begin
		if(clk'event and clk='1') then
			r_reg <= r_next;
		end if;
	end process;
	
	-- next state logic
	r_next <= r_reg + 1 when(r_reg >= "0011" and r_reg < "1100") else
				 "0011";
				 
	-- output logic
	q <= std_logic_vector(r_reg);
	
end tt_arch;
 
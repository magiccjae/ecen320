library ieee;
use ieee.std_logic_1164.all;
entity jkff is
	port(
		clk: in std_logic;
		q: out std_logic;
		jk: in std_logic_vector(1 downto 0)
	);
end jkff;

architecture jk_arch of jkff is
	signal q_reg: std_logic;
	signal q_next: std_logic;
begin
	process(clk)
	begin
		if(clk'event and clk='1') then
			q_reg <= q_next;
		end if;
	end process;
	
	-- next state logic
	q_next <= q_reg when jk="00" else
				 '0' when jk="01" else
				 '1' when jk="10" else
				 not q_reg;
	
	-- output logic
	q <= q_reg;
	
end jk_arch;
 
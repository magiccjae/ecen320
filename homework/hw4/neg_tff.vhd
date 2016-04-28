library ieee;
use ieee.std_logic_1164.all;
entity neg_tff is
	port(
		clk: in std_logic;
		q: out std_logic;
		t: in std_logic;
		reset: in std_logic
	);
end neg_tff;

architecture negt_arch of neg_tff is
	signal q_reg: std_logic;
	signal q_next: std_logic;
begin
	process(clk)
	begin
		if(clk'event and clk='0') then
			if(reset = '1') then
				q_reg <= '0';
			else
				q_reg <= q_next;
			end if;
		end if;
	end process;
	
	-- next state logic
	q_next <= q_reg when t='0' else
				 not(q_reg);
	
	-- output logic
	q <= q_reg;
	
end negt_arch;
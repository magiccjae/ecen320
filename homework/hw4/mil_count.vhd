library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity mil_count is
	port(
		clk: in std_logic;
		q: out std_logic
	);
end mil_count;

architecture mil_arch of mil_count is
	signal r_reg: unsigned(18 downto 0) := to_unsigned(0,19);
	signal r_next, r_inc: unsigned(18 downto 0) := to_unsigned(0,19);
	signal zero, zero_next: std_logic := '0';
begin
	process(clk)
	begin
		if(clk'event and clk='1') then
			r_reg <= r_next;
		end if;
	end process;
	
	r_inc <= r_reg + 1;
	r_next <= (others=>'0') when r_inc = 500000 else -- this is mod 500000 counter !!
				 r_inc;
	
	process(clk)
	begin
		if(clk'event and clk='1') then
			zero <= zero_next;
		end if;
	end process;
	
	zero_next <= not zero when r_inc = 500000 else
			  zero;
	-- output logic
	q <= zero;
	
end mil_arch;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity stack is
	port(
		clk, reset: in std_logic;
		full, empty: out std_logic;
		push, pop: in std_logic;
		w_addr, r_addr: out std_logic_vector(1 downto 0)
	);
	
end stack;

architecture stack_arch of stack is

	constant N: natural := 1;
	signal addr_reg, addr_next: unsigned(N downto 0);
	signal full_flag, empty_flag: std_logic;
	
begin
	process(clk,reset)
	begin
		if (reset='1') then
			addr_reg <= (others=>'0');
		elsif(clk'event and clk='1') then
			addr_reg <= addr_next;
		end if;
	end process;

addr_next <= addr_reg+1 when push='1' and full_flag='0' else
				 addr_reg-1 when pop='1' and empty_flag='0' else
				 addr_reg;


full_flag <= '1' when addr_reg="11" else
				 '0';
empty_flag <= '1' when addr_reg="00" else
				  '0';

w_addr <= std_logic_vector(addr_reg+1);
r_addr <= std_logic_vector(addr_reg);
full <= full_flag;
empty <= empty_flag;

end stack_arch;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity stack_top is
	port(
		clk, reset: in std_logic;
		full, empty: out std_logic;
		push, pop: in std_logic;
		w_data: in std_logic_vector(15 downto 0);
		r_data: out std_logic_vector(15 downto 0)
	);
	
end stack_top;

architecture top_arch of stack is


end top_arch;
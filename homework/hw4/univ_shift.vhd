library ieee;
use ieee.std_logic_1164.all;
entity univ_shift is
	port(
		clk, reset: in std_logic;
		ctrl: in std_logic_vector(2 downto 0);
		q: out std_logic_vector(3 downto 0);
		d: in std_logic_vector(3 downto 0)
	);
end univ_shift;

architecture univ_arch of univ_shift is
	signal r_reg: std_logic_vector(3 downto 0);
	signal r_next: std_logic_vector(3 downto 0);
begin
	process(clk, reset)
	begin
		if(reset = '1') then
			r_reg <= (others => '0');
		elsif(clk'event and clk='1') then
			r_reg <= r_next;
		end if;
	end process;
	
	-- next state logic
	with ctrl select
		r_next <= r_reg when "000", -- pause
					 r_reg(2 downto 0) & d(0) when "001", -- shift left
					 d(3) & r_reg(3 downto 1) when "010", -- shift right
					 r_reg(2 downto 0) & r_reg(3) when "011", -- rotate left
					 r_reg(0) & r_reg(3 downto 1) when "100", -- rotate right
					 d when others;
		q <= r_reg;
end univ_arch;
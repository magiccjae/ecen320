library ieee;
use ieee.std_logic_1164.all;
entity thousand_93_counter is
	port(
		clk, reset: in std_logic;
		en: in std_logic;
		q_hundred, q_ten, q_one: out std_logic_vector(3 downto 0);
		p1000: out std_logic
	);
end thousand_93_counter;

architecture vhdl_93_arch of thousand_93_counter is
	signal p_one, p_ten, p_hundred: std_logic;
begin
	one_digit: entity work.dec_counter(up_arch)
		port map(clk=>clk, reset=>reset, en=>en, pulse=>p_one, q=>q_one);
	ten_digit: entity work.dec_counter(up_arch)
		port map(clk=>clk, reset=>reset, en=>p_one, pulse=>p_ten, q=>q_ten);
	hundred_digit: entity work.dec_counter(up_arch)
		port map(clk=>clk, reset=>reset, en=>p_ten, pulse=>p_hundred, q=>q_hundred);
p1000 <= p_one and p_ten and p_hundred;
end vhdl_93_arch;

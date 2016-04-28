library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity p3_11 is
	port(
	 a:in std_logic;
	 b:out std_logic
	);
end p3_11;

architecture p_arch of p3_11 is
	signal s1, s2, s3, s4, s5, s6, s7: std_logic_vector(3 downto 0);
	signal u1, u2, u3, u4, u5, u6, u7: unsigned(3 downto 0);
	signal sg: signed(3 downto 0);
begin
	u1 <= to_unsigned(2#0001#,4);
	u2 <= u3 and u4;
	u5 <= unsigned(s1) + 1;
	u6 <= u3 + u4 + 3;
	u7 <= (others => '1');
	s2 <= std_logic_vector(unsigned(s3) + unsigned(s4) - 1);
	s5 <= (others => '1');
	s6 <= std_logic_vector(u3 and u4);
	sg <= signed(u3) - 1;
	s7 <= not std_logic_vector(sg);

end p_arch;
library ieee;
use ieee.std_logic_1164.all;

entity reduced_xor is
	port(
		clk: in std_logic;
		a: in std_logic_vector(7 downto 0);
		y: out std_logic
	);
end reduced_xor;

architecture pipe_xor of reduced_xor is

	signal reg1, reg2, reg3, reg4, reg5, reg6, reg7: std_logic := '0';
	signal next1, next2, next3, next4, next5, next6, next7: std_logic;
	
begin
	process(clk)
	begin
		if(clk'event and clk='1') then 
			reg1 <= a(0) xor a(1);
			reg2 <= a(2) xor a(3);
			reg3 <= a(4) xor a(5);
			reg4 <= a(6) xor a(7);
			reg5 <= next5;
			reg6 <= next6;
			reg7 <= next7;
		end if;
	end process;
	
	next5 <= reg1 xor reg2;
	next6 <= reg3 xor reg4;
	next7 <= reg5 xor reg6;
	
	y <= reg7;

end pipe_xor;
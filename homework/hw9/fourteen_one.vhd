library ieee;
use ieee.std_logic_1164.all;

entity fourteen_one is
	port (
		a, cin: in std_logic;
		s, cout: out std_logic
	);
end fourteen_one;

architecture rtl of fourteen_one is
begin 
	s <= a xor cin;
	cout <= a and cin;
end rtl;
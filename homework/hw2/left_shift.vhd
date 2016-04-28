library ieee;
use ieee.std_logic_1164.all;
entity left_shift is
	port(
		a: in std_logic_vector(7 downto 0);
		ctrl: in std_logic_vector(2 downto 0);
		y: out std_logic_vector(7 downto 0)
	);
end left_shift;

architecture shift_arch of left_shift is
begin
	y <= a when(ctrl="000") else
		  a(6)&a(5)&a(4)&a(3)&a(2)&a(1)&a(0)&a(7) when(ctrl="001") else
		  a(5)&a(4)&a(3)&a(2)&a(1)&a(0)&a(7)&a(6) when(ctrl="010") else
		  a(4)&a(3)&a(2)&a(1)&a(0)&a(7)&a(6)&a(5) when(ctrl="011") else
		  a(3)&a(2)&a(1)&a(0)&a(7)&a(6)&a(5)&a(4) when(ctrl="100") else
		  a(2)&a(1)&a(0)&a(7)&a(6)&a(5)&a(4)&a(3) when(ctrl="101") else
		  a(1)&a(0)&a(7)&a(6)&a(5)&a(4)&a(3)&a(2) when(ctrl="110") else
		  a(0)&a(7)&a(6)&a(5)&a(4)&a(3)&a(2)&a(1);
end shift_arch;

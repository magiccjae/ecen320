
library ieee;
use ieee.std_logic_1164.all;

entity lab2 is
	port( 
		switches: in std_logic_vector(7 downto 0);
		buttons: in std_logic_vector(3 downto 0);
		leds: out std_logic_vector(7 downto 0)
	);
end lab2;
architecture lab2_arch of lab2 is
	
begin
	leds <= switches(0) & switches(7) & switches(6) & switches(5) & switches(4) & switches(3) & switches(2) & switches(1) when buttons(0) = '1' else
			  (not switches(7)) & (not switches(6)) &(not switches(5)) &(not switches(4)) &(not switches(3)) &(not switches(2)) &(not switches(1)) & (not switches(0)) when buttons(1) = '1' else
			  switches(0) & switches(1) & switches(2) & switches(3) & switches(4) & switches(5) & switches(6) & switches(7) when buttons(2) = '1' else
			  switches(3) & switches(2) & switches(1) & switches(0) & switches(7) & switches(6) & switches(5) & switches(4) when buttons(3) = '1' else
			  switches;			  
end lab2_arch;
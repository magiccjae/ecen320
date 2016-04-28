library ieee;
use ieee.std_logic_1164.all;

entity edge_detector is
	port(
		clk: in std_logic;
		strobe: in std_logic;
		p1: out std_logic;
	);
end edge_detector;

architecture moore_edge of edge_detector is
	type state_type is (zero, edge, one);
	signal state_reg, state_next: state_type;
	
begin
	process(clk)
	begin
		if(clk'event and clk='1') then
			state_reg <= state_next;
		end if;
	end process;
	
	process(state_reg,strobe)
	begin
		case state_reg is
			when zero =>
				if strobe='1' then
					state_next <= edge;
				else
					state_next <= zero;
				end if;
			when edge =>
				p1 <= '1';
				if strobe='1' then
					state_next <= one;
				else
					state_next <= zero;
				end if;
			when one =>
				if strobe='1' then
					state_next <= one;
				else
					state_next <= edge;
				end if;
		end case;				
	end process;

end moore_edge;

architecture mealy_edge of edge_detector is
	type state_type is (zero, one);
	signal state_reg, state_next: state_type;

begin
	process(clk)
	begin
		if(clk'event and clk='1') then 
		end if;
	end process;

	process(state_reg,strobe)
	begin
		case state_reg is
			when zero =>
				if strobe='1' then
					p1 <= '1';
					state_next <= one;
				else
					state_next <= zero;
				end if;
			when one =>
				if strobe='1' then
					state_next <= one;
				else
					p1 <= '1';					
					state_next <= zero;
				end if;
		end case;				
	end process;	
	

end mealy_edge;
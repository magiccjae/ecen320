library ieee;
use ieee.std_logic_1164.all;
entity preamble is
	port(
		clk: in std_logic;
		start: in std_logic;
		data_out: out std_logic
	);
	
end preamble;

architecture preamble_arch of preamble is
	type state_type is
		(idle,out1,out2,out3,out4,out5,out6,out7,out8);
	signal state_reg, state_next: state_type := idle;

begin
	process(clk)
	begin
		if(rising_edge(clk)) then
			state_reg <= state_next;
		end if;
	end process;
	
	process(state_reg,start)
	begin
		state_next <= state_reg;
		case state_reg is
			when idle=>
				if start='1' then
					state_next <= out1;
				end if;
			when out1=>
				state_next <= out2;
				data_out <= '1';
			when out2=>
				state_next <= out3;
				data_out <= '0';				
			when out3=>
				state_next <= out4;
				data_out <= '1';				
			when out4=>
				state_next <= out5;
				data_out <= '0';
			when out5=>
				state_next <= out6;
				data_out <= '1';
			when out6=>
				state_next <= out7;
				data_out <= '0';				
			when out7=>
				state_next <= out8;
				data_out <= '1';
			when out8=>
				state_next <= idle;
				data_out <= '0';
		end case;

	end process;
	
end preamble_arch;
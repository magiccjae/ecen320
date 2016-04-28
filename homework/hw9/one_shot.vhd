library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity one_shot_pulse_generator is
	port(
		clk,reset: in std_logic;
		go,stop: in std_logic;
		pulse: out std_logic
	);
end one_shot_pulse_generator;

architecture pulse_arch of one_shot_pulse_generator is
		
	type fsm_state_type is 
	(idle,delay,sh);
	signal state_reg, state_next: fsm_state_type;
	signal c_reg,c_next: unsigned(2 downto 0);
	signal w_reg,w_next: unsigned(2 downto 0);
	signal counter: natural := 0;

begin
	-- state and data registers
	process(clk,reset)
	begin
		if(reset='1') then
			state_reg <= idle;
			c_reg <= (others=>'0');
			w_reg <= "101";
		elsif(clk'event and clk='1') then
			state_reg <= state_next;
			c_reg <= c_next;
			w_reg <= w_next;
		end if;
	end process;
		
	-- next state logic & data path functional units/routing
	process(state_reg,go,stop,c_reg,w_reg)
	begin
		pulse <= '0';
		c_next <= c_reg;
		w_next <= w_reg;
		case state_reg is
			when idle =>
				if(go='1') then
					if stop='1' then
						state_next <= sh;
					else
						state_next <= delay;
					end if;
				else
					state_next <= idle;
				end if;
				c_next <= (others=>'0');
				
			when delay =>
				if(stop='1') then
					state_next <= idle;
				else
					if(c_reg=w_reg-1) then
						state_next <= idle;
					else
						c_next <= c_reg+1;
						state_next <= delay;
					end if;
				end if;
				pulse <= '1';
				
			when sh =>
				if(counter=2) then
					w_next <= go & w_reg(2 downto 1);
					state_next <= idle;
				else
					w_next <= go & w_reg(2 downto 1);
					state_next <= sh;
					counter <= counter + 1;
				end if;
		end case;
	
	end process;
		
end pulse_arch;
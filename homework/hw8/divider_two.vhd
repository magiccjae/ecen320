library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity divider_two is
	port(
		clk: in std_logic;
		y_in: in std_logic_vector(7 downto 0);
		d: in std_logic_vector(7 downto 0);
		r_out: out std_logic_vector(7 downto 0);
		q_out: out std_logic_vector(7 downto 0)
	);
	
end divider_two;

architecture divider_arch of divider_two is
	type state_type is
		(idle,y_less_d,load,op,stop);
	signal state_reg, state_next: state_type := idle;
	signal y_reg, y_next: unsigned(7 downto 0);
	signal q_reg, q_next: unsigned(7 downto 0);

begin
	-- state and data registers
	process(clk)
	begin
		if(rising_edge(clk)) then
			state_reg <= state_next;
			y_reg <= y_next;
			q_reg <= q_next;
			q_reg <= q_next;			
			
		end if;
	end process;
	
	-- combinational circuit
	process(state_reg,y_reg,q_reg)
	begin
		state_next <= state_reg;
		y_next <= y_reg;
		q_next <= q_reg;
		
		case state_reg is
			when idle=>
				q_out <= (others=>'0');
				r_out <= (others=>'0');
				if y_in <= d then
					state_next <= y_less_d;
				else
					state_next <= load;
				end if;
			when y_less_d=>
				state_next <= idle;
				q_out <= (others=>'0');
				r_out <= y_in;
			when load=>
				state_next <= op;
				y_next <= unsigned(y_in);
				q_next <= (others=>'0');
			when op=>
				y_next <= y_reg-unsigned(d);
				q_next <= q_reg+1;						
				if(y_reg <= unsigned(d)) then 
					state_next <= stop;
				else
					state_next <= state_reg;
				end if;
			when stop=>
				state_next <= idle;
		end case;

	end process;
	
	-- control path: output logic
	r_out <= y_in when state_reg=y_less_d else 
				std_logic_vector(y_reg) when state_reg=stop else
				(others=>'0');
	q_out <= std_logic_vector(q_reg) when state_reg=stop else (others=>'0');
		

end divider_arch;
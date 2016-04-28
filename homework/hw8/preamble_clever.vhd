library ieee;
use ieee.std_logic_1164.all;
entity preamble_clever is
	port(
		clk: in std_logic;
		start: in std_logic;
		data_out: out std_logic
	);
	
end preamble_clever;

architecture clever_arch of preamble_clever is
	constant idle: std_logic_vector(3 downto 0) := "0000";
	constant out1: std_logic_vector(3 downto 0) := "0001";
	constant out2: std_logic_vector(3 downto 0) := "0010";
	constant out3: std_logic_vector(3 downto 0) := "0011";
	constant out4: std_logic_vector(3 downto 0) := "0100";
	constant out5: std_logic_vector(3 downto 0) := "0101";
	constant out6: std_logic_vector(3 downto 0) := "0110";
	constant out7: std_logic_vector(3 downto 0) := "0111";
	constant out8: std_logic_vector(3 downto 0) := "1000";
	
	signal state_reg, state_next: std_logic_vector(3 downto 0) := "0000";

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
				data_out <= state_reg(0);
			when out2=>
				state_next <= out3;
				data_out <= state_reg(0);
			when out3=>
				state_next <= out4;
				data_out <= state_reg(0);
			when out4=>
				state_next <= out5;
				data_out <= state_reg(0);
			when out5=>
				state_next <= out6;
				data_out <= state_reg(0);
			when out6=>
				state_next <= out7;
				data_out <= state_reg(0);
			when out7=>
				state_next <= out8;
				data_out <= state_reg(0);
			when others=>
				state_next <= idle;
				data_out <= state_reg(0);
		end case;

	end process;
	
end clever_arch;
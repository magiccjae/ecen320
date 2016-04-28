library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rx is
	generic(
		CLK_RATE: natural := 50_000_000;
		BAUD_RATE: natural := 19_200
	);
	port(
		clk: in std_logic;
		rst: in std_logic;
		data_out: out std_logic_vector(7 downto 0);
		data_strobe: out std_logic;		
		rx_in: in std_logic;
		rx_busy:out std_logic
		
	);
end rx;

architecture receiver_arch of rx is
	function log2c(n: integer) return integer is
		variable m, p: integer;
	begin
		m := 0;
		p := 1;
		while p<n loop
			m:= m+1;
			p:=p*2;
		end loop;
		return m;
	end log2c;
	
	constant BIT_COUNTER_MAX_VAL : Natural := CLK_RATE / BAUD_RATE - 1;
	constant BIT_COUNTER_BITS : Natural := log2c(BIT_COUNTER_MAX_VAL);
	
	signal counter: unsigned(BIT_COUNTER_BITS downto 0) := (others=>'0');
	signal counter_next: unsigned(BIT_COUNTER_BITS downto 0);	
	
	type fsm_state_type is 
	(powerup,idle,strt,b0,b1,b2,b3,b4,b5,b6,b7,stp);
	signal state_reg, state_next: fsm_state_type;
	
	-- BitTimer signal
	signal rx_bit: std_logic := '0';
	signal rx_half_bit: std_logic := '0';
	signal temp: std_logic_vector(7 downto 0) := (others=>'0');
	
begin
	
	-- FSM
	process(clk,rst)
	begin
		if(rst='1') then
			state_reg <= powerup;
			data_out <= (others=>'0');
		elsif(clk'event and clk='1') then
			state_reg <= state_next;
			data_out <= temp;	
		end if;
	end process;
	
	process(state_reg,rx_bit,rx_half_bit,rx_in,temp)
	begin
		state_next <= state_reg;
		rx_busy <= '1';
		temp <= temp;
		case state_reg is
			when idle =>
				rx_busy <= '0';
				if(rx_in='0') then
					state_next <= strt;
				end if;
			when strt =>
				if(rx_bit='1') then
					state_next <= b0;
				end if;
			when b0 =>
				if(rx_bit='1') then
					state_next <= b1;
				else
					if(rx_half_bit='1') then
						temp(7 downto 1) <= temp(7 downto 1);
						temp(0) <= rx_in;
					end if;
				end if;
			when b1 =>
				if(rx_bit='1') then
					state_next <= b2;
				else
					if(rx_half_bit='1') then
						temp(7 downto 2) <= temp(7 downto 2);
						temp(0) <= temp(0);
						temp(1) <= rx_in;
					end if;
				end if;
			when b2 =>
				if(rx_bit='1') then
					state_next <= b3;
				else
					if(rx_half_bit='1') then
						temp(7 downto 3) <= temp(7 downto 3);
						temp(1 downto 0) <= temp(1 downto 0);					
						temp(2) <= rx_in;
					end if;
				end if;
			when b3 =>
				if(rx_bit='1') then
					state_next <= b4;
				else
					if(rx_half_bit='1') then
						temp(7 downto 4) <= temp(7 downto 4);
						temp(2 downto 0) <= temp(2 downto 0);	
						temp(3) <= rx_in;
					end if;
				end if;
			when b4 =>
				if(rx_bit='1') then
					state_next <= b5;
				else
					if(rx_half_bit='1') then
						temp(7 downto 5) <= temp(7 downto 5);
						temp(3 downto 0) <= temp(3 downto 0);						
						temp(4) <= rx_in;
					end if;
				end if;
			when b5 =>
				if(rx_bit='1') then
					state_next <= b6;
				else
					if(rx_half_bit='1') then
						temp(7 downto 6) <= temp(7 downto 6);
						temp(4 downto 0) <= temp(4 downto 0);						
						temp(5) <= rx_in;
					end if;
				end if;
			when b6 =>
				if(rx_bit='1') then
					state_next <= b7;
				else
					if(rx_half_bit='1') then
						temp(7) <= temp(7);
						temp(5 downto 0) <= temp(5 downto 0);						
						temp(6) <= rx_in;
					end if;
				end if;
			when b7 =>
				if(rx_bit='1') then
					state_next <= stp;
				else
					if(rx_half_bit='1') then
						temp(6 downto 0) <= temp(6 downto 0);						
						temp(7) <= rx_in;
					end if;
				end if;
			when stp =>
				if(rx_bit='0') then
					state_next <= stp;
				elsif(rx_bit='1' and rx_in='1') then	
					state_next <= idle;
				else
					state_next <= powerup;
				end if;
			when powerup =>
				if(rx_in='1') then
					state_next <= idle;
				end if;
		end case;
	end process;
	
	data_strobe <= '1' when (state_reg=stp) and state_next=idle else
						'0';
	
	-- BitTimer	
	process(clk,rst)
	begin
		if(rst='1') then
			counter <= (others=>'0');
		elsif(clk'event and clk='1') then
			counter <= counter_next;
		end if;
	end process;
	
	counter_next <= (others=>'0') when counter = to_unsigned(BIT_COUNTER_MAX_VAL,BIT_COUNTER_BITS) else
						 (others=>'0') when state_reg = idle else
						 counter+1;
	rx_bit <= '1' when counter = to_unsigned(BIT_COUNTER_MAX_VAL,BIT_COUNTER_BITS) else
				 '0';
	rx_half_bit <= '1' when counter = to_unsigned(BIT_COUNTER_MAX_VAL,BIT_COUNTER_BITS)/2 else
						'0';
	
	
end receiver_arch;
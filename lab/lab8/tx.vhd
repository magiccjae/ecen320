library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tx is
	generic(
		CLK_RATE: natural := 50_000_000;
		BAUD_RATE: natural := 19_200
	);
	port(
		clk: in std_logic;
		rst: in std_logic;
		data_in: in std_logic_vector(7 downto 0);
		send_character: in std_logic;
		tx_out: out std_logic;
		tx_busy:out std_logic
		
	);
end tx;

architecture tran_arch of tx is
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
	(idle,strt,b0,b1,b2,b3,b4,b5,b6,b7,stp,retrn);
	signal state_reg, state_next: fsm_state_type;
	
	-- BitTimer signal
	signal tx_bit: std_logic;
	
	-- Shift Register signal
	signal shift_out: std_logic;
	signal shift_next: std_logic;	
	signal mydata: std_logic_vector(7 downto 0);
	
	-- FSM signal
	signal load: std_logic;
	signal clrTimer: std_logic;
	signal shift: std_logic;
	signal stop: std_logic;
	signal start: std_logic;
	
	-- Transmit Out signal
	
begin

	-- Transmit Out
	process(clk,shift_out)
	begin
		if(clk'event and clk='1') then
			tx_out <= shift_out;
			if(start='1') then
				tx_out <= '0';
			end if;
			if(stop='1') then
				tx_out <= '1';
			end if;
		end if;
	end process;
	
	-- FSM
	process(clk,rst)
	begin
		if(rst='1') then
			state_reg <= idle;
		elsif(clk'event and clk='1') then
			state_reg <= state_next;
		end if;
	end process;
	
	process(state_reg,send_character,tx_bit)
	begin
		state_next <= state_reg;
		start <= '0';
		stop <= '0';
		tx_busy <= '1';
		shift <= '0';
		clrTimer <= '0';
		load <= '0';
		case state_reg is
			when idle =>
				stop <= '1';			
				clrTimer <= '1';
				tx_busy <= '0';
				if(send_character='1') then
					load <= '1';
					state_next <= strt;
				end if;
			when strt =>
				start <= '1';		
				if(tx_bit='1') then
					state_next <= b0;
				end if;
			when b0 =>
				if(tx_bit='1') then
					shift <= '1';
					state_next <= b1;
				end if;
			when b1 =>
				if(tx_bit='1') then
					shift <= '1';
					state_next <= b2;
				end if;
			when b2 =>
				if(tx_bit='1') then
					shift <= '1';
					state_next <= b3;
				end if;
			when b3 =>
				if(tx_bit='1') then
					shift <= '1';
					state_next <= b4;
				end if;
			when b4 =>
				if(tx_bit='1') then
					shift <= '1';
					state_next <= b5;
				end if;
			when b5 =>
				if(tx_bit='1') then
					shift <= '1';
					state_next <= b6;
				end if;
			when b6 =>
				if(tx_bit='1') then
					shift <= '1';
					state_next <= b7;
				end if;
			when b7 =>
				if(tx_bit='1') then
					shift <= '1';
					state_next <= stp;
				end if;
			when stp =>
				stop <= '1';			
				if(tx_bit='1') then
					state_next <= retrn;
				end if;
			when retrn =>
				stop <= '1';			
				if(send_character='0') then
					state_next <= idle;
				end if;
			
		end case;
	
	end process;
	
	
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
	tx_bit <= '1' when counter = to_unsigned(BIT_COUNTER_MAX_VAL,BIT_COUNTER_BITS) else
				 '0';
	
	-- Shift Register
	process(clk,rst,load)
	begin
		if(rst='1') then
			mydata <= (others=>'0');
		elsif(clk'event and clk='1') then
			if(load = '1') then
				mydata <= data_in;
			else
				mydata <= mydata;
			end if;
			shift_out <= shift_next;
		end if;
	end process;
		
	shift_next <= mydata(0) when state_reg=b0 else
					  mydata(1) when state_reg=b1 else
					  mydata(2) when state_reg=b2 else
					  mydata(3) when state_reg=b3 else
					  mydata(4) when state_reg=b4 else
					  mydata(5) when state_reg=b5 else
					  mydata(6) when state_reg=b6 else
					  mydata(7) when state_reg=b7 else
					  '0';
	
end tran_arch;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sramController is
	port(
		clk, rst: in std_logic;
		mem, rw: in std_logic;
		addr: in std_logic_vector(22 downto 0);
		data_m2s: in std_logic_vector(15 downto 0);
		data_s2m: out std_logic_vector(15 downto 0);
		data_valid, ready: out std_logic;
		MemOE, MemWR: out std_logic;
		MemAdr: out std_logic_vector(22 downto 0);
		RamCS: out std_logic;
		RamLB, RamUB: out std_logic;
		RamCLK, RamADV, RamCRE: out std_logic;
		MemDB: inout std_logic_vector(15 downto 0)
	);

end sramController;

architecture controller_arch of sramController is

	type state_type is 
	(powerup,idle,r1,r2,r3,r4,w1,w2,w3,w4,w5);
	signal state_reg, state_next: state_type;
	

	signal addr_reg, addr_next: std_logic_vector(22 downto 0);
	signal in_reg, in_next: std_logic_vector(15 downto 0);
	signal out_reg, out_next: std_logic_vector(15 downto 0);
	signal tri_en: std_logic;
	signal counter, counter_next: natural := 0;
	signal counter_en: std_logic;
	
begin

	RamCLK <= '0';
	RamADV <= '0';
	RamCRE <= '0';
	RamUB <= '0';
	RamLB <= '0';

	-- I/O registers
	process(clk,rst)
	begin
		if(rst='1') then
			state_reg <= powerup;
			in_reg <= (others=>'0');
			out_reg <= (others=>'0');
			addr_reg <= (others=>'0');
		elsif(clk'event and clk='1') then
			in_reg <= in_next;
			out_reg <= out_next;
			addr_reg <= addr_next;
			state_reg <= state_next;
		end if;
	end process;
	
	-- next-state logic
	addr_next <= addr when state_reg = idle and mem = '0' else
					 addr_reg;
	-- writing to SRAM
	in_next <= data_m2s when mem='0' and rw='0' else
				  in_reg;
	-- reading from SRAM 
	out_next <= MemDB when tri_en = '0' and state_reg = r4 else
					out_reg;
	
	MemDB <= in_reg when tri_en = '1' else
				(others=>'Z');

	-- output logic
	data_s2m <= out_reg;
	MemAdr <= addr_reg;
	
	-- state machine
	process(state_reg, counter_en, mem, rw)
	begin
		tri_en <= '0';
		MemWR <= '1';
		MemOE <= '1';
		ready <= '0';
		RamCS <= '0';
		data_valid <= '0';
		state_next <= state_reg;
		case state_reg is
			when powerup =>
				RamCS <= '1';
				if(counter_en = '1') then
					state_next <= idle;
				else
					state_next <= state_reg;
				end if;
			when idle =>
				ready <= '1';
				if(mem = '0' and rw = '1') then
					state_next <= r1;
				elsif(mem = '0' and rw = '0') then
					state_next <= w1;
				end if;
			when r1 =>
				state_next <= r2;
			when r2 =>
				state_next <= r3;
				MemOE <= '0';
			when r3 =>
				state_next <= r4;
				MemOE <= '0';
			when r4 =>
				MemOE <= '0';
				data_valid <= '1';
				state_next <= powerup;
			when w1 =>
				state_next <= w2;
			when w2 =>
				MemWR <= '0';
				tri_en <= '1';
				state_next <= w3;				
			when w3 =>
				MemWR <= '0';
				tri_en <= '1';
				state_next <= w4;
			when w4 =>
				MemWR <= '0';
				tri_en <= '1';
				state_next <= w5;
			when w5 =>
				MemWR <= '0';
				tri_en <= '1';
				state_next <= powerup;
	
		end case;
	end process;
	
	
	-- bit timer
	process(clk,rst)
	begin
		if(rst='1') then
			counter <= 0;
		elsif(clk'event and clk='1') then
			counter <= counter_next;
		end if;
	end process;
	counter_next <= 0 when counter = 7500 else
						 counter + 1;
	counter_en <= '1' when counter = 7500 else
					  '0';
	
end controller_arch;
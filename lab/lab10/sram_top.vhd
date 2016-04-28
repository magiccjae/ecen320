library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sram_top is
	port(
		sw: in std_logic_vector(7 downto 0);
		btn: in std_logic_vector(3 downto 0);
		seg : out std_logic_vector(6 downto 0);
		an : out std_logic_vector(3 downto 0) := "0000";		
		dp : out std_logic;
		
		clk: in std_logic;
		data_valid, ready: out std_logic;
		MemOE, MemWR: out std_logic;
		MemAdr: out std_logic_vector(22 downto 0);
		RamCS: out std_logic;
		RamLB, RamUB: out std_logic;
		RamCLK, RamADV, RamCRE: out std_logic;
		MemDB: inout std_logic_vector(15 downto 0)
	);
end sram_top;

architecture top_arch of sram_top is
			
	component seven_segment_display
		generic(
			COUNTER_BITS: natural := 15
		);	
		port(
			clk: in std_logic;
			data_in: in std_logic_vector(15 downto 0);
			dp_in: in std_logic_Vector(3 downto 0);
			blank: in std_logic_vector(3 downto 0);
			seg : out std_logic_vector(6 downto 0);
			dp : out std_logic;
			an : out std_logic_vector(3 downto 0)
		);
	end component;
	
	component sramController is
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
	end component;
	
	
	signal addr_reg, addr_next: std_logic_vector(22 downto 0) := (others=>'0');
	signal in_reg, in_next: std_logic_vector(7 downto 0) := (others=>'0');
	signal combined_data: std_logic_vector(15 downto 0) := (others=>'0');
	signal reset: std_logic;
	signal temp: std_logic_vector(15 downto 0) := (others=>'0');
	signal mem, rw: std_logic := '0';
	signal dp_in: std_logic_vector(3 downto 0) := "0000";
	signal blank4: std_logic_vector(3 downto 0) := (others=>'0');	
	
	begin
		
		bottom_segment: seven_segment_display
		generic map(COUNTER_BITS=>15)
		port map(clk=>clk, an=>an, seg=>seg, dp=>dp, blank=>blank4,
					data_in=>temp, dp_in=>dp_in
				);
		
		bottom_controller: sramController
		port map(clk=>clk, rst=>reset, mem=>mem, rw=>rw, addr=>addr_reg, data_m2s=>combined_data, data_s2m=>temp, data_valid=>data_valid, 
					MemOE=>MemOE, MemWR=>MemWR, MemAdr=>MemAdr, RamCS=>RamCS, RamUB=>RamUB, RamLB=>RamLB, RamCLK=>RamCLK, RamADV=>RamADV, RamCRE=>RamCRE, MemDB=>MemDB);
		
		process(clk)
		begin
			if(rising_edge(clk)) then
				addr_reg <= addr_next;
				in_reg <= in_next;
			end if;
		end process;		
		
		-- button logic
		addr_next <= "000000000000000" & sw when btn(0)='1' and btn(3 downto 1) = "000" else
						 addr_reg;
		in_next <= sw when btn(1)='1' and btn(3 downto 2)="00" and btn(0)='0' else
					  in_reg;
					  
		combined_data <= in_reg & in_reg when reset='0' else
							  (others=>'0');
		
		reset <= '1' when btn = "1111" else
					'0';
					
		mem <= '0' when (btn(2)='1' or btn(3)='1') and btn(1)='0' and btn(0)='0' else
				 '1';
		rw <= '1' when btn(3)='1' and btn(2 downto 0)="000" else
				'0';
		
end top_arch;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tx_top is
	generic(COUNTER_BIT: natural := 20);
	port(
		clk: in std_logic;
		sw: in std_logic_vector(7 downto 0);
		seg : out std_logic_vector(6 downto 0);
		an : out std_logic_vector(3 downto 0) := "1100";		
		dp : out std_logic;
		tx_out: out std_logic;
		btn: in std_logic_vector(3 downto 0)
	);
end tx_top;

architecture top_arch of tx_top is
			
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
	
	component tx
		port(
			clk: in std_logic;
			rst: in std_logic;
			data_in: in std_logic_vector(7 downto 0);
			send_character: in std_logic;
			tx_out: out std_logic;
			tx_busy: out std_logic
			
		);
	end component;
	
	signal reset: std_logic := '0';
	signal dp_in: std_logic_vector(3 downto 0) := "0000";
	signal blank4: std_logic_vector(3 downto 0) := (others=>'0');	
	signal data_in: std_logic_vector(7 downto 0) := (others=>'0');
	signal send_character: std_logic;
	signal counter: unsigned(COUNTER_BIT downto 0) := (others=>'0');
	signal debouncing: std_logic;
	signal data_in2: std_logic_vector(15 downto 0) := (others=>'0');
	
	begin
		
		bottom_segment: seven_segment_display
		generic map(COUNTER_BITS=>15)
		port map(clk=>clk, an=>an, seg=>seg, dp=>dp, blank=>blank4,
					data_in=>data_in2, dp_in=>dp_in
				);
		
		bottom_tx: tx
		port map(clk=>clk, rst=>reset, send_character=>send_character, 
					tx_out=>tx_out, tx_busy=>open, data_in=>data_in
				);
		
		
		data_in <=  sw;	
		data_in2 <= "00000000" & sw;
		-- debouncer
		process(clk)
		begin
			if(rising_edge(clk)) then
				if(counter = "111111111111111111111") then
					debouncing <= '1';
					counter <= (others=>'0');
				else
					debouncing <= '0';				
					counter <= counter+1;
				end if;
			end if;
		end process;
		
		-- button logic
		process(clk,btn)
		begin
			if(rising_edge(clk)) then
				if (btn(3)='1') then
					reset <= '1';
				elsif (btn(0)='1') then
					if(debouncing='1') then
						send_character <= '1';
					end if;
				else
					reset <= '0';
					send_character <= '0';
				end if;
			end if;
		end process;
				
end top_arch;
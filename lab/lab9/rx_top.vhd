library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rx_top is
	generic(COUNTER_BIT: natural := 20);
	port(
		clk: in std_logic;
		seg : out std_logic_vector(6 downto 0);
		an : out std_logic_vector(3 downto 0) := "1100";		
		dp : out std_logic;
		rx_in : in std_logic;
		btn: in std_logic_vector(3 downto 0)
	);
end rx_top;

architecture top_arch of rx_top is
			
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
	
	component rx
		port(
			clk: in std_logic;
			rst: in std_logic;
			data_out: out std_logic_vector(7 downto 0);
			data_strobe: out std_logic;		
			rx_in: in std_logic;
			rx_busy:out std_logic
			
		);
	end component;
	
	signal reset: std_logic := '0';
	signal dp_in: std_logic_vector(3 downto 0) := "0000";
	signal blank4: std_logic_vector(3 downto 0) := (others=>'0');	
	signal data_out2: std_logic_vector(7 downto 0) := (others=>'0');
	signal data_strobe: std_logic;
	signal reg_left,reg_right: std_logic_vector(7 downto 0) := (others=>'0');
	signal delay_data1, delay_data2: std_logic;
	signal temp: std_logic_vector(15 downto 0) := (others=>'0');
	
	begin
		
		bottom_segment: seven_segment_display
		generic map(COUNTER_BITS=>15)
		port map(clk=>clk, an=>an, seg=>seg, dp=>dp, blank=>blank4,
					data_in=>temp, dp_in=>dp_in
				);
		
		bottom_rx: rx
		port map(clk=>clk, rst=>reset, data_out=>data_out2, 
					data_strobe=>data_strobe, rx_in=>delay_data2, rx_busy=>open
				);
		
		temp <= (reg_left & reg_right);
		
		process(clk)
		begin
			if(rising_edge(clk)) then
				delay_data1 <= rx_in;
				delay_data2 <= delay_data1;
				if(data_strobe='1') then
					reg_left <= reg_right;
					reg_right <= data_out2;
				end if;
			end if;
		end process;		
						
		-- button logic
		process(clk,btn)
		begin
			if(rising_edge(clk)) then
				reset <= '0';
				if (btn(3)='1') then
					reset <= '1';					
				end if;
			end if;
		end process;
				
end top_arch;
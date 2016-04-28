library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity charGen_top is
	port(
		clk: in std_logic;
		rgb: out std_logic_vector(7 downto 0);
		hs_out, vs_out: out std_logic;
		sw: in std_logic_vector(7 downto 0);
		seg : out std_logic_vector(6 downto 0);
		an : out std_logic_vector(3 downto 0) := "1100";		
		dp : out std_logic;
		btn: in std_logic_vector(3 downto 0)
	);
end charGen_top;

architecture top_charGen of charGen_top is
	
	component charGen
	port(
		clk: in std_logic;
		char_we: in std_logic;
		char_value: in std_logic_vector(7 downto 0);
		char_addr: in std_logic_vector(11 downto 0);
		pixel_x, pixel_y: in std_logic_vector(9 downto 0);
		pixel_out: out std_logic
	);
	end component;
	
	component vga_timing is
	port(
		clk, rst: in std_logic;
		HS, VS: out std_logic;
		pixel_x, pixel_y: out std_logic_vector(9 downto 0);
		last_column, last_row: out std_logic;
		blank: out std_logic
	);
	end component;
	
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

	
	signal temp_x,temp_y: std_logic_vector(9 downto 0);
	signal hs,vs: std_logic;
	signal temp_hs,temp_vs: std_logic := '0';
	signal reset: std_logic := '0';
	signal dp_in: std_logic_vector(3 downto 0) := "0000";
	signal blank4: std_logic_vector(3 downto 0) := (others=>'0');	
	signal data_in: std_logic_vector(15 downto 0) := (others=>'0');
	signal pixel_out: std_logic;
	signal count: natural := 0;
	signal count_next: natural;
	signal count_en: std_logic;
	signal char_we: std_logic;
	signal row_position, column_position: natural := 0;
	signal row_next, column_next: natural;
	signal row_en: std_logic;
	signal char_write_addr: std_logic_vector(11 downto 0) := (others=>'0');
	signal blank: std_logic := '0';
	signal font_color: unsigned(7 downto 0) := (others=>'1');
	signal back_color: unsigned(7 downto 0) := (others=>'0');

	begin
		bottom_level: vga_timing
		port map(clk=>clk, rst=>reset, pixel_x=>temp_x, pixel_y=>temp_y, blank=>blank,
					HS=>hs, VS=>vs, last_column=>open, last_row=>open
				);
		
		bottom_charGen: charGen
		port map(clk=>clk, char_we=>char_we, char_value=>sw, char_addr=>char_write_addr, pixel_x=>temp_x, pixel_y=>temp_y, pixel_out=>pixel_out
				);
		
		bottom_segment: seven_segment_display
		generic map(COUNTER_BITS=>15)
		port map(clk=>clk, an=>an, seg=>seg, dp=>dp, blank=>blank4,
					data_in=>data_in, dp_in=>dp_in
				);
		
		data_in <= "00000000" & sw;
		
		-- delaying counter
		process(clk)
		begin
			if(rising_edge(clk)) then
				count <= count_next;
			end if;
		end process;
		count_next <= 0 when count=400000 else
						  count + 1;
		count_en <= '1' when count=400000 else
						'0';
		
		-- row_position, column_position logic
		
		row_next <= row_position+1 when row_position < 30 else
						0;
		column_next <= column_position+1 when column_position < 79 else
						0;
		row_en <= '1' when column_position = 79 else
					 '0';
		char_write_addr <= std_logic_vector(to_unsigned(row_position,5)) & std_logic_vector(to_unsigned(column_position,7));

		-- color logic
		rgb <= std_logic_vector(font_color) when pixel_out='1' else
				 std_logic_vector(back_color);
		
		-- button logic
		process(clk,btn,count_en)
		begin
			if(rising_edge(clk)) then
				if (btn(3)='1') then
					reset <= '1';
					column_position <= 0;
					row_position <= 0;
				elsif (btn(0)='1') then
					if(count_en='1') then
						reset <= '0';
						char_we <= '1';
						column_position <= column_next;
						if(row_en='1') then
							row_position <= row_next;
							font_color <= font_color+1;
							if(row_position=0) then
								back_color <= back_color+1;
							end if;
						end if;
					else
						char_we <= '0';
					end if;				
				else
					reset <= '0';
				end if;
			end if;
		end process;
		
		-- making delays for HS, VS
		process(clk,hs,vs)
		begin
			if(rising_edge(clk)) then
				temp_hs <= hs;
				temp_vs <= vs;
				hs_out <= temp_hs;
				vs_out <= temp_vs;						
			end if;
		end process;
		
end top_charGen;
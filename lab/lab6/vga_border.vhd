library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_top is
	port(
		clk: in std_logic;
		red_out, green_out: out std_logic_vector(2 downto 0);
		blue_out: out std_logic_vector(1 downto 0);
		hs_out, vs_out: out std_logic;
		seg : out std_logic_vector(6 downto 0);
		an : out std_logic_vector(3 downto 0) := "0000";		
		dp : out std_logic;
		btn: in std_logic_vector(3 downto 0)
	);
end vga_top;

architecture top_arch of vga_top is
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
	
	component vga_timing
		port(
			clk, rst: in std_logic;
			HS, VS: out std_logic;
			pixel_x, pixel_y: out std_logic_vector(9 downto 0);
			last_column, last_row: out std_logic;
			blank: out std_logic
		);
	end component;
	
	signal pixel_x,pixel_y: unsigned(9 downto 0);
	signal temp_x,temp_y: std_logic_vector(9 downto 0);
	signal blank: std_logic;
	signal blank4: std_logic_vector(3 downto 0) := (others=>'0');
	signal lastcol, lastrow: std_logic;
	signal hs,vs: std_logic;
	signal reset: std_logic := '0';
	signal border_on: std_logic;
	signal red_disp, green_disp: std_logic_vector(2 downto 0);
	signal blue_disp: std_logic_vector(1 downto 0);
	signal box1_x_location: unsigned(9 downto 0) := "0000010100";
	signal box1_y_location: unsigned(9 downto 0) := "0000001010";
	signal box2_x_location: unsigned(9 downto 0) := "1001100110";
	signal box2_y_location: unsigned(9 downto 0) := "0000001010";
	signal square_x_location: unsigned(9 downto 0) := "0000001010";
	signal square_y_location: unsigned(9 downto 0) := "0000001010";
	
	signal moving_box1_on: std_logic;
	signal moving_box2_on: std_logic;
	signal square_on: std_logic;
	signal count: natural := 0;
	signal count_next: natural;
	signal count_en: std_logic;
	signal square_right: std_logic := '1';
	signal square_down: std_logic := '1';
	signal data_in: std_logic_vector(15 downto 0) := (others=>'0');
	signal dp_in: std_logic_vector(3 downto 0) := "0000";
	signal counter: unsigned(15 downto 0) := (others=>'0');
	
	begin
		bottom_level: vga_timing
		port map(clk=>clk, rst=>reset, pixel_x=>temp_x, pixel_y=>temp_y, blank=>blank,
					HS=>hs, VS=>vs, last_column=>lastcol, last_row=>lastrow
				);
		
		bottom_segment: seven_segment_display
		generic map(COUNTER_BITS=>15)
		port map(clk=>clk, an=>an, seg=>seg, dp=>dp, blank=>blank4,
					data_in=>data_in, dp_in=>dp_in
				);
		
		
		pixel_x <= unsigned(temp_x);
		pixel_y <= unsigned(temp_y);
		
		
		process(clk)
		begin
			if(rising_edge(clk)) then
				if(lastrow = '1' and lastcol = '1') then
					counter <= counter+1;
				end if;
			end if;
		end process;
		
		data_in <= std_logic_vector(counter);
		
		-- every clock cycle, outputs load new values
		process(clk)
		begin
			if (rising_edge(clk)) then
				hs_out <= hs;
				vs_out <= vs;
				red_out <= red_disp;
				green_out <= green_disp;
				blue_out <= blue_disp;
				
			end if;
		end process;		
		
		-- next sequential state logic
		process(clk)
		begin
			if(rising_edge(clk)) then
				count <= count_next;
			end if;
		end process;
		count_next <= 0 when count=200000 else
						  count + 1;
		count_en <= '1' when count_next=200000 else
						'0';
		
		process(clk)
		begin
			if(rising_edge(clk)) then
				if(count_en = '1') then
					if(btn(3) = '1') then
						if(box1_y_location>10) then
							box1_y_location <= box1_y_location-1;
						else
							box1_y_location <= box1_y_location;
						end if;
					end if;
					if(btn(2) = '1') then
						if(box1_y_location<420) then
							box1_y_location <= box1_y_location+1;
						else
							box1_y_location <= box1_y_location;
						end if;
					end if;

					if(btn(1) = '1') then
						if(box2_y_location>10) then
							box2_y_location <= box2_y_location-1;
						else
							box2_y_location <= box2_y_location;
						end if;
					end if;
					if(btn(0) = '1') then
						if(box2_y_location<420) then
							box2_y_location <= box2_y_location+1;
						else
							box2_y_location <= box2_y_location;
						end if;
					end if;
					
					if(square_x_location < 10) then
						square_right <= '1';
					elsif(square_x_location >= 625) then
						square_right <= '0';
					end if;
					if(square_y_location < 10) then
						square_down <= '1';
					elsif(square_y_location >= 465) then
						square_down <= '0';
					end if;
					
					if(square_right='1' and square_down='1') then
						square_x_location <= square_x_location+1;
						square_y_location <= square_y_location+1;
					elsif(square_right='1' and square_down='0') then
						square_x_location <= square_x_location+1;
						square_y_location <= square_y_location-1;
					elsif(square_right='0' and square_down='1') then
						square_x_location <= square_x_location-1;
						square_y_location <= square_y_location+1;
					elsif(square_right='0' and square_down='0') then
						square_x_location <= square_x_location-1;
						square_y_location <= square_y_location-1;
					end if;
				end if;
			end if;
		end process;
		
			
		-- next concurrent state logic
		moving_box1_on <= '1' when pixel_x >= box1_x_location and
										  pixel_x <  box1_x_location+7 and
										  pixel_y >= box1_y_location and
										  pixel_y < box1_y_location+50 else
								'0';
		
		moving_box2_on <= '1' when pixel_x >= box2_x_location and
										  pixel_x < box2_x_location+7 and
										  pixel_y >= box2_y_location and
										  pixel_y < box2_y_location+50 else
								'0';
		square_on <= '1' when pixel_x >= square_x_location and
									 pixel_x <  square_x_location+5 and
									 pixel_y >= square_y_location and
									 pixel_y < square_y_location+5 else
						 '0';
			
		border_on <= '1' when (pixel_x<10 or pixel_x>=630 or pixel_y<10 or pixel_y>=470) else
						 '0';
		red_disp <= "111" when (border_on = '1') and (blank = '0') else
						"111" when moving_box1_on = '1' else
						"000" when moving_box2_on = '1' else
						"111" when square_on = '1' else
						"000";
		green_disp <= "111" when moving_box1_on = '1' else
						  "111" when moving_box2_on = '1' else
						  "111" when square_on = '1' else
						  "000";
		blue_disp <= "00" when moving_box1_on = '1' else
						 "00" when moving_box2_on = '1' else
						 "11" when square_on = '1' else
						 "00";
				
end top_arch;
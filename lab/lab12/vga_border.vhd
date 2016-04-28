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
		btn: in std_logic_vector(3 downto 0);
		light_out: out std_logic
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
	signal box1_x_location: unsigned(9 downto 0) := "0100100111";
	signal box1_y_location: unsigned(9 downto 0) := "0111000010";
	signal square_x_location: unsigned(9 downto 0) := "0100100111";
	signal square_y_location: unsigned(9 downto 0) := "0011000010";
	
	signal moving_box1_on: std_logic;
	signal square_on: std_logic;
	signal paddle_count: natural := 0;
	signal paddle_count_next: natural;
	signal paddle_count_en: std_logic;
	
	signal ball_count: natural := 0;
	signal ball_count_next: natural;
	signal ball_count_en: std_logic;
		
	signal data_in: std_logic_vector(15 downto 0) := (others=>'0');
	signal dp_in: std_logic_vector(3 downto 0) := "0000";
	signal counter: unsigned(15 downto 0) := (others=>'0');
	
	--brick layout
	signal brick_0_0_on, brick_1_0_on, brick_2_0_on, brick_3_0_on, brick_4_0_on: std_logic;
	signal brick_5_0_on, brick_6_0_on, brick_7_0_on, brick_8_0_on, brick_9_0_on: std_logic;
	signal brick_0_1_on, brick_1_1_on, brick_2_1_on, brick_3_1_on, brick_4_1_on: std_logic;
	signal brick_5_1_on, brick_6_1_on, brick_7_1_on, brick_8_1_on, brick_9_1_on: std_logic;
	signal brick_0_2_on, brick_1_2_on, brick_2_2_on, brick_3_2_on, brick_4_2_on: std_logic;
	signal brick_5_2_on, brick_6_2_on, brick_7_2_on, brick_8_2_on, brick_9_2_on: std_logic;
	signal brick_0_3_on, brick_1_3_on, brick_2_3_on, brick_3_3_on, brick_4_3_on: std_logic;
	signal brick_5_3_on, brick_6_3_on, brick_7_3_on, brick_8_3_on, brick_9_3_on: std_logic;
	signal brick_0_4_on, brick_1_4_on, brick_2_4_on, brick_3_4_on, brick_4_4_on: std_logic;
	signal brick_5_4_on, brick_6_4_on, brick_7_4_on, brick_8_4_on, brick_9_4_on: std_logic;
	signal brick_0_5_on, brick_1_5_on, brick_2_5_on, brick_3_5_on, brick_4_5_on: std_logic;
	signal brick_5_5_on, brick_6_5_on, brick_7_5_on, brick_8_5_on, brick_9_5_on: std_logic;
	signal brick_0_6_on, brick_1_6_on, brick_2_6_on, brick_3_6_on, brick_4_6_on: std_logic;
	signal brick_5_6_on, brick_6_6_on, brick_7_6_on, brick_8_6_on, brick_9_6_on: std_logic;

	signal brick_0_0_off, brick_1_0_off, brick_2_0_off, brick_3_0_off, brick_4_0_off: std_logic := '0';
	signal brick_5_0_off, brick_6_0_off, brick_7_0_off, brick_8_0_off, brick_9_0_off: std_logic := '0';
	signal brick_0_1_off, brick_1_1_off, brick_2_1_off, brick_3_1_off, brick_4_1_off: std_logic := '0';
	signal brick_5_1_off, brick_6_1_off, brick_7_1_off, brick_8_1_off, brick_9_1_off: std_logic := '0';
	signal brick_0_2_off, brick_1_2_off, brick_2_2_off, brick_3_2_off, brick_4_2_off: std_logic := '0';
	signal brick_5_2_off, brick_6_2_off, brick_7_2_off, brick_8_2_off, brick_9_2_off: std_logic := '0';
	signal brick_0_3_off, brick_1_3_off, brick_2_3_off, brick_3_3_off, brick_4_3_off: std_logic := '0';
	signal brick_5_3_off, brick_6_3_off, brick_7_3_off, brick_8_3_off, brick_9_3_off: std_logic := '0';
	signal brick_0_4_off, brick_1_4_off, brick_2_4_off, brick_3_4_off, brick_4_4_off: std_logic := '0';
	signal brick_5_4_off, brick_6_4_off, brick_7_4_off, brick_8_4_off, brick_9_4_off: std_logic := '0';
	signal brick_0_5_off, brick_1_5_off, brick_2_5_off, brick_3_5_off, brick_4_5_off: std_logic := '0';
	signal brick_5_5_off, brick_6_5_off, brick_7_5_off, brick_8_5_off, brick_9_5_off: std_logic := '0';
	signal brick_0_6_off, brick_1_6_off, brick_2_6_off, brick_3_6_off, brick_4_6_off: std_logic := '0';
	signal brick_5_6_off, brick_6_6_off, brick_7_6_off, brick_8_6_off, brick_9_6_off: std_logic := '0';

	signal red_brick, orange_brick, yellow_brick : std_logic_vector(7 downto 0);
	signal green_brick, blue_brick, indigo_brick, violet_brick : std_logic_vector(7 downto 0);
	signal brick_color: std_logic_vector(7 downto 0) := (others=>'0');
	
	signal score: unsigned(15 downto 0) := (others=>'0');
	
	type direction is
		(up_right_30, up_right_45, up_right_60, up_left_30, up_left_45, up_left_60, 
			down_left_30, down_left_45, down_left_60, down_right_30, down_right_45, down_right_60, freeze);
	signal current_direction: direction := up_right_45;
	signal start, start_next: std_logic := '0';
	
	signal light: std_logic := '0';
	
--function in architecure declarations
	function get_vert_direction(old_direction: direction) return direction is
		variable new_direction: direction;
	begin
		new_direction := current_direction;
		if(old_direction = up_right_30) then
			new_direction := down_right_30;
		elsif(old_direction = up_right_45) then
			new_direction := down_right_45;
		elsif(old_direction = up_right_60) then
			new_direction := down_right_60;
		elsif(old_direction = up_left_30) then
			new_direction := down_left_30;
		elsif(old_direction = up_left_45) then
			new_direction := down_left_45;
		elsif(old_direction = up_left_60) then
			new_direction := down_left_60;
		elsif(old_direction = down_right_30) then
			new_direction := up_right_30;
		elsif(old_direction = down_right_45) then
			new_direction := up_right_45;
		elsif(old_direction = down_right_60) then
			new_direction := up_right_60;
		elsif(old_direction = down_left_30) then
			new_direction := up_left_30;
		elsif(old_direction = down_left_45) then
			new_direction := up_left_45;
		elsif(old_direction = down_left_60) then
			new_direction := up_left_60;
		end if;
		return new_direction;
	end get_vert_direction;	
	
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
		
		data_in <= std_logic_vector(score);
		
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
		
		-- paddle counter
		process(clk)
		begin
			if(rising_edge(clk)) then
				paddle_count <= paddle_count_next;
			end if;
		end process;
		paddle_count_next <= 0 when paddle_count=200000 else
									paddle_count + 1;
		paddle_count_en <= '1' when paddle_count_next = 200000 else
								 '0';
		-- ball counter
		process(clk)
		begin
			if(rising_edge(clk)) then
				start <= start_next;
				if(start='1') then
					ball_count <= ball_count_next;
				end if;
				if(btn(0)='1') then
					start <= '1';
				end if;
				if(btn(1)='1') then
					start <= '0';
				end if;
			end if;
		end process;
		
		light_out <= start;
		
		ball_count_next <= 0 when ball_count=300000 else
								 ball_count + 1;
		ball_count_en <= '1' when ball_count_next = 300000 else
								 '0';
				
		
		-- ball moving logic
		process(clk,start)
		begin
			if(rising_edge(clk)) then
				if(start='0') then
					square_x_location <= "0100100111";
					square_y_location <= "0011000010";
					current_direction <= up_right_45;
					start_next <= '0';
					
					score <= (others=>'0');
					
					brick_0_0_off <= '0';
					brick_1_0_off <= '0';
					brick_2_0_off <= '0';
					brick_3_0_off <= '0';
					brick_4_0_off <= '0';
					brick_5_0_off <= '0';
					brick_6_0_off <= '0';
					brick_7_0_off <= '0';
					brick_8_0_off <= '0';
					brick_9_0_off <= '0';
					brick_0_1_off <= '0';
					brick_1_1_off <= '0';
					brick_2_1_off <= '0';
					brick_3_1_off <= '0';
					brick_4_1_off <= '0';
					brick_5_1_off <= '0';
					brick_6_1_off <= '0';
					brick_7_1_off <= '0';
					brick_8_1_off <= '0';
					brick_9_1_off <= '0';
					brick_0_2_off <= '0';
					brick_1_2_off <= '0';
					brick_2_2_off <= '0';
					brick_3_2_off <= '0';
					brick_4_2_off <= '0';
					brick_5_2_off <= '0';
					brick_6_2_off <= '0';
					brick_7_2_off <= '0';
					brick_8_2_off <= '0';
					brick_9_2_off <= '0';
					brick_0_3_off <= '0';
					brick_1_3_off <= '0';
					brick_2_3_off <= '0';
					brick_3_3_off <= '0';
					brick_4_3_off <= '0';
					brick_5_3_off <= '0';
					brick_6_3_off <= '0';
					brick_7_3_off <= '0';
					brick_8_3_off <= '0';
					brick_9_3_off <= '0';
					brick_0_4_off <= '0';
					brick_1_4_off <= '0';
					brick_2_4_off <= '0';
					brick_3_4_off <= '0';
					brick_4_4_off <= '0';
					brick_5_4_off <= '0';
					brick_6_4_off <= '0';
					brick_7_4_off <= '0';
					brick_8_4_off <= '0';
					brick_9_4_off <= '0';
					brick_0_5_off <= '0';
					brick_1_5_off <= '0';
					brick_2_5_off <= '0';
					brick_3_5_off <= '0';
					brick_4_5_off <= '0';
					brick_5_5_off <= '0';
					brick_6_5_off <= '0';
					brick_7_5_off <= '0';
					brick_8_5_off <= '0';
					brick_9_5_off <= '0';
					brick_0_6_off <= '0';
					brick_1_6_off <= '0';
					brick_2_6_off <= '0';
					brick_3_6_off <= '0';
					brick_4_6_off <= '0';
					brick_5_6_off <= '0';
					brick_6_6_off <= '0';
					brick_7_6_off <= '0';
					brick_8_6_off <= '0';
					brick_9_6_off <= '0';
				else
					start_next <= '1';
					if(ball_count_en = '1') then
				
						--add to process with ball_on				
						if (square_y_location >= 127 and square_y_location <= 148) then
							if (square_x_location >= 7 and square_x_location <= 70) then
								if (brick_0_6_off = '0') then
									brick_0_6_off <= '1';
									score <= score+1;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 69 and square_x_location <= 132) then
								if (brick_1_6_off = '0') then
									brick_1_6_off <= '1';
									score <= score+1;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 131 and square_x_location <= 194) then
								if (brick_2_6_off = '0') then
									brick_2_6_off <= '1';
									score <= score+1;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 193 and square_x_location <= 256) then
								if (brick_3_6_off = '0') then
									brick_3_6_off <= '1';
									score <= score+1;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 255 and square_x_location <= 318) then
								if (brick_4_6_off = '0') then
									brick_4_6_off <= '1';
									score <= score+1;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 317 and square_x_location <= 380) then
								if (brick_5_6_off = '0') then
									brick_5_6_off <= '1';
									score <= score+1;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 379 and square_x_location <= 442) then
								if (brick_6_6_off = '0') then
									brick_6_6_off <= '1';
									score <= score+1;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 441 and square_x_location <= 504) then
								if (brick_7_6_off = '0') then
									brick_7_6_off <= '1';
									score <= score+1;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 503 and square_x_location <= 566) then
								if (brick_8_6_off = '0') then
									brick_8_6_off <= '1';
									score <= score+1;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 565 and square_x_location <= 628) then
								if (brick_9_6_off = '0') then
									brick_9_6_off <= '1';
									score <= score+1;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
						end if;
						if (square_y_location >= 107 and square_y_location <= 128) then
							if (square_x_location >= 7 and square_x_location <= 70) then
								if (brick_0_5_off = '0') then
									brick_0_5_off <= '1';
									score <= score+2;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 69 and square_x_location <= 132) then
								if (brick_1_5_off = '0') then
									brick_1_5_off <= '1';
									score <= score+2;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 131 and square_x_location <= 194) then
								if (brick_2_5_off = '0') then
									brick_2_5_off <= '1';
									score <= score+2;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 193 and square_x_location <= 256) then
								if (brick_3_5_off = '0') then
									brick_3_5_off <= '1';
									score <= score+2;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 255 and square_x_location <= 318) then
								if (brick_4_5_off = '0') then
									brick_4_5_off <= '1';
									score <= score+2;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 317 and square_x_location <= 380) then
								if (brick_5_5_off = '0') then
									brick_5_5_off <= '1';
									score <= score+2;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 379 and square_x_location <= 442) then
								if (brick_6_5_off = '0') then
									brick_6_5_off <= '1';
									score <= score+2;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 441 and square_x_location <= 504) then
								if (brick_7_5_off = '0') then
									brick_7_5_off <= '1';
									score <= score+2;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 503 and square_x_location <= 566) then
								if (brick_8_5_off = '0') then
									brick_8_5_off <= '1';
									score <= score+2;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 565 and square_x_location <= 628) then
								if (brick_9_5_off = '0') then
									brick_9_5_off <= '1';
									score <= score+2;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
						end if;
						if (square_y_location >= 87 and square_y_location <= 108) then
							if (square_x_location >= 7 and square_x_location <= 70) then
								if (brick_0_4_off = '0') then
									brick_0_4_off <= '1';
									score <= score+4;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 69 and square_x_location <= 132) then
								if (brick_1_4_off = '0') then
									brick_1_4_off <= '1';
									score <= score+4;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 131 and square_x_location <= 194) then
								if (brick_2_4_off = '0') then
									brick_2_4_off <= '1';
									score <= score+4;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 193 and square_x_location <= 256) then
								if (brick_3_4_off = '0') then
									brick_3_4_off <= '1';
									score <= score+4;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 255 and square_x_location <= 318) then
								if (brick_4_4_off = '0') then
									brick_4_4_off <= '1';
									score <= score+4;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 317 and square_x_location <= 380) then
								if (brick_5_4_off = '0') then
									brick_5_4_off <= '1';
									score <= score+4;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 379 and square_x_location <= 442) then
								if (brick_6_4_off = '0') then
									brick_6_4_off <= '1';
									score <= score+4;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 441 and square_x_location <= 504) then
								if (brick_7_4_off = '0') then
									brick_7_4_off <= '1';
									score <= score+4;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 503 and square_x_location <= 566) then
								if (brick_8_4_off = '0') then
									brick_8_4_off <= '1';
									score <= score+4;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 565 and square_x_location <= 628) then
								if (brick_9_4_off = '0') then
									brick_9_4_off <= '1';
									score <= score+4;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
						end if;
						if (square_y_location >= 67 and square_y_location <= 88) then
							if (square_x_location >= 7 and square_x_location <= 70) then
								if (brick_0_3_off = '0') then
									brick_0_3_off <= '1';
									score <= score+8;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 69 and square_x_location <= 132) then
								if (brick_1_3_off = '0') then
									brick_1_3_off <= '1';
									score <= score+8;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 131 and square_x_location <= 194) then
								if (brick_2_3_off = '0') then
									brick_2_3_off <= '1';
									score <= score+8;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 193 and square_x_location <= 256) then
								if (brick_3_3_off = '0') then
									brick_3_3_off <= '1';
									score <= score+8;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 255 and square_x_location <= 318) then
								if (brick_4_3_off = '0') then
									brick_4_3_off <= '1';
									score <= score+8;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 317 and square_x_location <= 380) then
								if (brick_5_3_off = '0') then
									brick_5_3_off <= '1';
									score <= score+8;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 379 and square_x_location <= 442) then
								if (brick_6_3_off = '0') then
									brick_6_3_off <= '1';
									score <= score+8;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 441 and square_x_location <= 504) then
								if (brick_7_3_off = '0') then
									brick_7_3_off <= '1';
									score <= score+8;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 503 and square_x_location <= 566) then
								if (brick_8_3_off = '0') then
									brick_8_3_off <= '1';
									score <= score+8;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 565 and square_x_location <= 628) then
								if (brick_9_3_off = '0') then
									brick_9_3_off <= '1';
									score <= score+8;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
						end if;
						if (square_y_location >= 47 and square_y_location <= 68) then
							if (square_x_location >= 7 and square_x_location <= 70) then
								if (brick_0_2_off = '0') then
									brick_0_2_off <= '1';
									score <= score+16;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 69 and square_x_location <= 132) then
								if (brick_1_2_off = '0') then
									brick_1_2_off <= '1';
									score <= score+16;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 131 and square_x_location <= 194) then
								if (brick_2_2_off = '0') then
									brick_2_2_off <= '1';
									score <= score+16;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 193 and square_x_location <= 256) then
								if (brick_3_2_off = '0') then
									brick_3_2_off <= '1';
									score <= score+16;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 255 and square_x_location <= 318) then
								if (brick_4_2_off = '0') then
									brick_4_2_off <= '1';
									score <= score+16;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 317 and square_x_location <= 380) then
								if (brick_5_2_off = '0') then
									brick_5_2_off <= '1';
									score <= score+16;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 379 and square_x_location <= 442) then
								if (brick_6_2_off = '0') then
									brick_6_2_off <= '1';
									score <= score+16;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 441 and square_x_location <= 504) then
								if (brick_7_2_off = '0') then
									brick_7_2_off <= '1';
									score <= score+16;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 503 and square_x_location <= 566) then
								if (brick_8_2_off = '0') then
									brick_8_2_off <= '1';
									score <= score+16;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 565 and square_x_location <= 628) then
								if (brick_9_2_off = '0') then
									brick_9_2_off <= '1';
									score <= score+16;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
						end if;
						if (square_y_location >= 27 and square_y_location <= 48) then
							if (square_x_location >= 7 and square_x_location <= 70) then
								if (brick_0_1_off = '0') then
									brick_0_1_off <= '1';
									score <= score+32;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 69 and square_x_location <= 132) then
								if (brick_1_1_off = '0') then
									brick_1_1_off <= '1';
									score <= score+32;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 131 and square_x_location <= 194) then
								if (brick_2_1_off = '0') then
									brick_2_1_off <= '1';
									score <= score+32;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 193 and square_x_location <= 256) then
								if (brick_3_1_off = '0') then
									brick_3_1_off <= '1';
									score <= score+32;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 255 and square_x_location <= 318) then
								if (brick_4_1_off = '0') then
									brick_4_1_off <= '1';
									score <= score+32;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 317 and square_x_location <= 380) then
								if (brick_5_1_off = '0') then
									brick_5_1_off <= '1';
									score <= score+32;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 379 and square_x_location <= 442) then
								if (brick_6_1_off = '0') then
									brick_6_1_off <= '1';
									score <= score+32;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 441 and square_x_location <= 504) then
								if (brick_7_1_off = '0') then
									brick_7_1_off <= '1';
									score <= score+32;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 503 and square_x_location <= 566) then
								if (brick_8_1_off = '0') then
									brick_8_1_off <= '1';
									score <= score+32;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 565 and square_x_location <= 628) then
								if (brick_9_1_off = '0') then
									brick_9_1_off <= '1';
									score <= score+32;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
						end if;
						if (square_y_location >= 7 and square_y_location <= 28) then
							if (square_x_location >= 7 and square_x_location <= 70) then
								if (brick_0_0_off = '0') then
									brick_0_0_off <= '1';
									score <= score+64;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 69 and square_x_location <= 132) then
								if (brick_1_0_off = '0') then
									brick_1_0_off <= '1';
									score <= score+64;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 131 and square_x_location <= 194) then
								if (brick_2_0_off = '0') then
									brick_2_0_off <= '1';
									score <= score+64;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 193 and square_x_location <= 256) then
								if (brick_3_0_off = '0') then
									brick_3_0_off <= '1';
									score <= score+64;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 255 and square_x_location <= 318) then
								if (brick_4_0_off = '0') then
									brick_4_0_off <= '1';
									score <= score+64;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 317 and square_x_location <= 380) then
								if (brick_5_0_off = '0') then
									brick_5_0_off <= '1';
									score <= score+64;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 379 and square_x_location <= 442) then
								if (brick_6_0_off = '0') then
									brick_6_0_off <= '1';
									score <= score+64;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 441 and square_x_location <= 504) then
								if (brick_7_0_off = '0') then
									brick_7_0_off <= '1';
									score <= score+64;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 503 and square_x_location <= 566) then
								if (brick_8_0_off = '0') then
									brick_8_0_off <= '1';
									score <= score+64;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
							if (square_x_location >= 565 and square_x_location <= 628) then
								if (brick_9_0_off = '0') then
									brick_9_0_off <= '1';
									score <= score+64;
									current_direction <= get_vert_direction(current_direction);
								end if;
							end if;
						end if;
					
						-- left wall
						if(square_x_location < 10) then
							if(current_direction = up_left_30) then
								current_direction <= up_right_30;
							elsif(current_direction = up_left_45) then
								current_direction <= up_right_45;
							elsif(current_direction = up_left_60) then
								current_direction <= up_right_60;
							elsif(current_direction = down_left_30) then
								current_direction <= down_right_30;
							elsif(current_direction = down_left_45) then
								current_direction <= down_right_45;
							elsif(current_direction = down_left_60) then
								current_direction <= down_right_60;
							end if;
							
						-- right wall
						elsif(square_x_location >= 625) then
							if(current_direction = up_right_30) then
								current_direction <= up_left_30;
							elsif(current_direction = up_right_45) then
								current_direction <= up_left_45;
							elsif(current_direction = up_right_60) then
								current_direction <= up_left_60;
							elsif(current_direction = down_right_30) then
								current_direction <= down_left_30;
							elsif(current_direction = down_right_45) then
								current_direction <= down_left_45;
							elsif(current_direction = down_right_60) then
								current_direction <= down_left_60;							
							end if;
						end if;
						
						-- ceiling
						if(square_y_location < 10) then
							if(current_direction = up_right_30) then
								current_direction <= down_right_30;
							elsif(current_direction = up_right_45) then
								current_direction <= down_right_45;
							elsif(current_direction = up_right_60) then
								current_direction <= down_right_60;
							elsif(current_direction = up_left_30) then
								current_direction <= down_left_30;
							elsif(current_direction = up_left_45) then
								current_direction <= down_left_45;
							elsif(current_direction = up_left_60) then
								current_direction <= down_left_60;
							end if;
						
						-- bottom
						elsif(square_y_location >= 465) then
							current_direction <= freeze;
							start_next <= '0';
							
						
						-- paddle
						elsif(square_y_location >= 445 and square_x_location > box1_x_location and square_x_location < box1_x_location+55) then
							if(square_x_location < box1_x_location+7) then
								current_direction <= up_left_30;
							elsif(square_x_location >= box1_x_location+7 and square_x_location < box1_x_location+17) then
								current_direction <= up_left_45;
							elsif(square_x_location >= box1_x_location+17 and square_x_location < box1_x_location+27) then
								current_direction <= up_left_60;
							elsif(square_x_location >= box1_x_location+27 and square_x_location < box1_x_location+37) then
								current_direction <= up_right_60;
							elsif(square_x_location >= box1_x_location+37 and square_x_location < box1_x_location+47) then
								current_direction <= up_right_45;
							elsif(square_x_location >= box1_x_location+47 and square_x_location < box1_x_location+55) then
								current_direction <= up_right_30;
							end if;
						end if;

						if(current_direction = up_right_30) then
							square_x_location <= square_x_location+2;
							square_y_location <= square_y_location-1;
						elsif(current_direction = up_right_45) then
							square_x_location <= square_x_location+1;
							square_y_location <= square_y_location-1;
						elsif(current_direction = up_right_60) then
							square_x_location <= square_x_location+1;
							square_y_location <= square_y_location-2;
						elsif(current_direction = up_left_30) then
							square_x_location <= square_x_location-2;
							square_y_location <= square_y_location-1;
						elsif(current_direction = up_left_45) then
							square_x_location <= square_x_location-1;
							square_y_location <= square_y_location-1;
						elsif(current_direction = up_left_60) then
							square_x_location <= square_x_location-1;
							square_y_location <= square_y_location-2;
						elsif(current_direction = down_right_30) then
							square_x_location <= square_x_location+2;
							square_y_location <= square_y_location+1;
						elsif(current_direction = down_right_45) then
							square_x_location <= square_x_location+1;
							square_y_location <= square_y_location+1;
						elsif(current_direction = down_right_60) then
							square_x_location <= square_x_location+1;
							square_y_location <= square_y_location+2;
						elsif(current_direction = down_left_30) then
							square_x_location <= square_x_location-2;
							square_y_location <= square_y_location+1;
						elsif(current_direction = down_left_45) then
							square_x_location <= square_x_location-1;
							square_y_location <= square_y_location+1;
						elsif(current_direction = down_left_60) then
							square_x_location <= square_x_location-1;
							square_y_location <= square_y_location+2;
						elsif(current_direction = freeze) then
							square_x_location <= square_x_location;
							square_y_location <= square_y_location;
						end if;
					end if;
				end if;
			end if;
		end process;
		
		-- paddle location logic
		process(clk)
		begin
			if(rising_edge(clk)) then
				if(paddle_count_en = '1') then
					if(btn(3) = '1') then
						if(box1_x_location>10) then
							box1_x_location <= box1_x_location-1;
						else
							box1_x_location <= box1_x_location;
						end if;
					end if;
					if(btn(2) = '1') then
						if(box1_x_location<579) then
							box1_x_location <= box1_x_location+1;
						else
							box1_x_location <= box1_x_location;
						end if;
					end if;
				end if;
			end if;
		end process;
		
		--brick layout--
	red_brick <= "11100000";
	orange_brick <= "11110000";
	yellow_brick <= "11111100";
	green_brick <= "00011100";
	blue_brick <= "00000011";
	indigo_brick <= "00100011";
	violet_brick <= "01100011";

	--First row
	brick_0_0_on <= '1' when pixel_x >= 12 and pixel_x < 70 and pixel_y >= 12 and pixel_y < 28 else '0';
	brick_1_0_on <= '1' when pixel_x >= 74 and pixel_x < 132 and pixel_y >= 12 and pixel_y < 28 else '0';
	brick_2_0_on <= '1' when pixel_x >= 136 and pixel_x < 194 and pixel_y >= 12 and pixel_y < 28 else '0';
	brick_3_0_on <= '1' when pixel_x >= 198 and pixel_x < 256 and pixel_y >= 12 and pixel_y < 28 else '0';
	brick_4_0_on <= '1' when pixel_x >= 260 and pixel_x < 318 and pixel_y >= 12 and pixel_y < 28 else '0';
	brick_5_0_on <= '1' when pixel_x >= 322 and pixel_x < 380 and pixel_y >= 12 and pixel_y < 28 else '0';
	brick_6_0_on <= '1' when pixel_x >= 384 and pixel_x < 442 and pixel_y >= 12 and pixel_y < 28 else '0';
	brick_7_0_on <= '1' when pixel_x >= 446 and pixel_x < 504 and pixel_y >= 12 and pixel_y < 28 else '0';
	brick_8_0_on <= '1' when pixel_x >= 508 and pixel_x < 566 and pixel_y >= 12 and pixel_y < 28 else '0';
	brick_9_0_on <= '1' when pixel_x >= 570 and pixel_x < 628 and pixel_y >= 12 and pixel_y < 28 else '0';
	
	--Second row
	brick_0_1_on <= '1' when pixel_x >= 12 and pixel_x < 70 and pixel_y >= 32 and pixel_y < 48 else '0';
	brick_1_1_on <= '1' when pixel_x >= 74 and pixel_x < 132 and pixel_y >= 32 and pixel_y < 48 else '0';
	brick_2_1_on <= '1' when pixel_x >= 136 and pixel_x < 194 and pixel_y >= 32 and pixel_y < 48 else '0';
	brick_3_1_on <= '1' when pixel_x >= 198 and pixel_x < 256 and pixel_y >= 32 and pixel_y < 48 else '0';
	brick_4_1_on <= '1' when pixel_x >= 260 and pixel_x < 318 and pixel_y >= 32 and pixel_y < 48 else '0';
	brick_5_1_on <= '1' when pixel_x >= 322 and pixel_x < 380 and pixel_y >= 32 and pixel_y < 48 else '0';
	brick_6_1_on <= '1' when pixel_x >= 384 and pixel_x < 442 and pixel_y >= 32 and pixel_y < 48 else '0';
	brick_7_1_on <= '1' when pixel_x >= 446 and pixel_x < 504 and pixel_y >= 32 and pixel_y < 48 else '0';
	brick_8_1_on <= '1' when pixel_x >= 508 and pixel_x < 566 and pixel_y >= 32 and pixel_y < 48 else '0';
	brick_9_1_on <= '1' when pixel_x >= 570 and pixel_x < 628 and pixel_y >= 32 and pixel_y < 48 else '0';
	
	--Third row
	brick_0_2_on <= '1' when pixel_x >= 12 and pixel_x < 70 and pixel_y >= 52 and pixel_y < 68 else '0';
	brick_1_2_on <= '1' when pixel_x >= 74 and pixel_x < 132 and pixel_y >= 52 and pixel_y < 68 else '0';
	brick_2_2_on <= '1' when pixel_x >= 136 and pixel_x < 194 and pixel_y >= 52 and pixel_y < 68 else '0';
	brick_3_2_on <= '1' when pixel_x >= 198 and pixel_x < 256 and pixel_y >= 52 and pixel_y < 68 else '0';
	brick_4_2_on <= '1' when pixel_x >= 260 and pixel_x < 318 and pixel_y >= 52 and pixel_y < 68 else '0';
	brick_5_2_on <= '1' when pixel_x >= 322 and pixel_x < 380 and pixel_y >= 52 and pixel_y < 68 else '0';
	brick_6_2_on <= '1' when pixel_x >= 384 and pixel_x < 442 and pixel_y >= 52 and pixel_y < 68 else '0';
	brick_7_2_on <= '1' when pixel_x >= 446 and pixel_x < 504 and pixel_y >= 52 and pixel_y < 68 else '0';
	brick_8_2_on <= '1' when pixel_x >= 508 and pixel_x < 566 and pixel_y >= 52 and pixel_y < 68 else '0';
	brick_9_2_on <= '1' when pixel_x >= 570 and pixel_x < 628 and pixel_y >= 52 and pixel_y < 68 else '0';	
	
	--Fourth row
	brick_0_3_on <= '1' when pixel_x >= 12 and pixel_x < 70 and pixel_y >= 72 and pixel_y < 88 else '0';
	brick_1_3_on <= '1' when pixel_x >= 74 and pixel_x < 132 and pixel_y >= 72 and pixel_y < 88 else '0';
	brick_2_3_on <= '1' when pixel_x >= 136 and pixel_x < 194 and pixel_y >= 72 and pixel_y < 88 else '0';
	brick_3_3_on <= '1' when pixel_x >= 198 and pixel_x < 256 and pixel_y >= 72 and pixel_y < 88 else '0';
	brick_4_3_on <= '1' when pixel_x >= 260 and pixel_x < 318 and pixel_y >= 72 and pixel_y < 88 else '0';
	brick_5_3_on <= '1' when pixel_x >= 322 and pixel_x < 380 and pixel_y >= 72 and pixel_y < 88 else '0';
	brick_6_3_on <= '1' when pixel_x >= 384 and pixel_x < 442 and pixel_y >= 72 and pixel_y < 88 else '0';
	brick_7_3_on <= '1' when pixel_x >= 446 and pixel_x < 504 and pixel_y >= 72 and pixel_y < 88 else '0';
	brick_8_3_on <= '1' when pixel_x >= 508 and pixel_x < 566 and pixel_y >= 72 and pixel_y < 88 else '0';
	brick_9_3_on <= '1' when pixel_x >= 570 and pixel_x < 628 and pixel_y >= 72 and pixel_y < 88 else '0';
	
	--Fifth row
	brick_0_4_on <= '1' when pixel_x >= 12 and pixel_x < 70 and pixel_y >= 92 and pixel_y < 108 else '0';
	brick_1_4_on <= '1' when pixel_x >= 74 and pixel_x < 132 and pixel_y >= 92 and pixel_y < 108 else '0';
	brick_2_4_on <= '1' when pixel_x >= 136 and pixel_x < 194 and pixel_y >= 92 and pixel_y < 108 else '0';
	brick_3_4_on <= '1' when pixel_x >= 198 and pixel_x < 256 and pixel_y >= 92 and pixel_y < 108 else '0';
	brick_4_4_on <= '1' when pixel_x >= 260 and pixel_x < 318 and pixel_y >= 92 and pixel_y < 108 else '0';
	brick_5_4_on <= '1' when pixel_x >= 322 and pixel_x < 380 and pixel_y >= 92 and pixel_y < 108 else '0';
	brick_6_4_on <= '1' when pixel_x >= 384 and pixel_x < 442 and pixel_y >= 92 and pixel_y < 108 else '0';
	brick_7_4_on <= '1' when pixel_x >= 446 and pixel_x < 504 and pixel_y >= 92 and pixel_y < 108 else '0';
	brick_8_4_on <= '1' when pixel_x >= 508 and pixel_x < 566 and pixel_y >= 92 and pixel_y < 108 else '0';
	brick_9_4_on <= '1' when pixel_x >= 570 and pixel_x < 628 and pixel_y >= 92 and pixel_y < 108 else '0';
	
	--Sixth row
	brick_0_5_on <= '1' when pixel_x >= 12 and pixel_x < 70 and pixel_y >= 112 and pixel_y < 128 else '0';
	brick_1_5_on <= '1' when pixel_x >= 74 and pixel_x < 132 and pixel_y >= 112 and pixel_y < 128 else '0';
	brick_2_5_on <= '1' when pixel_x >= 136 and pixel_x < 194 and pixel_y >= 112 and pixel_y < 128 else '0';
	brick_3_5_on <= '1' when pixel_x >= 198 and pixel_x < 256 and pixel_y >= 112 and pixel_y < 128 else '0';
	brick_4_5_on <= '1' when pixel_x >= 260 and pixel_x < 318 and pixel_y >= 112 and pixel_y < 128 else '0';
	brick_5_5_on <= '1' when pixel_x >= 322 and pixel_x < 380 and pixel_y >= 112 and pixel_y < 128 else '0';
	brick_6_5_on <= '1' when pixel_x >= 384 and pixel_x < 442 and pixel_y >= 112 and pixel_y < 128 else '0';
	brick_7_5_on <= '1' when pixel_x >= 446 and pixel_x < 504 and pixel_y >= 112 and pixel_y < 128 else '0';
	brick_8_5_on <= '1' when pixel_x >= 508 and pixel_x < 566 and pixel_y >= 112 and pixel_y < 128 else '0';
	brick_9_5_on <= '1' when pixel_x >= 570 and pixel_x < 628 and pixel_y >= 112 and pixel_y < 128 else '0';
	
	--Seventh row
	brick_0_6_on <= '1' when pixel_x >= 12 and pixel_x < 70 and pixel_y >= 132 and pixel_y < 148 else '0';
	brick_1_6_on <= '1' when pixel_x >= 74 and pixel_x < 132 and pixel_y >= 132 and pixel_y < 148 else '0';
	brick_2_6_on <= '1' when pixel_x >= 136 and pixel_x < 194 and pixel_y >= 132 and pixel_y < 148 else '0';
	brick_3_6_on <= '1' when pixel_x >= 198 and pixel_x < 256 and pixel_y >= 132 and pixel_y < 148 else '0';
	brick_4_6_on <= '1' when pixel_x >= 260 and pixel_x < 318 and pixel_y >= 132 and pixel_y < 148 else '0';
	brick_5_6_on <= '1' when pixel_x >= 322 and pixel_x < 380 and pixel_y >= 132 and pixel_y < 148 else '0';
	brick_6_6_on <= '1' when pixel_x >= 384 and pixel_x < 442 and pixel_y >= 132 and pixel_y < 148 else '0';
	brick_7_6_on <= '1' when pixel_x >= 446 and pixel_x < 504 and pixel_y >= 132 and pixel_y < 148 else '0';
	brick_8_6_on <= '1' when pixel_x >= 508 and pixel_x < 566 and pixel_y >= 132 and pixel_y < 148 else '0';
	brick_9_6_on <= '1' when pixel_x >= 570 and pixel_x < 628 and pixel_y >= 132 and pixel_y < 148 else '0';
		
			
		-- next concurrent state logic
		moving_box1_on <= '1' when pixel_x >= box1_x_location and
										  pixel_x <  box1_x_location+60 and
										  pixel_y >= box1_y_location and
										  pixel_y < box1_y_location+7 else
								'0';
		
		square_on <= '1' when pixel_x >= square_x_location and
									 pixel_x <  square_x_location+5 and
									 pixel_y >= square_y_location and
									 pixel_y < square_y_location+5 else
						 '0';
			
		border_on <= '1' when (pixel_x<10 or pixel_x>=630 or pixel_y<10 or pixel_y>=470) else
						 '0';

						 
		
		
	brick_color <= "10101010" when (border_on = '1') and (blank = '0') else
						"11111000" when moving_box1_on = '1' else
						"11111111" when square_on = '1' else
						red_brick when brick_0_0_on = '1' and brick_0_0_off = '0' else
						red_brick when brick_1_0_on = '1' and brick_1_0_off = '0' else
						red_brick when brick_2_0_on = '1' and brick_2_0_off = '0' else
						red_brick when brick_3_0_on = '1' and brick_3_0_off = '0' else
						red_brick when brick_4_0_on = '1' and brick_4_0_off = '0' else
						red_brick when brick_5_0_on = '1' and brick_5_0_off = '0' else
						red_brick when brick_6_0_on = '1' and brick_6_0_off = '0' else
						red_brick when brick_7_0_on = '1' and brick_7_0_off = '0' else
						red_brick when brick_8_0_on = '1' and brick_8_0_off = '0' else
						red_brick when brick_9_0_on = '1' and brick_9_0_off = '0' else
						orange_brick when brick_0_1_on = '1' and brick_0_1_off = '0' else
						orange_brick when brick_1_1_on = '1' and brick_1_1_off = '0' else
						orange_brick when brick_2_1_on = '1' and brick_2_1_off = '0' else
						orange_brick when brick_3_1_on = '1' and brick_3_1_off = '0' else
						orange_brick when brick_4_1_on = '1' and brick_4_1_off = '0' else
						orange_brick when brick_5_1_on = '1' and brick_5_1_off = '0' else
						orange_brick when brick_6_1_on = '1' and brick_6_1_off = '0' else
						orange_brick when brick_7_1_on = '1' and brick_7_1_off = '0' else
						orange_brick when brick_8_1_on = '1' and brick_8_1_off = '0' else
						orange_brick when brick_9_1_on = '1' and brick_9_1_off = '0' else
						yellow_brick when brick_0_2_on = '1' and brick_0_2_off = '0' else
						yellow_brick when brick_1_2_on = '1' and brick_1_2_off = '0' else
						yellow_brick when brick_2_2_on = '1' and brick_2_2_off = '0' else
						yellow_brick when brick_3_2_on = '1' and brick_3_2_off = '0' else
						yellow_brick when brick_4_2_on = '1' and brick_4_2_off = '0' else
						yellow_brick when brick_5_2_on = '1' and brick_5_2_off = '0' else
						yellow_brick when brick_6_2_on = '1' and brick_6_2_off = '0' else
						yellow_brick when brick_7_2_on = '1' and brick_7_2_off = '0' else
						yellow_brick when brick_8_2_on = '1' and brick_8_2_off = '0' else
						yellow_brick when brick_9_2_on = '1' and brick_9_2_off = '0' else
						green_brick when brick_0_3_on = '1' and brick_0_3_off = '0' else
						green_brick when brick_1_3_on = '1' and brick_1_3_off = '0' else
						green_brick when brick_2_3_on = '1' and brick_2_3_off = '0' else
						green_brick when brick_3_3_on = '1' and brick_3_3_off = '0' else
						green_brick when brick_4_3_on = '1' and brick_4_3_off = '0' else
						green_brick when brick_5_3_on = '1' and brick_5_3_off = '0' else
						green_brick when brick_6_3_on = '1' and brick_6_3_off = '0' else
						green_brick when brick_7_3_on = '1' and brick_7_3_off = '0' else
						green_brick when brick_8_3_on = '1' and brick_8_3_off = '0' else
						green_brick when brick_9_3_on = '1' and brick_9_3_off = '0' else
						blue_brick when brick_0_4_on = '1' and brick_0_4_off = '0' else
						blue_brick when brick_1_4_on = '1' and brick_1_4_off = '0' else
						blue_brick when brick_2_4_on = '1' and brick_2_4_off = '0' else
						blue_brick when brick_3_4_on = '1' and brick_3_4_off = '0' else
						blue_brick when brick_4_4_on = '1' and brick_4_4_off = '0' else
						blue_brick when brick_5_4_on = '1' and brick_5_4_off = '0' else
						blue_brick when brick_6_4_on = '1' and brick_6_4_off = '0' else
						blue_brick when brick_7_4_on = '1' and brick_7_4_off = '0' else
						blue_brick when brick_8_4_on = '1' and brick_8_4_off = '0' else
						blue_brick when brick_9_4_on = '1' and brick_9_4_off = '0' else
						indigo_brick when brick_0_5_on = '1' and brick_0_5_off = '0' else
						indigo_brick when brick_1_5_on = '1' and brick_1_5_off = '0' else
						indigo_brick when brick_2_5_on = '1' and brick_2_5_off = '0' else
						indigo_brick when brick_3_5_on = '1' and brick_3_5_off = '0' else
						indigo_brick when brick_4_5_on = '1' and brick_4_5_off = '0' else
						indigo_brick when brick_5_5_on = '1' and brick_5_5_off = '0' else
						indigo_brick when brick_6_5_on = '1' and brick_6_5_off = '0' else
						indigo_brick when brick_7_5_on = '1' and brick_7_5_off = '0' else
						indigo_brick when brick_8_5_on = '1' and brick_8_5_off = '0' else
						indigo_brick when brick_9_5_on = '1' and brick_9_5_off = '0' else
						violet_brick when brick_0_6_on = '1' and brick_0_6_off = '0' else
						violet_brick when brick_1_6_on = '1' and brick_1_6_off = '0' else
						violet_brick when brick_2_6_on = '1' and brick_2_6_off = '0' else
						violet_brick when brick_3_6_on = '1' and brick_3_6_off = '0' else
						violet_brick when brick_4_6_on = '1' and brick_4_6_off = '0' else
						violet_brick when brick_5_6_on = '1' and brick_5_6_off = '0' else
						violet_brick when brick_6_6_on = '1' and brick_6_6_off = '0' else
						violet_brick when brick_7_6_on = '1' and brick_7_6_off = '0' else
						violet_brick when brick_8_6_on = '1' and brick_8_6_off = '0' else
						violet_brick when brick_9_6_on = '1' and brick_9_6_off = '0' else
						"00000000";
						
						
		red_disp <= brick_color(7 downto 5);
		green_disp <= brick_color(4 downto 2);
		blue_disp <= brick_color(1 downto 0);
				
end top_arch;
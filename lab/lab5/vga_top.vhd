library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_top is
	port(
		clk: in std_logic;
		red_out, green_out: out std_logic_vector(2 downto 0);
		blue_out: out std_logic_vector(1 downto 0);
		hs_out, vs_out: out std_logic;
		sw: in std_logic_vector(7 downto 0);
		btn: in std_logic_vector(3 downto 0)
	);
end vga_top;

architecture top_arch of vga_top is
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
	signal lastcol, lastrow: std_logic;
	signal hs,vs: std_logic;
	signal red,green: std_logic_vector(2 downto 0);
	signal blue: std_logic_vector(1 downto 0);
	signal red_disp,green_disp: std_logic_vector(2 downto 0);
	signal blue_disp: std_logic_vector(1 downto 0);
	signal reset: std_logic;
	
	begin
		bottom_level: vga_timing
		port map(clk=>clk, rst=>reset, pixel_x=>temp_x, pixel_y=>temp_y, blank=>blank,
					HS=>hs, VS=>vs, last_column=>lastcol, last_row=>lastrow);
		pixel_x <= unsigned(temp_x);
		pixel_y <= unsigned(temp_y);
		
		process(clk)
		begin
			if (rising_edge(clk)) then
				hs_out <= hs;
				vs_out <= vs;
				red_out <= red;
				green_out <= green;
				blue_out <= blue;
			end if;
		end process;
		
		process(btn,sw,pixel_x,pixel_y)
		
		begin
		red_disp <= "000";
		green_disp <= "000";
		blue_disp <= "00";
		reset <= '0';
		
			if btn(3)='1' then
				reset <= '1';
			elsif btn(2)='1' then
				red_disp <= "000";
				green_disp <= "000";
				blue_disp <= "00";
			elsif btn(1)='1' then
				red_disp <= sw(7)&sw(6)&sw(5);
				green_disp <= sw(4)&sw(3)&sw(2);
				blue_disp <= sw(1)&sw(0);
			elsif btn(0)='1' then
				if pixel_y>=0 and pixel_y<60 then
					red_disp <= "000";
					green_disp <= "000";
					blue_disp <= "00";
				elsif pixel_y>=60 and pixel_y<120 then
					red_disp <= "000";
					green_disp <= "000";
					blue_disp <= "11";
				elsif pixel_y>=120 and pixel_y<180 then
					red_disp <= "000";
					green_disp <= "111";
					blue_disp <= "00";
				elsif pixel_y>=180 and pixel_y<240 then
					red_disp <= "000";
					green_disp <= "111";
					blue_disp <= "11";
				elsif pixel_y>=240 and pixel_y<300 then
					red_disp <= "111";
					green_disp <= "000";
					blue_disp <= "00";
				elsif pixel_y>=300 and pixel_y<360 then
					red_disp <= "111";
					green_disp <= "000";
					blue_disp <= "11";
				elsif pixel_y>=360 and pixel_y<420 then
					red_disp <= "111";
					green_disp <= "111";
					blue_disp <= "00";
				else
					red_disp <= "111";
					green_disp <= "111";
					blue_disp <= "11";
				end if;

			else
				if pixel_x>=0 and pixel_x<80 then
					red_disp <= "000";
					green_disp <= "000";
					blue_disp <= "00";
				elsif pixel_x>=80 and pixel_x<160 then
					red_disp <= "000";
					green_disp <= "000";
					blue_disp <= "11";
				elsif pixel_x>=160 and pixel_x<240 then
					red_disp <= "000";
					green_disp <= "111";
					blue_disp <= "00";
				elsif pixel_x>=240 and pixel_x<320 then
					red_disp <= "000";
					green_disp <= "111";
					blue_disp <= "11";
				elsif pixel_x>=320 and pixel_x<400 then
					red_disp <= "111";
					green_disp <= "000";
					blue_disp <= "00";
				elsif pixel_x>=400 and pixel_x<480 then
					red_disp <= "111";
					green_disp <= "000";
					blue_disp <= "11";
				elsif pixel_x>=480 and pixel_x<560 then
					red_disp <= "111";
					green_disp <= "111";
					blue_disp <= "00";
				else
					red_disp <= "111";
					green_disp <= "111";
					blue_disp <= "11";
				end if;
			end if;
		end process;
		
		
		red <= red_disp when blank = '0' else "000";
		green <= green_disp when blank = '0' else "000";
		blue <= blue_disp when blank = '0' else "00";
				
end top_arch;
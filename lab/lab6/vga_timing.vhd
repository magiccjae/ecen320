library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity vga_timing is
	port(
		clk, rst: in std_logic;
		HS, VS: out std_logic;
		pixel_x, pixel_y: out std_logic_vector(9 downto 0);
		last_column, last_row: out std_logic;
		blank: out std_logic
	);
end vga_timing;

architecture vga_arch of vga_timing is
	signal pixel_en: std_logic := '0';
	signal column: unsigned(9 downto 0) := (others=>'0');
	signal column_next: unsigned(9 downto 0);
	signal row_en: std_logic;
	signal row: unsigned(9 downto 0) := (others=>'0');
	signal row_next: unsigned(9 downto 0);
	
begin
	
	-- pixel clock
	process(clk,rst)
	begin
		if(rst='1') then
			pixel_en <= '0';
		elsif(clk'event and clk='1') then
			pixel_en <= not pixel_en;
		end if;
	end process;
	
	-- horizontal counter
	process(clk,rst)
	begin
		if(rst='1') then
			column <= (others=>'0');
		elsif(clk'event and clk='1') then
			if(pixel_en = '0') then
				column <= column_next;	
			end if;
		end if;
	end process;
	column_next <= (others=>'0') when column=799 else
					  column + 1;
	row_en <= '1' when column=799 else
				 '0';
		
	-- vertical counter
	process(clk,rst)
	begin
		if(rst='1') then
			row <= (others=>'0');
		elsif(clk'event and clk='1') then
			if(row_en = '1' and pixel_en = '0') then
				row <= row_next;	
			end if;
		end if;
	end process;
	row_next <= (others=>'0') when row=520 else
					row + 1;
	
	--output logic
	pixel_x <= std_logic_vector(column);
	pixel_y <= std_logic_vector(row);
	last_column <= '1' when column=639 else
						'0';
	last_row <= '1' when row=479 else
					'0';
	HS <= '0' when column >= 656 and column <= 751 else
			'1';
	VS <= '0' when row >= 490 and row <= 491 else
			'1';
	blank <= '0' when column >= 0 and column <= 639 and row >= 0 and  row <= 479 else
				'1';
						
end vga_arch;
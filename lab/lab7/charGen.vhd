library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity charGen is
	port(
		clk: in std_logic;
		char_we: in std_logic;
		char_value: in std_logic_vector(7 downto 0);
		char_addr: in std_logic_vector(11 downto 0);
		pixel_x, pixel_y: in std_logic_vector(9 downto 0);
		pixel_out: out std_logic
	);
end charGen;

architecture charGen_arch of charGen is
	
	component char_mem
   port(
			clk: in std_logic;
			char_read_addr : in std_logic_vector(11 downto 0);
			char_write_addr: in std_logic_vector(11 downto 0);
			char_we : in std_logic;
			char_write_value : in std_logic_vector(7 downto 0);
			char_read_value : out std_logic_vector(7 downto 0)
		);
	end component;
	
	component font_rom
   port(
			clk: in std_logic;
			addr: in std_logic_vector(10 downto 0);
			data: out std_logic_vector(7 downto 0)
		);
	end component;
	
	signal rom_addr: std_logic_vector(10 downto 0);
	signal ram_read_addr: std_logic_vector(11 downto 0);
	signal ram_value: std_logic_vector(7 downto 0);
	signal myselect: std_logic_vector(2 downto 0);
	signal temp1: std_logic_vector(2 downto 0);
	signal rom_dataout: std_logic_vector(7 downto 0);
	
	begin
		myram: char_mem
		port map(clk=>clk, char_read_addr=>ram_read_addr, char_write_addr=>char_addr, char_we=>char_we, char_write_value=>char_value, char_read_value=>ram_value
				);
		myrom: font_rom
		port map(clk=>clk, addr=>rom_addr, data=>rom_dataout
				);

		process(clk)
		begin
			if(rising_edge(clk)) then
				temp1 <= pixel_x(2 downto 0);
				myselect <= temp1;
			end if;
		end process;

		
		with myselect select
			pixel_out <= rom_dataout(7) when "000",
							 rom_dataout(6) when "001",
							 rom_dataout(5) when "010",
							 rom_dataout(4) when "011",
							 rom_dataout(3) when "100",
							 rom_dataout(2) when "101",
							 rom_dataout(1) when "110",
							 rom_dataout(0) when others;
							 
		
		ram_read_addr <= pixel_y(8 downto 4) & pixel_x(9 downto 3);
		
		rom_addr <= ram_value(6 downto 0) & pixel_y(3 downto 0);
		
end charGen_arch;
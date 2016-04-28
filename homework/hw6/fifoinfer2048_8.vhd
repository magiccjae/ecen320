library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity fifoinfer2048_8 is
	port(
		clk, reset: in std_logic;
		full, empty: out std_logic;
		wr, rd: in std_logic;
		w_data: in std_logic_vector(7 downto 0);
		r_data: out std_logic_vector(7 downto 0)
	);
	
end fifoinfer2048_8;

architecture fifo_arch of fifoinfer2048_8 is
	
	type ram_type is array(2047 downto 0) of std_logic_vector(7 downto 0);
	signal Ram: ram_type := (others=>(others=>'0'));
	constant N: natural := 11;
	signal w_ptr_reg, w_ptr_next: unsigned(N downto 0);
	signal r_ptr_reg, r_ptr_next: unsigned(N downto 0);	
	signal full_flag, empty_flag: std_logic;
	signal addra, addrb: std_logic_vector(N downto 0) := (others=>'0');
	signal w_en: std_logic;
	signal read_a: std_logic_vector(7 downto 0) := (others=>'0');
	
begin
	
	process(clk)
	begin
		if(clk'event and clk='1') then
			if(w_en='1') then
				RAM(conv_integer(addra)) <= w_data;
			end if;
		end if;
		read_a <= RAM(conv_integer(addrb));
	end process;
		
	r_data <= read_a;	
	
	process(clk,reset)
	begin
		if (reset='1') then
			w_ptr_reg <= (others=>'0');
			r_ptr_reg <= (others=>'0');
		elsif(clk'event and clk='1') then
			w_ptr_reg <= w_ptr_next;
			r_ptr_reg <= r_ptr_next;
		end if;
	end process;


	-- write next logic
	w_en <= '1' when wr='1' and full_flag='0' else
			  '0';
	w_ptr_next <= w_ptr_reg + 1 when wr='1' and full_flag='0' else 
						w_ptr_reg;
	full_flag <= '1' when r_ptr_reg(N) /= w_ptr_reg(N) and 
								  r_ptr_reg(N-1 downto 0) = w_ptr_reg(N-1 downto 0) 
							else
					 '0';
	addra <= std_logic_vector(w_ptr_reg(N-1 downto 0));


	-- read next logic
	r_ptr_next <= r_ptr_reg + 1 when rd='1' and empty_flag='0' else
						r_ptr_reg;
	empty_flag <= '1' when r_ptr_reg = w_ptr_reg else
					  '0';
	addrb <= std_logic_vector(r_ptr_reg(N-1 downto 0));
					  
	-- output logic
	full <= full_flag;
	empty <= empty_flag;

end fifo_arch;
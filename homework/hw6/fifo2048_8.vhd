library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo2048_8 is
	port(
		clk, reset: in std_logic;
		full, empty: out std_logic;
		wr, rd: in std_logic;
		w_data: in std_logic_vector(7 downto 0);
		r_data: out std_logic_vector(7 downto 0)
	);
	
end fifo2048_8;

architecture fifo_arch of fifo2048_8 is

	component RAMB16_S9_S9
	port(
		DOA: out std_logic_vector(7 downto 0);
		DOB: out std_logic_vector(7 downto 0);
		DOPA: out std_logic_vector(0 downto 0);
		DOPB: out std_logic_vector(0 downto 0);
		ADDRA: in std_logic_vector(10 downto 0);
		ADDRB: in std_logic_vector(10 downto 0);
		CLKA: in std_ulogic;
		CLKB: in std_ulogic;
		DIA: in std_logic_vector(7 downto 0);
		DIB: in std_logic_vector(7 downto 0);
		DIPA: in std_logic_vector(0 downto 0);
		DIPB: in std_logic_vector(0 downto 0);
		ENA: in std_ulogic;
		ENB: in std_ulogic;
		SSRA: in std_ulogic;
		SSRB: in std_ulogic;
		WEA: in std_ulogic;
		WEB: in std_ulogic
	);
	end component;
	
	constant N: natural := 11;
	signal w_ptr_reg, w_ptr_next: unsigned(N downto 0);
	signal r_ptr_reg, r_ptr_next: unsigned(N downto 0);	
	signal full_flag, empty_flag: std_logic;
	signal addra, addrb: std_logic_vector(N downto 0) := (others=>'0');
	signal w_en: std_logic;
	signal clk_en: std_logic := '1';
	
	signal dib: std_logic_vector(7 downto 0) := (others=>'0');
	signal dipa,dipb: std_logic_vector(0 downto 0) := (others=>'0');
	signal web: std_ulogic := '0';
	
	
begin
	myram: RAMB16_S9_S9
	port map(DOA=>open, DOB=>r_data, DOPA=>open, DOPB=>open,
				ADDRA=>addra, ADDRB=>addrb,
				CLKA=>clk, CLKB=>clk, DIA=>w_data, DIB=>dib, 
				DIPA=>dipa, DIPB=>dipb, ENA=>clk_en, ENB=>clk_en,
				SSRA=>reset, SSRB=>reset, WEA=>w_en, WEB=>web
			);
	
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
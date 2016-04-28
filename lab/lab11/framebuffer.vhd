library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity framebuffer is
	port(
		clk: in std_logic;
		btn0: in std_logic;
		sw: in std_logic_vector(4 downto 0);
		Hsync: out std_logic;
		Vsync: out std_logic;
		vgaRed: out std_logic_vector(2 downto 0);
		vgaGreen: out std_logic_vector(2 downto 0);
		vgaBlue: out std_logic_vector(1 downto 0);
		MemAdr: out std_logic_vector(22 downto 0);
		MemOE: out std_logic;
		MemWR: out std_logic;
		RamCS: out std_logic;
		RamLB: out std_logic;
		RamUB: out std_logic;
		RamCLK: out std_logic;
		RamADV: out std_logic;
		RamCRE: out std_logic;
		MemDB: inout std_logic_vector(15 downto 0)
	);

end framebuffer;

architecture frame_arch of framebuffer is

	component sramController is
		port(
			clk, rst: in std_logic;
			mem, rw: in std_logic;
			addr: in std_logic_vector(22 downto 0);
			data_m2s: in std_logic_vector(15 downto 0);
			data_s2m: out std_logic_vector(15 downto 0);
			data_valid, ready: out std_logic;
			MemOE, MemWR: out std_logic;
			MemAdr: out std_logic_vector(22 downto 0);
			RamCS: out std_logic;
			RamLB, RamUB: out std_logic;
			RamCLK, RamADV, RamCRE: out std_logic;
			MemDB: inout std_logic_vector(15 downto 0)
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
	
	signal pixel_x,pixel_y: std_logic_vector(9 downto 0);
	signal blank: std_logic;
	signal rst: std_logic;
	signal lastcol, lastrow: std_logic;
	signal hs,vs: std_logic;
	signal addr: std_logic_vector(22 downto 0) := (others=>'0');
	signal combined_data: std_logic_vector(15 downto 0) := (others=>'0');
	signal data_s2m: std_logic_vector(15 downto 0) := (others=>'0');
	signal pixel_out: std_logic_vector(7 downto 0) := (others=>'0');
	signal hs_buf1, hs_buf2, hs_buf3, hs_buf4, hs_buf5, hs_final, vs_buf1, vs_buf2, vs_buf3, vs_buf4, vs_final: std_logic;
	signal x_buf1, x_buf2, x_buf3, x_final: std_logic_vector(9 downto 0);
	signal blank_buf1, blank_buf2, blank_buf3, blank_buf4, blank_buf5, blank_buf6, blank_final: std_logic;
--	type state_type is 
--	(idle,e1,e2,o1,o2);
--	signal state_reg, state_next: state_type;

	begin
	
		bottom_level: vga_timing
		port map(
				clk=>clk, 				-- o
				rst=>rst, 				-- o
				pixel_x=>pixel_x, 	-- o
				pixel_y=>pixel_y, 	-- o
				blank=>blank,			-- o
				HS=>hs, 					-- o
				VS=>vs, 					-- o
				last_column=>lastcol,-- o
				last_row=>lastrow		-- o
		);
		
		bottom_controller: sramController
		port map(
				clk=>clk, 				-- o
				rst=>rst, 				-- o
				mem=>'0', 				-- o
				rw=>'1', 				-- o
				addr=>addr, 			-- o
				data_m2s=>combined_data, -- o
				data_s2m=>data_s2m, 	-- o
				data_valid=>open, 	-- o 
				MemOE=>MemOE, 			-- o
				MemWR=>MemWR, 			-- o
				MemAdr=>MemAdr, 		-- o
				RamCS=>RamCS, 			-- o
				RamUB=>RamUB, 			-- o
				RamLB=>RamLB, 			-- o
				RamCLK=>RamCLK, 		-- o
				RamADV=>RamADV, 		-- o
				RamCRE=>RamCRE, 		-- o
				MemDB=>MemDB
		);
		
		-- asynchronous reset
		rst <= btn0;
		
		process(clk)
		begin
			if (rising_edge(clk)) then
				hs_buf1 <= hs;
				hs_buf2 <= hs_buf1;
				hs_buf3 <= hs_buf2;
				Hsync <= hs_buf3;
--				hs_buf5 <= hs_buf4;
--				hs_final <= hs_buf5;
--				Hsync <= hs_final;				
				
				vs_buf1 <= vs;
--				vs_buf2 <= vs_buf1;
--				vs_buf3 <= vs_buf2;
--				vs_buf4 <= vs_buf3;
--				vs_final <= vs_buf4;
				Vsync <= vs_buf1;				
				
				x_buf1 <= pixel_x;
				x_buf2 <= x_buf1;
				x_buf3 <= x_buf2;
				x_final <= x_buf3;
				
				blank_buf1 <= blank;
				blank_buf2 <= blank_buf1;
				blank_buf3 <= blank_buf2;
				blank_buf4 <= blank_buf3;
				blank_buf5 <= blank_buf4;
				blank_buf6 <= blank_buf5;
				blank_final <= blank_buf6;
				
			end if;
		end process;
		
		-- next address
		addr <= sw(4 downto 0) & pixel_y(8 downto 0) & pixel_x(9 downto 1);
			
		-- pixel_out logic
		pixel_out <= (others=>'0') when blank_final = '1' else
						 data_s2m(7 downto 0) when x_final(0)='0' else
						 data_s2m(15 downto 8) when x_final(0)='1' else
						 (others=>'0');
		vgaRed <= pixel_out(7 downto 5);
		vgaGreen <= pixel_out(4 downto 2);
		vgaBlue <= pixel_out(1 downto 0);	
	
--		process(state_reg, data_s2m, blank)
--		begin
--			state_next <= state_reg;
--			case state_reg is	
--				when idle =>
--					if blank = '0' then
--						state_next <= e1;
--					else
--						state_next <= state_reg;
--					end if;
--				when e1 =>	
--					state_next <= e2;
--				when e2 =>
--					if blank = '1' then
--						vgaRed <= "000";
--						vgaGreen <= "000";
--						vgaBlue <= "00";
--					else
--						vgaRed <= data_s2m(7 downto 5);
--						vgaGreen <= data_s2m(4 downto 2);
--						vgaBlue <= data_s2m(1 downto 0);	
--					end if;
--					state_next <= o1;
--				when o1 =>
--					state_next <= o2;
--				when o2 =>
--					if blank = '1' then
--						vgaRed <= "000";
--						vgaGreen <= "000";
--						vgaBlue <= "00";					
--						state_next <= idle;
--					else
--						vgaRed <= data_s2m(15 downto 13);
--						vgaGreen <= data_s2m(12 downto 10);
--						vgaBlue <= data_s2m(9 downto 8);
--						state_next <= e1;
--					end if;
--			end case;
--		end process;		

end frame_arch;
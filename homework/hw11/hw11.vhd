1.
	signal s4: signed(3 downto 0);
	signal s6: signed(5 downto 0);
	signal s8: signed(7 downto 0);
	
	s8 <= resize(s6+s4,8);
	
2.
	signal u8: unsigned(7 downto 0);
	signal s4: signed(3 downto 0);
	signal s9: signed(9 downto 0);
	
	s9 <= resize(s4,9) - signed(u8);
	
3.
	signal u1 : unsigned(3 downto 0) := "0110";
	signal u2 : unsigned(3 downto 0) := "1101";
	signal u3 : unsigned(5 downto 0) := "110011";
	signal u4 : unsigned(5 downto 0) := "010100";
	signal s1 : signed(3 downto 0) := "0111";
	signal s2 : signed(3 downto 0) := "1100";
	signal s3 : signed(5 downto 0) := "111111";
	signal s4 : signed(5 downto 0) := "011000";
	
	(a) r1 <= u1 + u2;	-- valid, unsigned(3 downto 0), "0011"
	(b) r2 <= u2 + u3; 	-- valid, unsigned(5 downto 0), "000000"
	(c) r3 <= u1 - u4;	-- valid, unsigned(5 downto 0), "110010"
	(d) r4 <= u1 + s1;	-- invalid
	(e) r5 <= signed(u3) + s4;	-- valid, signed(5 downto 0), "001011"
	(f) r6 <= s1 - s2;	-- valid, signed(3 downto 0), "1011"
	(g) r7 <= s3 + s4;	-- valid, signed(5 downto 0), "010111"
	(h) r8 <= s2 - u2;	-- invalid
	(i) r9 <= s3 + s1;	-- valid, signed(5 downto 0), "000110"
	(j) r10 <= s4 - (signed(u2));	-- valid, signed(5 downto 0), "011011"
	(k) r11 <= u1 * u4;	-- valid, unsigned(9 downto 0), "0001111000"
	(l) r12 <= s3 * (-s2);	-- valid, signed(9 downto 0), "1111111100"
	(m) r13 <= s1 * s2;	 -- valid, signed(7 downto 0), "11100100"
	
4.
	signal twos: signed(WIDTH-1 downto 0);
	signal ones: signed(WIDTH-1 downto 0);
	
	process(twos)
	begin
		if(twos(WIDTH-1)='0') then
			ones <= twos;
		else
			ones <= '1'&(-twos(WIDTH-2 downto 0));
	end process;
	
5.
	signal a: signed(7 downto 0);
	signal b: signed(7 downto 0);
	signal result: signed(7 downto 0);
	signal temp: signed(15 downto 0);	
	
	temp <= a*b;
	result <= temp(15) & temp(6 downto 0);
	
6.
	library ieee; 
	use ieee.std_logic_1164.all; 
	use ieee.numeric_std.all; 
	entity mult8 is 
	port( 
		a, b: in std_logic_vector(7 downto 0); 
		y: out std_logic_vector (15 downto 0) 
	); 
	end mult8; 
	
	architecture comb1_arch of mult8 is 
	 
	constant WIDTH: integer := 8; 
	signal au, bv0, bv1, bv2, bv3, bv4, bv5, bv6, bv7: signed(WIDTH-1 downto 0);
	signal temp0, temp1, temp2, temp3, temp4, temp5, temp6, temp7: signed(WIDTH-1 downto 0);
	signal p0, pl, p2, p3, p4, p5, p6, p7, prod: signed(2*WIDTH-1 downto 0);
	
	begin 
		au <= signed(a); 
		bv0 <= (others=>b(0)); 
		bv1 <= (others=>b(1)); 
		bv2 <= (others=>b(2)); 
		bv3 <= (others=>b(3)); 
		bv4 <= (others=>b(4)); 
		bv5 <= (others=>b(5)); 
		bv6 <= (others=>b(6)); 
		bv7 <= (others=>b(7)); 
		temp0 <= bv0 and au;
		P0 <= (others=>temp0(WIDTH-1)) & (bv0 and au);
		temp1 <= bv1 and au;
		p1 <= (others=>temp1(WIDTH-1)) & (bv1 and au) & "0";
		temp2 <= bv2 and au;
		p2 <= (others=>temp2(WIDTH-1)) & (bv2 and au) & "00"; 
		temp3 <= bv3 and au;
		p3 <= (others=>temp3(WIDTH-1)) & (bv3 and au) & "000"; 
		temp4 <= bv4 and au;
		p4 <= (others=>temp4(WIDTH-1)) & (bv4 and au) & "0000";
		temp5 <= bv5 and au;
		p5 <= (others=>temp5(WIDTH-1)) & (bv5 and au) & "00000";
		temp6 <= bv6 and au;		
		p6 <= (others=>temp6(WIDTH-1)) & (bv6 and au) & "000000"; 
		temp7 <= -bv7 and au;
		p7 <= temp7(WIDTH-1) & (-bv7 and au) & "0000000"; 
		prod <= ((p0+pl)+(p2+p3))+((p4+p5)+(p6+p7)); 
		y <= std_logic_vector(prod); 
	end comb1_arch; 

7.
	library ieee; 
	use ieee.std_logic_1164.all; 
	use ieee.numeric_std.all; 
	entity mult8_pipe is 
	port( 
		a, b: in std_logic_vector(7 downto 0); 
		y: out std_logic_vector (15 downto 0) 
	); 
	end mult8_pipe; 
	
	architecture comb2_arch of mult8_pipe is 
	 
	constant WIDTH: integer := 8; 
	signal au, bv0, bv1, bv2, bv3, bv4, bv5, bv6, bv7: signed(WIDTH-1 downto 0);
	signal temp0, temp1, temp2, temp3, temp4, temp5, temp6, temp7: signed(WIDTH-1 downto 0);
	signal p0, p1, p2, p3, p4, p5, p6, p7, prod: signed(2*WIDTH-1 downto 0);
	signal stage1a_reg, stage1a_next, stage1b_reg, stage1b_next, 
			stage1c_reg, stage1c_next, stage1d_reg, stage1d_next : signed(2*WIDTH-1 downto 0);
	signal stage2a_reg, stage2a_next, stage2b_reg, stage2b_next: signed(2*WIDTH-1 downto 0);
	signal stage3a_reg, stage3a_next: signed(2*WIDTH-1 downto 0);
	
	begin 
		process(clk)
		begin
			if(clk'event and clk='1') then
				stage1a_reg <= stage1a_next;
				stage1b_reg <= stage1b_next;
				stage1c_reg <= stage1c_next;
				stage1d_reg <= stage1d_next;
				stage2a_reg <= stage2a_next;
				stage2b_reg <= stage2b_next;
				prod <= stage3a_next;
				
			end if;
		end process;
	
		au <= signed(a); 
		bv0 <= (others=>b(0)); 
		bv1 <= (others=>b(1)); 
		bv2 <= (others=>b(2)); 
		bv3 <= (others=>b(3)); 
		bv4 <= (others=>b(4)); 
		bv5 <= (others=>b(5)); 
		bv6 <= (others=>b(6)); 
		bv7 <= (others=>b(7));
		
		temp0 <= bv0 and au;
		p0 <= (others=>temp0(WIDTH-1)) & (bv0 and au);
		temp1 <= bv1 and au;
		p1 <= (others=>temp1(WIDTH-1)) & (bv1 and au) & "0";
		temp2 <= bv2 and au;
		p2 <= (others=>temp2(WIDTH-1)) & (bv2 and au) & "00";
		temp3 <= bv3 and au;
		p3 <= (others=>temp3(WIDTH-1)) & (bv3 and au) & "000";
		temp4 <= bv4 and au;
		p4 <= (others=>temp4(WIDTH-1)) & (bv4 and au) & "0000";
		temp5 <= bv5 and au;
		p5 <= (others=>temp5(WIDTH-1)) & (bv5 and au) & "00000";
		temp6 <= bv6 and au;		
		p6 <= (others=>temp6(WIDTH-1)) & (bv6 and au) & "000000";
		temp7 <= -bv7 and au;
		p7 <= temp7(WIDTH-1) & (-bv7 and au) & "0000000";
		
		stage1a_next <= p0 + p1;
		stage1b_next <= p2 + p3;
		stage1c_next <= p4 + p5;
		stage1d_next <= p6 + p7;
		stage2a_next <= stage1a_reg + stage1b_reg;
		stage2b_next <= stage1c_reg + stage1d_reg;
		stage3a_next <= stage2a_reg + stage2b_reg;
		
		y <= std_logic_vector(prod); 
	end comb2_arch; 
--=============================
-- Listing 7.34 adder-based multiplier
--=============================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity mult8 is
   port(
      a, b: in std_logic_vector(15 downto 0);
      y: out std_logic_vector(31 downto 0)
   );
end mult8;

architecture comb1_arch of mult8 is
   constant WIDTH: integer:=16;
   signal au, bv0, bv1, bv2, bv3, bv4, bv5, bv6, bv7, 
          bv8, bv9, bv10, bv11, bv12, bv13, bv14, bv15:
      unsigned(WIDTH-1 downto 0);
   signal p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,prod:
      unsigned(2*WIDTH-1 downto 0);
begin
   au <= unsigned(a);
   bv0 <= (others=>b(0));
   bv1 <= (others=>b(1));
   bv2 <= (others=>b(2));
   bv3 <= (others=>b(3));
   bv4 <= (others=>b(4));
   bv5 <= (others=>b(5));
   bv6 <= (others=>b(6));
   bv7 <= (others=>b(7));
   bv8 <= (others=>b(8));
   bv9 <= (others=>b(9));
   bv10 <= (others=>b(10));
   bv11 <= (others=>b(11));
   bv12 <= (others=>b(12));
   bv13 <= (others=>b(13));
   bv14 <= (others=>b(14));
   bv15 <= (others=>b(15));
	p0 <="0000000000000000" & (bv0 and au);
   p1 <="000000000000000" & (bv1 and au) & "0";
   p2 <="00000000000000" & (bv2 and au) & "00";
   p3 <="0000000000000" & (bv3 and au) & "000";
   p4 <="000000000000" & (bv4 and au) & "0000";
   p5 <="00000000000" & (bv5 and au) & "00000";
   p6 <="0000000000" & (bv6 and au) & "000000";
   p7 <="000000000" & (bv7 and au) & "0000000";
   p8 <="00000000" & (bv8 and au) & "00000000";
   p9 <="0000000" & (bv9 and au) & "000000000";
   p10<="000000" & (bv10 and au)& "0000000000";
   p11<="00000" & (bv11 and au)& "00000000000";
   p12<="0000" & (bv12 and au)& "000000000000";
   p13<="000" & (bv13 and au)& "0000000000000";
   p14<="00" & (bv14 and au)& "00000000000000";
   p15<="0" & (bv15 and au)& "000000000000000";
   prod <= ((p0+p1)+(p2+p3))+((p4+p5)+(p6+p7))+
	   ((p8+p9)+(p10+p11))+((p12+p13)+(p14+p15));
   y <= std_logic_vector(prod);
end comb1_arch;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity seq_mult is
   port(
      clk, reset: in std_logic;
      start: in std_logic;
      a_in, b_in: in std_logic_vector(15 downto 0);
      ready: out std_logic;
      r: out std_logic_vector(31 downto 0)
   );
end seq_mult;


--=============================
-- Listing 11.8
--=============================
architecture shift_add_better_arch of seq_mult is
   constant WIDTH: integer:=16;
   constant C_WIDTH: integer:=4; -- width of the counter
   constant C_INIT: unsigned(C_WIDTH-1 downto 0):="1000";
   type state_type is (idle, add_shft);
   signal state_reg, state_next: state_type;
   signal a_reg, a_next: unsigned(WIDTH-1 downto 0);
   signal n_reg, n_next: unsigned(C_WIDTH-1 downto 0);
   signal p_reg, p_next: unsigned(2*WIDTH downto 0);
   -- alias for the upper part and lower parts of p_reg
   alias pu_next: unsigned(WIDTH downto 0) is
                 p_next(2*WIDTH downto WIDTH);
   alias pu_reg: unsigned(WIDTH downto 0) is
                 p_reg(2*WIDTH downto WIDTH);
   alias pl_reg: unsigned(WIDTH-1 downto 0) is
                 p_reg(WIDTH-1 downto 0);
begin
   -- state and data registers
   process(clk,reset)
   begin
      if reset='1' then
         state_reg <= idle;
         a_reg <= (others=>'0');
         n_reg <= (others=>'0');
         p_reg <= (others=>'0');
      elsif (clk'event and clk='1') then
         state_reg <= state_next;
         a_reg <= a_next;
         n_reg <= n_next;
         p_reg <= p_next;
      end if;
   end process;
   -- combinational circuit
   process(start,state_reg,a_reg,n_reg,p_reg,
           a_in,b_in,n_next,p_next)
   begin
      a_next <= a_reg;
      n_next <= n_reg;
      p_next <= p_reg;
      ready <='0';
      case state_reg is
         when idle =>
            if start='1' then
               p_next <= "00000000000000000" & unsigned(b_in);
               a_next <= unsigned(a_in);
               n_next <= C_INIT;
               state_next <= add_shft;
             else
               state_next <= idle;
            end if;
            ready <='1';
         when add_shft =>
            n_next <= n_reg - 1;
            -- add if multiplier bit is '1'
            if (p_reg(0)='1') then
               pu_next <= pu_reg + ('0' & a_reg);
            else
               pu_next <= pu_reg;
            end if;
            --shift
            p_next <= '0' & pu_next &
                      pl_reg(WIDTH-1 downto 1);
            if (n_next /= "0000") then
               state_next <= add_shft;
            else
               state_next <= idle;
            end if;
      end case;
   end process;
   r <= std_logic_vector(p_reg(2*WIDTH-1 downto 0));
end shift_add_better_arch;

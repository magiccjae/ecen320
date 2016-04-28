restart

wave add q
wave add r_reg
wave add r_next

isim force add clk 1 -value 0 -time 10ns -repeat 20ns
run 100ns


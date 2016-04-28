restart

wave add clk
wave add q
wave add reset
wave add r_reg
wave add counter

isim force add clk 1 -value 0 -time 10ns -repeat 20ns
put reset 1
run 10ns

put reset 0
run 90ns


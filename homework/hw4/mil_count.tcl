restart

wave add zero
wave add zero_next
wave add clk
wave add r_reg
wave add r_inc
wave add r_next

isim force add clk 1 -value 0 -time 5ns -repeat 10ns
run 20ms


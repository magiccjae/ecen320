restart

wave add clk
wave add a
wave add y

wave add reg1
wave add reg2
wave add reg3
wave add reg4
wave add reg5
wave add reg6
wave add reg7

wave add next5
wave add next6
wave add next7

isim force add clk 1 -value 0 -time 5ns -repeat 10ns

put a 10101010
run 8ns

put a 11111111
run 8ns

put a 01111111
run 8ns

run 20ns

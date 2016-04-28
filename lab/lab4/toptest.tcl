restart
wave add clk
wave add sw
wave add btn
wave add seg
wave add dp
wave add an
wave add blank

isim force add clk 1 -value 0 -time 10ns -repeat 20ns
run 11ns

put btn 1000
run 10ns

put btn 0100
run 10ns

put btn 0010
run 10ns

put btn 0001
run 10ns

put btn 0000
run 10ns
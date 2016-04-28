restart

wave add clk
wave add rgb
wave add hs_out
wave add vs_out
wave add sw
wave add seg
wave add an
wave add btn
wave add char_write_addr
wave add column_position
wave add row_position


isim force add clk 1 -value 0 -time 5ns -repeat 10ns
put sw 11001100
put btn 1000
run 20ns

put btn 0001
run 2ms

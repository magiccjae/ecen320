restart

wave add clk
wave add counter
wave add tx_bit
wave add load
wave add shift
wave add stop
wave add start
wave add clrTimer
wave add state_reg
wave add send_character
wave add shift_out
wave add tx_out

isim force add clk 1 -value 0 -time 5ns -repeat 10ns

put send_character 1
put data_in 10101011
run 1ms

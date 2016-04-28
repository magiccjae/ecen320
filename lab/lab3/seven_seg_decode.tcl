restart
wave add sw
wave add btn
wave add seg
wave add dp
wave add an

put sw 11111111
put btn 1000
run 10ns

put sw 11111111
put btn 0100
run 10ns

put sw 11111111
put btn 0000
run 10ns

put sw 10101010
put btn 1100
run 10ns

put sw 10101010
put btn 0000
run 10ns

put sw 10101010
put btn 0001
run 10ns

put sw 10101010
put btn 0010
run 10ns

put sw 10101010
put btn 0011
run 10ns


restart
wave add an
wave add dp
wave add seg
wave add myseg
wave add blank
wave add dp_in
wave add data_in
wave add anode_select
wave add r_reg
wave add clk

isim force add clk 1 -value 0 -time 10ns -repeat 20ns
run 10ns

# checking for anode_select
put data_in 1010101010011001
put anode_select 00
run 10ns

put data_in 1010101010011001
put anode_select 01
run 10ns

put data_in 1010101010011001
put anode_select 10
run 10ns

put data_in 1010101010011001
put anode_select 11
run 10ns

# checking for blank & dp
put data_in 1010100110101001
put anode_select 00
put dp_in 1111
put blank 0001
run 10ns

put data_in 1010100110101001
put anode_select 00
put dp_in 1111
put blank 0010
run 10ns

put data_in 1010100110101001
put anode_select 00
put blank 0100
run 10ns

put data_in 1010100110101001
put anode_select 00
put blank 1000
run 10ns


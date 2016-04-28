restart

wave add clk
wave add q1
wave add q2
wave add q3
wave add q4
wave add en1
wave add en2
wave add en3
wave add y

isim force add clk 1 -value 0 -time 10ns -repeat 20ns

run 200ns
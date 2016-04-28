restart

wave add clk
wave add rst
wave add pixel_en
wave add pixel_x
wave add pixel_y
wave add row_en
wave add last_column
wave add last_row
wave add HS
wave add VS
wave add blank

isim force add clk 1 -value 0 -time 5ns -repeat 10ns
put rst 1
run 20ns

put rst 0
run 10ms

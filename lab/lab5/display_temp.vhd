red_disp <= "000" when pixel_x<320 else
			"111";
green_disp <= "000" when pixel_x>=0 and pixel_x<160 and pixel_x>=320 and pixel_x<480 else
			  "111";
blue_disp <= "00" when pixel_x>=0 and pixel_x<80 and pixel_x>=160 and pixel_x<239
					   and pixel_x>=320 and pixel_x<400 and pixel_x>=480 and pixel_x<560 else
			 "11";
			 
red <= red_disp when blank = '0' else "000";
green <= green_disp when blank = '0' else "000";
blue <= blue_disp when blank = '0' else "00";


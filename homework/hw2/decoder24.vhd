architecture if_arch of decoder4 is
begin
	process(s,en)
	begin
		if(s="00" and en="1") then
			x <= "0001";
		elsif(s="01" and en="1") then
			x <= "0010";
		elsif(s="10" and en="1") then
			x <= "0100";
		elsif(s="11" and en="1") then
			x <= "1000";
		else
			x <= "0000";
		end if;
	end process;
end if_arch;
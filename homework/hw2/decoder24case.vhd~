architecture case_arch of decoder4 is
signal ens <= en&s;
begin
	process(ens)
	begin
		case ens is
			when "000"|"001"|"010"|"011" =>
				x <= "0000";
			when "100" =>
				x <= "0001";
			when "101" =>
				x <= "0010";
			when "110" =>
				x <= "0100";
			when others =>
				x <= "1000";
		end case;		
	end process;
end case_arch;

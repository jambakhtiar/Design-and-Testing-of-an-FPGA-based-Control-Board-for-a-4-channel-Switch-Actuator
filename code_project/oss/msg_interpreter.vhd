library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MSG_INTERPRETER is
	port (
		clk				: in std_logic;
		in_signal		: in std_logic;
		in_cmd			: in std_logic_vector(23 downto 0);
		in_current_state: in std_logic_vector(3 downto 0);	
		out_state		: out std_logic_vector(3 downto 0);
		state_msg		: out std_logic_vector(23 downto 0);
		out_e4_signal	: out std_logic;
		request_signal	: out std_logic
		);
end MSG_INTERPRETER;

architecture rtl of MSG_INTERPRETER is
	signal msg_command	: std_logic_vector(7 downto 0);
	signal msg_value  	: std_logic_vector(7 downto 0);
	
	-- Command List 
	signal s_activate_relay 	: std_logic_vector(7 downto 0) := X"73";
	signal c_deactivate_relay 	: std_logic_vector(7 downto 0) := X"63";
	signal t_toggle_relay 		: std_logic_vector(7 downto 0) := X"74";
	signal g_return_state 		: std_logic_vector(7 downto 0) := X"67";
	signal d_selftest 			: std_logic_vector(7 downto 0) := X"64";
	
	-- Value List
	signal msg_0 : std_logic_vector(7 downto 0) := X"30";
	signal msg_1 : std_logic_vector(7 downto 0) := X"31";
	signal msg_2 : std_logic_vector(7 downto 0) := X"32";
	signal msg_3 : std_logic_vector(7 downto 0) := X"33";
	signal msg_4 : std_logic_vector(7 downto 0) := X"34";
	signal msg_5 : std_logic_vector(7 downto 0) := X"35";
	signal msg_6 : std_logic_vector(7 downto 0) := X"36";
	signal msg_7 : std_logic_vector(7 downto 0) := X"37";
	signal msg_8 : std_logic_vector(7 downto 0) := X"38";
	signal msg_9 : std_logic_vector(7 downto 0) := X"39";
	signal msg_A : std_logic_vector(7 downto 0) := X"41";
	signal msg_B : std_logic_vector(7 downto 0) := X"42";
	signal msg_C : std_logic_vector(7 downto 0) := X"43";
	signal msg_D : std_logic_vector(7 downto 0) := X"44";
	signal msg_E : std_logic_vector(7 downto 0) := X"45";
	signal msg_F : std_logic_vector(7 downto 0) := X"46";
	signal msg_la : std_logic_vector(7 downto 0) := X"61";
	signal msg_lb : std_logic_vector(7 downto 0) := X"62";
	signal msg_lc : std_logic_vector(7 downto 0) := X"63";
	signal msg_ld : std_logic_vector(7 downto 0) := X"64";
	signal msg_le : std_logic_vector(7 downto 0) := X"65";
	signal msg_lf : std_logic_vector(7 downto 0) := X"66";
begin
	msg_command <= in_cmd(7 downto 0);
	msg_value <= in_cmd(23 downto 16);
	
	msg_logic: process(clk)
	begin	
		if rising_edge(clk) then
			request_signal <= '0';
			if in_signal = '1' then
				-- Relais Activation
				if msg_command = s_activate_relay then
					request_signal <= '0';	
					if msg_value = msg_0 then
						out_state(0) <= in_current_state(0);
						out_state(1) <= in_current_state(1);
						out_state(2) <= in_current_state(2);
						out_state(3) <= in_current_state(3);
					elsif msg_value = msg_1 then
						out_state(0) <= '1';
						out_state(1) <= in_current_state(1);
						out_state(2) <= in_current_state(2);
						out_state(3) <= in_current_state(3);
					elsif msg_value = msg_2 then
						out_state(0) <= in_current_state(0);
						out_state(1) <= '1';
						out_state(2) <= in_current_state(2);
						out_state(3) <= in_current_state(3);
					elsif msg_value = msg_3 then
						out_state(0) <= '1';
						out_state(1) <= '1';
						out_state(2) <= in_current_state(2);
						out_state(3) <= in_current_state(3);
					elsif msg_value = msg_4 then
						out_state(0) <= in_current_state(0);
						out_state(1) <= in_current_state(1);
						out_state(2) <= '1';
						out_state(3) <= in_current_state(3);
					elsif msg_value = msg_5 then
						out_state(0) <= '1';
						out_state(1) <= in_current_state(1);
						out_state(2) <= '1';
						out_state(3) <= in_current_state(3);
					elsif msg_value = msg_6 then
						out_state(0) <= in_current_state(0);
						out_state(1) <= '1';
						out_state(2) <= '1';
						out_state(3) <= in_current_state(3);
					elsif msg_value = msg_7 then
						out_state(0) <= '1';
						out_state(1) <= '1';
						out_state(2) <= '1';
						out_state(3) <= in_current_state(3);
					elsif msg_value = msg_8 then
						out_state(0) <= in_current_state(0);
						out_state(1) <= in_current_state(1);
						out_state(2) <= in_current_state(2);
						out_state(3) <= '1';
					elsif msg_value = msg_9 then
						out_state(0) <= '1';
						out_state(1) <= in_current_state(1);
						out_state(2) <= in_current_state(2);
						out_state(3) <= '1';
					elsif (msg_value = msg_A) or (msg_value = msg_la) then
						out_state(0) <= in_current_state(0);
						out_state(1) <= '1';
						out_state(2) <= in_current_state(2);
						out_state(3) <= '1';
					elsif (msg_value = msg_B) or (msg_value = msg_lb) then
						out_state(0) <= '1';
						out_state(1) <= '1';
						out_state(2) <= in_current_state(2);
						out_state(3) <= '1';
					elsif (msg_value = msg_C) or (msg_value = msg_lc) then
						out_state(0) <= in_current_state(0);
						out_state(1) <= in_current_state(1);
						out_state(2) <= '1';
						out_state(3) <= '1';
					elsif (msg_value = msg_D) or (msg_value = msg_ld) then
						out_state(0) <= '1';
						out_state(1) <= in_current_state(1);
						out_state(2) <= '1';
						out_state(3) <= '1';
					elsif (msg_value = msg_E) or (msg_value = msg_le) then
						out_state(0) <= in_current_state(0);
						out_state(1) <= '1';
						out_state(2) <= '1';
						out_state(3) <= '1';
					elsif (msg_value = msg_F) or (msg_value = msg_lf) then
						out_state(0) <= '1';
						out_state(1) <= '1';
						out_state(2) <= '1';
						out_state(3) <= '1';
					else
						out_e4_signal <= '1';
					end if;
				-- Relais De-Activation
				elsif msg_command = c_deactivate_relay then
					request_signal <= '0';	
					if msg_value = msg_0 then
						out_state(0) <= in_current_state(0);
						out_state(1) <= in_current_state(1);
						out_state(2) <= in_current_state(2);
						out_state(3) <= in_current_state(3);
					elsif msg_value = msg_1 then
						out_state(0) <= '0';
						out_state(1) <= in_current_state(1);
						out_state(2) <= in_current_state(2);
						out_state(3) <= in_current_state(3);
					elsif msg_value = msg_2 then
						out_state(0) <= in_current_state(0);
						out_state(1) <= '0';
						out_state(2) <= in_current_state(2);
						out_state(3) <= in_current_state(3);
					elsif msg_value = msg_3 then
						out_state(0) <= '0';
						out_state(1) <= '0';
						out_state(2) <= in_current_state(2);
						out_state(3) <= in_current_state(3);
					elsif msg_value = msg_4 then
						out_state(0) <= in_current_state(0);
						out_state(1) <= in_current_state(1);
						out_state(2) <= '0';
						out_state(3) <= in_current_state(3);
					elsif msg_value = msg_5 then
						out_state(0) <= '0';
						out_state(1) <= in_current_state(1);
						out_state(2) <= '0';
						out_state(3) <= in_current_state(3);
					elsif msg_value = msg_6 then
						out_state(0) <= in_current_state(0);
						out_state(1) <= '0';
						out_state(2) <= '0';
						out_state(3) <= in_current_state(3);
					elsif msg_value = msg_7 then
						out_state(0) <= '0';
						out_state(1) <= '0';
						out_state(2) <= '0';
						out_state(3) <= in_current_state(3);
					elsif msg_value = msg_8 then
						out_state(0) <= in_current_state(0);
						out_state(1) <= in_current_state(1);
						out_state(2) <= in_current_state(2);
						out_state(3) <= '0';
					elsif msg_value = msg_9 then
						out_state(0) <= '0';
						out_state(1) <= in_current_state(1);
						out_state(2) <= in_current_state(2);
						out_state(3) <= '0';
					elsif (msg_value = msg_A) or (msg_value = msg_la) then
						out_state(0) <= in_current_state(0);
						out_state(1) <= '0';
						out_state(2) <= in_current_state(2);
						out_state(3) <= '0';
					elsif (msg_value = msg_B) or (msg_value = msg_lb) then
						out_state(0) <= '0';
						out_state(1) <= '0';
						out_state(2) <= in_current_state(2);
						out_state(3) <= '0';
					elsif (msg_value = msg_C) or (msg_value = msg_lc) then
						out_state(0) <= in_current_state(0);
						out_state(1) <= in_current_state(1);
						out_state(2) <= '0';
						out_state(3) <= '0';
					elsif (msg_value = msg_D) or (msg_value = msg_ld) then
						out_state(0) <= '0';
						out_state(1) <= in_current_state(1);
						out_state(2) <= '0';
						out_state(3) <= '0';
					elsif (msg_value = msg_E) or (msg_value = msg_le) then
						out_state(0) <= in_current_state(0);
						out_state(1) <= '0';
						out_state(2) <= '0';
						out_state(3) <= '0';
					elsif (msg_value = msg_F) or (msg_value = msg_lf) then
						out_state(0) <= '0';
						out_state(1) <= '0';
						out_state(2) <= '0';
						out_state(3) <= '0';
					else
						out_e4_signal <= '1';
					end if;
				-- toggle relais
				elsif msg_command = t_toggle_relay then
					request_signal <= '0';	
					if msg_value = msg_0 then
						out_state(0) <= in_current_state(0);
						out_state(1) <= in_current_state(1);
						out_state(2) <= in_current_state(2);
						out_state(3) <= in_current_state(3);
					elsif msg_value = msg_1 then
						out_state(0) <= not in_current_state(0);
						out_state(1) <= in_current_state(1);
						out_state(2) <= in_current_state(2);
						out_state(3) <= in_current_state(3);
					elsif msg_value = msg_2 then
						out_state(1) <= in_current_state(0);
						out_state(1) <= not in_current_state(1);
						out_state(2) <= in_current_state(2);
						out_state(3) <= in_current_state(3);
					elsif msg_value = msg_3 then
						out_state(0) <= not in_current_state(0);
						out_state(1) <= not in_current_state(1);
						out_state(2) <= in_current_state(2);
						out_state(3) <= in_current_state(3);
					elsif msg_value = msg_4 then
						out_state(0) <= in_current_state(0);
						out_state(1) <= in_current_state(1);
						out_state(2) <= not in_current_state(2);
						out_state(3) <= in_current_state(3);
					elsif msg_value = msg_5 then
						out_state(0) <= not in_current_state(0);
						out_state(1) <= in_current_state(1);
						out_state(2) <= not in_current_state(2);
						out_state(3) <= in_current_state(3);
					elsif msg_value = msg_6 then
						out_state(0) <= in_current_state(0);
						out_state(1) <= not in_current_state(1);
						out_state(2) <= not in_current_state(2);
						out_state(3) <= in_current_state(3);
					elsif msg_value = msg_7 then
						out_state(0) <= not in_current_state(0);
						out_state(1) <= not in_current_state(1);
						out_state(2) <= not in_current_state(2);
						out_state(3) <= in_current_state(3);
					elsif msg_value = msg_8 then
						out_state(0) <= in_current_state(0);
						out_state(1) <= in_current_state(1);
						out_state(2) <= in_current_state(2);
						out_state(3) <= not in_current_state(3);
					elsif msg_value = msg_9 then
						out_state(0) <= not in_current_state(0);
						out_state(1) <= in_current_state(1);
						out_state(2) <= in_current_state(2);
						out_state(3) <= not in_current_state(3);
					elsif (msg_value = msg_A) or (msg_value = msg_la) then
						out_state(0) <= in_current_state(0);
						out_state(1) <= not in_current_state(1);
						out_state(2) <= in_current_state(2);
						out_state(3) <= not in_current_state(3);
					elsif (msg_value = msg_B) or (msg_value = msg_lb) then
						out_state(0) <= not in_current_state(0);
						out_state(1) <= not in_current_state(1);
						out_state(2) <= in_current_state(2);
						out_state(3) <= not in_current_state(3);
					elsif (msg_value = msg_C) or (msg_value = msg_lc) then
						out_state(0) <= in_current_state(0);
						out_state(1) <= in_current_state(1);
						out_state(2) <= not in_current_state(2);
						out_state(3) <= not in_current_state(3);
					elsif (msg_value = msg_D) or (msg_value = msg_ld) then
						out_state(0) <= not in_current_state(0);
						out_state(1) <= in_current_state(1);
						out_state(2) <= not in_current_state(2);
						out_state(3) <= not in_current_state(3);
					elsif (msg_value = msg_E) or (msg_value = msg_le) then
						out_state(0) <= in_current_state(0);
						out_state(1) <= not in_current_state(1);
						out_state(2) <= not in_current_state(2);
						out_state(3) <= not in_current_state(3);
					elsif (msg_value = msg_F) or (msg_value = msg_lf) then
						out_state(0) <= not in_current_state(0); 
						out_state(1) <= not in_current_state(1);
						out_state(2) <= not in_current_state(2);
						out_state(3) <= not in_current_state(3);
					else
						out_e4_signal <= '1';
					end if;
				elsif msg_command = g_return_state then	
					request_signal <= '1';
					out_state <= in_current_state;
					if in_current_state = X"0" then
						state_msg <= msg_0 & X"3067";
					elsif in_current_state = X"1" then
						state_msg <= msg_1 & X"3067";
					elsif in_current_state = X"2" then
						state_msg <= msg_2 & X"3067";
					elsif in_current_state = X"3" then
						state_msg <= msg_3 & X"3067";
					elsif in_current_state = X"4" then
						state_msg <= msg_4 & X"3067";
					elsif in_current_state = X"5" then
						state_msg <= msg_5 & X"3067";
					elsif in_current_state = X"6" then
						state_msg <= msg_6 & X"3067";
					elsif in_current_state = X"7" then
						state_msg <= msg_7 & X"3067";
					elsif in_current_state = X"8" then
						state_msg <= msg_8 & X"3067";
					elsif in_current_state = X"9" then
						state_msg <= msg_9 & X"3067";
					elsif in_current_state = X"A" then
						state_msg <= msg_A & X"3067";
					elsif in_current_state = X"B" then
						state_msg <= msg_B & X"3067";
					elsif in_current_state = X"C" then
						state_msg <= msg_C & X"3067";
					elsif in_current_state = X"D" then
						state_msg <= msg_D & X"3067";
					elsif in_current_state = X"E" then
						state_msg <= msg_E & X"3067";
					elsif in_current_state = X"F" then
						state_msg <= msg_F & X"3067";
					end if;
				else
					out_e4_signal <= '1';
				end if;
			else
				out_state <= in_current_state;
				out_e4_signal <= '0';
			end if;
		end if;
	end process msg_logic;
end rtl;
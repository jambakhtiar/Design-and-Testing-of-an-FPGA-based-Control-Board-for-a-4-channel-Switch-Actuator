library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MSG_SEPARATOR is
	port (
		clk				: in std_logic;
		in_signal		: in std_logic;
		in_msg			: in std_logic_vector(7 downto 0);
		in_reset		: in std_logic;
		out_reciever 	: out std_logic_vector(31 downto 0);
		out_sender 		: out std_logic_vector(31 downto 0);
		out_cmd			: out std_logic_vector(23 downto 0);
		out_crc			: out std_logic_vector(31 downto 0);
		out_cr			: out std_logic_vector(7 downto 0);
		out_signal		: out std_logic;
		out_e3_signal	: out std_logic
		);
end MSG_SEPARATOR;

architecture rtl of MSG_SEPARATOR is
	type fsm is (reciever, sender, cmd, crc, cr);
	signal fsm_state 	: fsm := reciever;
	signal msg_reciever	: std_logic_vector(31 downto 0) := (others => '0');
	signal msg_sender	: std_logic_vector(31 downto 0) := (others => '0');
	signal msg_cmd		: std_logic_vector(23 downto 0) := (others => '0');
	signal msg_crc		: std_logic_vector(31 downto 0) := (others => '0');
	signal msg_cr		: std_logic_vector(7 downto 0) := (others => '0');
	signal msg_done 	: std_logic := '0';
	
	signal counter_rec	: integer range 0 to 3 := 0;
	signal counter_snd	: integer range 0 to 3 := 0;
	signal counter_cmd 	: integer range 0 to 2 := 0;
	signal counter_crc 	: integer range 0 to 3 := 0;
	
	signal cr_ref		: std_logic_vector(7 downto 0) := X"0D"; -- CR

begin
	fsm_logic: process(clk)
	begin
		if rising_edge(clk) then
			msg_done <= '0';
			if in_reset = '1' then
				out_e3_signal <= '0';
				counter_rec <= 0;
				counter_snd <= 0;
				counter_cmd <= 0;
				counter_crc <= 0;
				msg_reciever <= (others => '0');
				msg_sender <= (others => '0');
				msg_cmd <= (others => '0');
				msg_crc <= (others => '0');
				msg_cmd <= (others => '0');
				fsm_state <= reciever;
			elsif in_signal = '1' then
				case fsm_state is
					when reciever =>
						if in_msg = cr_ref then
							fsm_state <= reciever;
							counter_rec <= 0;
							--out_e3_signal <= '1';
						else
							-- Move in_msg into correct position of msg vector
							msg_reciever(7 + (counter_rec * 8) downto 0 + (counter_rec * 8)) <= in_msg;
							if counter_rec < 3 then
								counter_rec <= counter_rec + 1;
							else
								fsm_state <= sender;
								counter_rec <= 0;
							end if;
						end if;
					when sender =>
						if in_msg = cr_ref then
							msg_done <= '0';
							out_e3_signal <= '1';
							counter_snd <= 0;
							fsm_state <= reciever;
						else
							msg_sender(7 + (counter_snd * 8) downto 0 + (counter_snd * 8)) <= in_msg;
							if counter_snd < 3 then
								counter_snd <= counter_snd + 1;
							else
								fsm_state <= cmd;
								counter_snd <= 0;
							end if;
						end if;
					when cmd =>
						if in_msg = cr_ref then
							msg_done <= '0';
							out_e3_signal <= '1';
							counter_cmd <= 0;
							fsm_state <= reciever;
						else
							msg_cmd(7 + (counter_cmd * 8) downto 0 + (counter_cmd * 8)) <= in_msg;
							if counter_cmd < 2 then
								counter_cmd <= counter_cmd + 1;
							else
								fsm_state <= crc;
								counter_cmd <= 0;
							end if;
						end if;
					when crc =>
						if in_msg = cr_ref then
							msg_done <= '0';
							out_e3_signal <= '1';
							counter_crc <= 0;
							fsm_state <= reciever;
						else
							msg_crc(7 + (counter_crc * 8) downto 0 + (counter_crc * 8)) <= in_msg;
							if counter_crc < 3 then
								counter_crc <= counter_crc + 1;
							else
								fsm_state <= cr;
								counter_crc <= 0;
							end if;
						end if;
					when cr =>
						if in_msg = cr_ref then
							msg_cr <= in_msg;
							-- after recieving cr the message is complete
							msg_done <= '1';
							fsm_state <= reciever;
						else
							out_e3_signal <= '1';
							-- if last symbol is not cr, then start over
							fsm_state <= reciever;
						end if;
				end case;
			end if;
		end if;
	end process fsm_logic;
	out_signal <= msg_done;
	out_reciever <= msg_reciever;
	out_sender <= msg_sender;
	out_cmd <= msg_cmd;
	out_crc <= msg_crc;
	out_cr <= msg_cr;
end rtl;
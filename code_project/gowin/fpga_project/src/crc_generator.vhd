library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CRC_GENERATOR is
	port (
        clk    		: in std_logic;
        in_signal   : in std_logic;
        in_rec     	: in std_logic_vector(31 downto 0);
        in_sender   : in std_logic_vector(31 downto 0);
        in_cmd      : in std_logic_vector(23 downto 0);
        out_signal  : out std_logic;
        out_crc     : out std_logic_vector(31 downto 0)
		);
end CRC_GENERATOR;

architecture rtl of CRC_GENERATOR is
	signal polynom  : std_logic_vector(15 downto 0) := X"1002";
	signal buf      : std_logic_vector(103 downto 0) := (others => '0');
	signal buf_split: std_logic_vector(7 downto 0);
    signal flag     : std_logic_vector(7 downto 0);
    signal crc_reg  : std_logic_vector(15 downto 0) := X"FFFF";

    signal i        : integer range 0 to 13 := 0;
    signal j        : integer range 0 to 8 := 0;

	signal crc_msg  : std_logic_vector(31 downto 0) := (others => '0');
	signal start_signal : std_logic := '0';

	type fsm is (idle, loops, set_flag, set_crc0, set_crc1, set_buf, set_crc2);
	signal fsm_state	: fsm:= idle;

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

begin
    crc: process(clk)
    begin
        if rising_edge(clk) then 
			case fsm_state is
				when idle =>
					buf <= X"00" & X"00" & in_cmd & in_sender & in_rec;
					out_signal <= '0';
					crc_reg <= X"FFFF";
					if in_signal = '1' then
						fsm_state <= loops;
					end if;
				
				when loops =>
					if i < 13 then
						if j < 8 then
							fsm_state <= set_flag;
						else
							j <= 0;
							i <= i + 1;
						end if;
					else
						i <= 0;

						if crc_reg(15 downto 12) = X"0" then
							out_crc(7 downto 0) <= msg_0;
						elsif crc_reg(15 downto 12) = X"1" then
							out_crc(7 downto 0) <= msg_1;
						elsif crc_reg(15 downto 12) = X"2" then
							out_crc(7 downto 0) <= msg_2;
						elsif crc_reg(15 downto 12) = X"3" then
							out_crc(7 downto 0) <= msg_3;
						elsif crc_reg(15 downto 12) = X"4" then
							out_crc(7 downto 0) <= msg_4;
						elsif crc_reg(15 downto 12) = X"5" then
							out_crc(7 downto 0) <= msg_5;
						elsif crc_reg(15 downto 12) = X"6" then
							out_crc(7 downto 0) <= msg_6;
						elsif crc_reg(15 downto 12) = X"7" then
							out_crc(7 downto 0) <= msg_7;
						elsif crc_reg(15 downto 12) = X"8" then
							out_crc(7 downto 0) <= msg_8;
						elsif crc_reg(15 downto 12) = X"9" then
							out_crc(7 downto 0) <= msg_9;
						elsif crc_reg(15 downto 12) = X"A" then
							out_crc(7 downto 0) <= msg_A;
						elsif crc_reg(15 downto 12) = X"B" then
							out_crc(7 downto 0) <= msg_B;
						elsif crc_reg(15 downto 12) = X"C" then
							out_crc(7 downto 0) <= msg_C;
						elsif crc_reg(15 downto 12) = X"D" then
							out_crc(7 downto 0) <= msg_D;
						elsif crc_reg(15 downto 12) = X"E" then
							out_crc(7 downto 0) <= msg_E;
						elsif crc_reg(15 downto 12) = X"F" then
							out_crc(7 downto 0) <= msg_F;
						end if;

						if crc_reg(11 downto 8) = X"0" then
							out_crc(15 downto 8) <= msg_0;
						elsif crc_reg(11 downto 8) = X"1" then
							out_crc(15 downto 8) <= msg_1;
						elsif crc_reg(11 downto 8) = X"2" then
							out_crc(15 downto 8) <= msg_2;
						elsif crc_reg(11 downto 8) = X"3" then
							out_crc(15 downto 8) <= msg_3;
						elsif crc_reg(11 downto 8) = X"4" then
							out_crc(15 downto 8) <= msg_4;
						elsif crc_reg(11 downto 8) = X"5" then
							out_crc(15 downto 8) <= msg_5;
						elsif crc_reg(11 downto 8) = X"6" then
							out_crc(15 downto 8) <= msg_6;
						elsif crc_reg(11 downto 8) = X"7" then
							out_crc(15 downto 8) <= msg_7;
						elsif crc_reg(11 downto 8) = X"8" then
							out_crc(15 downto 8) <= msg_8;
						elsif crc_reg(11 downto 8) = X"9" then
							out_crc(15 downto 8) <= msg_9;
						elsif crc_reg(11 downto 8) = X"A" then
							out_crc(15 downto 8) <= msg_A;
						elsif crc_reg(11 downto 8) = X"B" then
							out_crc(15 downto 8) <= msg_B;
						elsif crc_reg(11 downto 8) = X"C" then
							out_crc(15 downto 8) <= msg_C;
						elsif crc_reg(11 downto 8) = X"D" then
							out_crc(15 downto 8) <= msg_D;
						elsif crc_reg(11 downto 8) = X"E" then
							out_crc(15 downto 8) <= msg_E;
						elsif crc_reg(11 downto 8) = X"F" then
							out_crc(15 downto 8) <= msg_F;
						end if;

						if crc_reg(7 downto 4) = X"0" then
							out_crc(23 downto 16) <= msg_0;
						elsif crc_reg(7 downto 4) = X"1" then
							out_crc(23 downto 16) <= msg_1;
						elsif crc_reg(7 downto 4) = X"2" then
							out_crc(23 downto 16) <= msg_2;
						elsif crc_reg(7 downto 4) = X"3" then
							out_crc(23 downto 16) <= msg_3;
						elsif crc_reg(7 downto 4) = X"4" then
							out_crc(23 downto 16) <= msg_4;
						elsif crc_reg(7 downto 4) = X"5" then
							out_crc(23 downto 16) <= msg_5;
						elsif crc_reg(7 downto 4) = X"6" then
							out_crc(23 downto 16) <= msg_6;
						elsif crc_reg(7 downto 4) = X"7" then
							out_crc(23 downto 16) <= msg_7;
						elsif crc_reg(7 downto 4) = X"8" then
							out_crc(23 downto 16) <= msg_8;
						elsif crc_reg(7 downto 4) = X"9" then
							out_crc(23 downto 16) <= msg_9;
						elsif crc_reg(7 downto 4) = X"A" then
							out_crc(23 downto 16) <= msg_A;
						elsif crc_reg(7 downto 4) = X"B" then
							out_crc(23 downto 16) <= msg_B;
						elsif crc_reg(7 downto 4) = X"C" then
							out_crc(23 downto 16) <= msg_C;
						elsif crc_reg(7 downto 4) = X"D" then
							out_crc(23 downto 16) <= msg_D;
						elsif crc_reg(7 downto 4) = X"E" then
							out_crc(23 downto 16) <= msg_E;
						elsif crc_reg(7 downto 4) = X"F" then
							out_crc(23 downto 16) <= msg_F;
						end if;

						if crc_reg(3 downto 0) = X"0" then
							out_crc(31 downto 24) <= msg_0;
						elsif crc_reg(3 downto 0) = X"1" then
							out_crc(31 downto 24) <= msg_1;
						elsif crc_reg(3 downto 0) = X"2" then
							out_crc(31 downto 24) <= msg_2;
						elsif crc_reg(3 downto 0) = X"3" then
							out_crc(31 downto 24) <= msg_3;
						elsif crc_reg(3 downto 0) = X"4" then
							out_crc(31 downto 24) <= msg_4;
						elsif crc_reg(3 downto 0) = X"5" then
							out_crc(31 downto 24) <= msg_5;
						elsif crc_reg(3 downto 0) = X"6" then
							out_crc(31 downto 24) <= msg_6;
						elsif crc_reg(3 downto 0) = X"7" then
							out_crc(31 downto 24) <= msg_7;
						elsif crc_reg(3 downto 0) = X"8" then
							out_crc(31 downto 24) <= msg_8;
						elsif crc_reg(3 downto 0) = X"9" then
							out_crc(31 downto 24) <= msg_9;
						elsif crc_reg(3 downto 0) = X"A" then
							out_crc(31 downto 24) <= msg_A;
						elsif crc_reg(3 downto 0) = X"B" then
							out_crc(31 downto 24) <= msg_B;
						elsif crc_reg(3 downto 0) = X"C" then
							out_crc(31 downto 24) <= msg_C;
						elsif crc_reg(3 downto 0) = X"D" then
							out_crc(31 downto 24) <= msg_D;
						elsif crc_reg(3 downto 0) = X"E" then
							out_crc(31 downto 24) <= msg_E;
						elsif crc_reg(3 downto 0) = X"F" then
							out_crc(31 downto 24) <= msg_F;
						end if;

						out_signal <= '1';
						fsm_state <= idle;
					end if;

				when set_flag =>
					if not((crc_reg(15 downto 12) and X"8") = X"0") then
						flag <= X"01";
					else 
						flag <= X"00";
					end if;
					fsm_state <= set_crc0;
				
				when set_crc0 =>
					crc_reg <= crc_reg(14 downto 0) & '0';
					buf_split <= buf(7 + (i * 8) downto 0 + (i * 8));
					fsm_state <= set_crc1;
				
				when set_crc1 =>
					if not((buf_split and X"80") = X"00") then
						crc_reg <= crc_reg or X"0001";
					end if;
					fsm_state <= set_buf;
				
				when set_buf =>
					buf_split <= buf_split(6 downto 0) & '0';
					fsm_state <= set_crc2;

				when set_crc2 =>
					buf(7 + (i * 8) downto 0 + (i * 8)) <= buf_split;
					if not(flag = X"00") then
						crc_reg <= crc_reg xor polynom;
					end if;
					j <= j + 1;
					fsm_state <= loops;
			end case;
		end if;
    end process crc;
end rtl;
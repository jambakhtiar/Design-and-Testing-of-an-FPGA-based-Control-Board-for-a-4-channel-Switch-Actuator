library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SERIAL_SENDER is
	generic (
		-- clks_per_bit is computed as follows:
		-- clks_per_bit = (frequency if in_clk) / (baud rate)
		-- 2,080,000 hz / 9600 = 217
		clks_per_bit: integer := 217
		);
	port (
        in_clk		: in std_logic;
        in_signal   : in std_logic;
		in_msg	    : in std_logic_vector(119 downto 0);
		out_signal 	: out std_logic;
		out_serial	: out std_logic
		);
end SERIAL_SENDER;

architecture rtl of SERIAL_SENDER is
	type fsm is (idle, start, data, stop);
	signal fsm_state	: fsm := idle;
	type fsm_msg is (rec0, rec1, rec2, rec3, sender0, sender1, sender2, sender3, cmd0, cmd1, cmd2, crc0, crc1, crc2, crc3, cr);
	signal fsm_msg_state: fsm_msg := rec0;
	signal counter		: integer range 0 to clks_per_bit 	:= 0;
	signal bit_index	: integer range 0 to 7				:= 0;
	signal msg_split	: std_logic_vector(7 downto 0)		:= (others => '0');
	signal msg_signal 	: std_logic := '0';
	signal start_signal	: std_logic := '0';
	signal fin_signal 	: std_logic := '0';
	
	signal split_rec0		: std_logic_vector(7 downto 0) := (others => '0');
	signal split_rec1		: std_logic_vector(7 downto 0) := (others => '0');
	signal split_rec2		: std_logic_vector(7 downto 0) := (others => '0');
	signal split_rec3		: std_logic_vector(7 downto 0) := (others => '0');
	signal split_sender0	: std_logic_vector(7 downto 0) := (others => '0');
	signal split_sender1	: std_logic_vector(7 downto 0) := (others => '0');
	signal split_sender2	: std_logic_vector(7 downto 0) := (others => '0');
	signal split_sender3	: std_logic_vector(7 downto 0) := (others => '0');
	signal split_cmd0		: std_logic_vector(7 downto 0) := (others => '0');
	signal split_cmd1		: std_logic_vector(7 downto 0) := (others => '0');
	signal split_cmd2		: std_logic_vector(7 downto 0) := (others => '0');
	signal split_crc0		: std_logic_vector(7 downto 0) := (others => '0');
	signal split_crc1		: std_logic_vector(7 downto 0) := (others => '0');
	signal split_crc2		: std_logic_vector(7 downto 0) := (others => '0');
	signal split_crc3		: std_logic_vector(7 downto 0) := (others => '0');
 
begin
	fsm_logic: process(in_clk)
	begin
		if rising_edge(in_clk) then
			split_rec0 <= in_msg(7 downto 0);
			split_rec1 <= in_msg(15 downto 8);
			split_rec2 <= in_msg(23 downto 16);
			split_rec3 <= in_msg(31 downto 24);
			split_sender0 <= in_msg(39 downto 32);
			split_sender1 <= in_msg(47 downto 40);
			split_sender2 <= in_msg(55 downto 48);
			split_sender3 <= in_msg(63 downto 56);
			split_cmd0 <= in_msg(71 downto 64);
			split_cmd1 <= in_msg(79 downto 72);
			split_cmd2 <= in_msg(87 downto 80);
			split_crc0 <= in_msg(95 downto 88);
			split_crc1 <= in_msg(103 downto 96);
			split_crc2 <= in_msg(111 downto 104);
			split_crc3 <= in_msg(119 downto 112);
			case fsm_msg_state is
				when rec0 =>
					fin_signal <= '0';
					msg_split <= split_rec0;
					if in_signal = '1' then
						start_signal <= '1';
					elsif msg_signal = '1' then
						fsm_msg_state <= rec1;
						start_signal <= '1';
					end if;
				when rec1 =>
					msg_split <= split_rec1;
					if msg_signal = '1' then
						fsm_msg_state <= rec2;
						start_signal <= '1';
					end if;
				when rec2 =>
					msg_split <= split_rec2;
					if msg_signal = '1' then
						fsm_msg_state <= rec3;
						start_signal <= '1';
					end if;
				when rec3 =>
					msg_split <= split_rec3;
					if msg_signal = '1' then
						fsm_msg_state <= sender0;
						start_signal <= '1';
					end if;
				when sender0 =>
					msg_split <= split_sender0;
					if msg_signal = '1' then
						fsm_msg_state <= sender1;
						start_signal <= '1';
					end if;
				when sender1 =>
					msg_split <= split_sender1;
					if msg_signal = '1' then
						fsm_msg_state <= sender2;
						start_signal <= '1';
					end if;
				when sender2 =>
					msg_split <= split_sender2;
					if msg_signal = '1' then
						fsm_msg_state <= sender3;
						start_signal <= '1';
					end if;
				when sender3 =>
					msg_split <= split_sender3;
					if msg_signal = '1' then
						fsm_msg_state <= cmd0;
						start_signal <= '1';
					end if;
				when cmd0 =>
					msg_split <= split_cmd0;
					if msg_signal = '1' then
						fsm_msg_state <= cmd1;
						start_signal <= '1';
					end if;
				when cmd1 =>
					msg_split <= split_cmd1;
					if msg_signal = '1' then
						fsm_msg_state <= cmd2;
						start_signal <= '1';
					end if;
				when cmd2 =>
					msg_split <= split_cmd2;
					if msg_signal = '1' then
						fsm_msg_state <= crc0;
						start_signal <= '1';
					end if;
				when crc0 =>
					msg_split <= split_crc0;
					if msg_signal = '1' then
						fsm_msg_state <= crc1;
						start_signal <= '1';
					end if;
				when crc1 =>
					msg_split <= split_crc1;
					if msg_signal = '1' then
						fsm_msg_state <= crc2;
						start_signal <= '1';
					end if;
				when crc2 =>
					msg_split <= split_crc2;
					if msg_signal = '1' then
						fsm_msg_state <= crc3;
						start_signal <= '1';
					end if;
				when crc3 =>
					msg_split <= split_crc3;
					if msg_signal = '1' then
						fsm_msg_state <= cr;
						start_signal <= '1';
					end if;
				when cr =>
					msg_split <= X"0d";
					if msg_signal = '1' then
						fsm_msg_state <= rec0;
						fin_signal <= '1';
					end if;
			end case;

			case fsm_state is
				-- idle
				when idle =>
					msg_signal <= '0';
					counter <= 0;
					bit_index <= 0;
					out_serial <= '1';
				
					-- start signal
					if start_signal = '1' then
						fsm_state <= start;
					end if;
				
				-- set start bit
				when start =>
                    out_serial <= '0';
					if counter = clks_per_bit - 1 then
                        counter <= 0;
                        fsm_state <= data;
					else
						counter <= counter + 1;
					end if;
				
				-- set data bits
                when data =>
                    out_serial <= msg_split(bit_index);
					if counter < clks_per_bit - 1 then
						counter <= counter + 1;
					else
						counter <= 0;
						if bit_index < 7 then
							bit_index <= bit_index + 1;
						else
							bit_index <= 0;
							fsm_state <= stop;
						end if;
					end if;
				
				-- set stop bit
                when stop =>
                    out_serial <= '1';
					if counter < clks_per_bit - 1 then
						counter <= counter + 1;
					else
                        -- signal for finished byte
                        msg_signal <= '1';
						counter <= 0;
						start_signal <= '0';
                        -- return to idle
                        fsm_state <= idle;
					end if;
			end case;
		end if;
	end process fsm_logic;
	
	out_signal <= fin_signal;
end rtl;

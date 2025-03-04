library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SERIAL_RECIEVER is
	generic (
		-- clks_per_bit is computed as follows:
		-- clks_per_bit = (frequency if in_clk) / (baud rate)
		-- 2,080,000 hz / 9600 = 217
		clks_per_bit: integer := 217
		);
	port (
		in_clk		: in std_logic;
		in_serial	: in std_logic;
		out_signal 	: out std_logic;
		out_msg		: out std_logic_vector(7 downto 0)
		);
end SERIAL_RECIEVER;

architecture rtl of SERIAL_RECIEVER is
	type fsm is (idle, start, data, stop);
	signal fsm_state	: fsm := idle;
	signal counter		: integer range 0 to clks_per_bit 	:= 0;
	signal bit_index	: integer range 0 to 7				:= 0;
	signal msg			: std_logic_vector(7 downto 0)		:= (others => '0');
	signal msg_signal 	: std_logic := '0';

begin
	fsm_logic: process(in_clk)
	begin
		if rising_edge(in_clk) then
			case fsm_state is
				-- idle
				when idle =>
					counter <= 0;
					bit_index <= 0;
					msg_signal <= '0';
					msg <= (others => '0');
				
					-- start bit
					if in_serial = '0' then
						fsm_state <= start;
					else 
						fsm_state <= idle;
					end if;
				
				-- recieve start bit
				when start =>
					-- find middle of signal
					if counter = (clks_per_bit - 1) / 2 then
						-- confirm that start bit is still low, switch to data state
						if in_serial = '0' then
							counter <= 0;
							fsm_state <= data;
						-- error detected, back to idle
						else
							fsm_state <= idle;
						end if;
					-- before middle of signal, increase counter
					else
						counter <= counter + 1;
						fsm_state <= start;
					end if;
				
				-- recieve data bits
				when data =>
					-- wait for 1 bit-cycle
					if counter < clks_per_bit - 1 then
						counter <= counter + 1;
						fsm_state <= data;
					-- 1-bit cycle is over, read bit
					else
						counter <= 0;
						msg(bit_index) <= in_serial;
						
						-- keep in state until all bits recieved
						if bit_index < 7 then
							bit_index <= bit_index + 1;
							fsm_state <= data;
						-- go to stop state after 103 bits are recieved
						else
							bit_index <= 0;
							fsm_state <= stop;
						end if;
					end if;
				
				-- recieve stop bit
				when stop =>
					-- wait for 1 bit-cycle
					if counter < clks_per_bit - 1 then
						counter <= counter + 1;
						fsm_state <= stop;
					-- 1-bit cycle is over
					else
						-- give signal for correct byte if stop_bit arrives
						if in_serial = '1' then
							-- signal for finished msg
							msg_signal <= '1';
							counter <= 0;
							-- go to idle							
							fsm_state <= idle;
						-- if stop_bit is 0, reset all and return to idle
						else
							fsm_state <= idle;
						end if;
					end if;
			end case;
		end if;
	end process fsm_logic;
	
	out_signal <= msg_signal;
	out_msg <= msg;
end rtl;

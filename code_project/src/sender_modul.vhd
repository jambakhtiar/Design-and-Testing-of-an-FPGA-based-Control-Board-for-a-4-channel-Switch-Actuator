library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SENDER_MODUL is
	port (
        clk         : in std_logic;
		in_reset	: in std_logic;
        in_signal   : in std_logic;
        in_rec     	: in std_logic_vector(31 downto 0);
        in_sender   : in std_logic_vector(31 downto 0);
        in_cmd      : in std_logic_vector(23 downto 0);
        out_signal  : out std_logic;
        out_serial  : out std_logic
		);
end SENDER_MODUL;

architecture rtl of SENDER_MODUL is 
	signal start_compose_signal	: std_logic := '0';
	signal start_sending_signal	: std_logic := '0';
    signal end_compose_signal   : std_logic := '0';
    signal end_sending_signal   : std_logic := '0';
    signal msg                  : std_logic_vector(119 downto 0) := (others => '0');
	
	type fsm is (idle, compose, sending, fin);
	signal fsm_state 			: fsm := idle;

	component SERIAL_SENDER
	generic (
		clks_per_bit: integer := 217
		);
	port (
		in_clk		: in std_logic;
        in_signal   : in std_logic;
		in_msg	    : in std_logic_vector(119 downto 0);
		out_signal 	: out std_logic;
		out_serial	: out std_logic
		);
    end component;
    
    component MSG_COMPOSER
    port (
        clk         : in std_logic;
        in_signal   : in std_logic;
        in_rec     	: in std_logic_vector(31 downto 0);
        in_sender   : in std_logic_vector(31 downto 0);
        in_cmd      : in std_logic_vector(23 downto 0);
        out_msg     : out std_logic_vector(119 downto 0);
        out_signal  : out std_logic
        );
    end component;

begin
    composer: MSG_COMPOSER 
        PORT MAP (
            clk,
            in_signal,
            in_rec,
            in_sender,
            in_cmd,
            out_msg => msg,
            out_signal => end_compose_signal
        );

    sender: SERIAL_SENDER
        PORT MAP (
            clk,
            start_sending_signal,
            msg,
            out_signal => end_sending_signal,
            out_serial => out_serial
        );
		
	send: process(clk)
	begin
		if rising_edge(clk) then
			case fsm_state is
				when idle =>
					if in_signal = '1' then
						start_compose_signal <= '1';
						fsm_state <= compose;
					end if;
				when compose =>
					start_compose_signal <= '0';
					if end_compose_signal = '1' then
						start_sending_signal <= '1';
						fsm_state <= sending;
					end if;
				when sending =>
					start_sending_signal <= '0';
					if end_sending_signal = '1' then
						out_signal <= '1';
						fsm_state <= fin;
					end if;
				when fin =>
					out_signal <= '0';
					fsm_state <= idle;
			end case;
		end if;
	end process send;
end rtl;
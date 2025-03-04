library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MSG_COMPOSER is
	port (
        clk         : in std_logic;
        in_signal   : in std_logic;
        in_rec      : in std_logic_vector(31 downto 0);
        in_sender   : in std_logic_vector(31 downto 0);
        in_cmd      : in std_logic_vector(23 downto 0);
        out_msg     : out std_logic_vector(119 downto 0);
        out_signal  : out std_logic
		);
end MSG_COMPOSER;

architecture rtl of MSG_COMPOSER is

    component CRC_GENERATOR
	port (
		clk         : in std_logic;
        in_signal   : in std_logic;
        in_rec      : in std_logic_vector(31 downto 0);
        in_sender   : in std_logic_vector(31 downto 0);
        in_cmd      : in std_logic_vector(23 downto 0);
        out_signal  : out std_logic;
        out_crc     : out std_logic_vector(31 downto 0)
	);
	end component;

	type fsm is (idle, gen_crc, compose, send);
    signal fsm_state 	: fsm := idle;
    signal msg          : std_logic_vector(119 downto 0) := (others => '0');
    signal crc_sum      : std_logic_vector(31 downto 0) := (others => '0');

    signal crc_start    : std_logic := '0';
    signal crc_done     : std_logic := '0';

begin

    crc_gen_out: CRC_GENERATOR
		PORT MAP (	clk,
					crc_start,
					in_rec,
					in_sender,
					in_cmd,
					out_signal => crc_done,
					out_crc => crc_sum);

    fsm_logic: process(clk)
    begin
        if rising_edge(clk) then
            case fsm_state is
                when idle =>
                    out_signal <= '0';
                    if in_signal = '1' then
                        crc_start <= '1';
                        fsm_state <= gen_crc;
                    end if;
                when gen_crc =>
                    crc_start <= '0';
                    if crc_done = '1' then
                        fsm_state <= compose;
                    end if;
                when compose =>
                    msg(31 downto 0) <= in_rec;
                    msg(63 downto 32) <= in_sender;
					msg(71 downto 64) <= in_cmd(7 downto 0);
                    msg(79 downto 72) <= in_cmd(15 downto 8);
					msg(87 downto 80) <= in_cmd(23 downto 16);
                    msg(95 downto 88) <= crc_sum(7 downto 0);
                    msg(103 downto 96) <= crc_sum(15 downto 8);
                    msg(111 downto 104) <= crc_sum(23 downto 16);
                    msg(119 downto 112) <= crc_sum(31 downto 24);
                    fsm_state <= send;
                when send =>
                    out_msg <= msg;
                    out_signal <= '1';
                    fsm_state <= idle;
            end case;
        end if;
    end process fsm_logic;
end rtl;
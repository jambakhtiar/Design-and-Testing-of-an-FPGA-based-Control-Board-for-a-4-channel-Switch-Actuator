library ieee;
--library lattice;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use lattice.components.all;

entity TOP is
	port(
	    clk : in std_logic; --47
		in_serial				: in std_logic; --30
		in_reset				: in std_logic; --13
		out_serial				: out std_logic; --29
		serial_enable			: out std_logic; --26
		button0					: in std_logic; --22(B2)
		button1					: in std_logic; --18(G5)
		button2					: in std_logic; --17(G4)
		button3					: in std_logic; --16(G3)
		relais0					: out std_logic; --35(R0)
		relais1					: out std_logic; --34(R1)
		relais2					: out std_logic; --20(B1)
		relais3					: out std_logic  --19(B0)
	);
end TOP;

architecture rtl of TOP is
	signal slave_address		: std_logic_vector(31 downto 0) := X"32303031"; -- 1002
	signal master_address		: std_logic_vector(31 downto 0) := X"31303031"; -- 1001
	--signal clk					: std_logic := '0';
	
	signal new_signal			: std_logic := '0'; 
	signal new_byte				: std_logic_vector(7 downto 0) := (others => '0');
	signal crc_sum				: std_logic_vector(31 downto 0) := (others => '0');
	
	signal sender_signal 		: std_logic := '0';
	signal send_signal			: std_logic := '0';
	signal send_output			: std_logic := '1';
	
	signal msg_rec		 		: std_logic_vector(31 downto 0) := (others => '0');
	signal msg_sender 			: std_logic_vector(31 downto 0) := (others => '0');
	signal msg_cmd				: std_logic_vector(23 downto 0) := (others => '0');
	signal msg_crc				: std_logic_vector(31 downto 0) := (others => '0');
	signal msg_cr				: std_logic_vector(7 downto 0) := (others => '0');
	signal msg_signal			: std_logic := '0';
	
	signal current_state		: std_logic_vector(3 downto 0) := (others => '0');
	signal state_msg			: std_logic_vector(23 downto 0) := (others => '0');
	signal send_value			: std_logic_vector(23 downto 0) := (others => '0');
	
	signal button_signal		: std_logic := '0';
	
	signal global_reset			: std_logic := '0';
	signal reset_separator		: std_logic := '0';
	signal reset_sender			: std_logic := '0';
	
	signal gen_crc_signal 		: std_logic := '0';
	signal crc_signal			: std_logic := '0';
	signal request_signal		: std_logic := '0';
	signal exec_cmd_signal		: std_logic := '0';
	
	signal error1_signal 		: std_logic := '0';
	signal error2_signal 		: std_logic := '0';
	signal error3_signal 		: std_logic := '0';
	signal error4_signal 		: std_logic := '0';
	signal error5_signal 		: std_logic := '0';

	type fsm is (startup, idle, recieve, check_crc, check_addr, check_cmd, exec_cmd, send, error1, error2, error3, error4, error5);
	signal fsm_state			: fsm := startup;

	
	-- list components
-----------------------------------------------
--Cycles_per_Bit = Clock_Frequency / Baud_Rate
-- case of tinyFPGA clock freq being generated from Lattice component OSC was 2.08Mhz
--  And thus:
--  2080000 / 9600 = 216.667

--- But in Case of Tang-Nano-1K FPGA board, input frequency is 27Mhz
--- so:
--  27,000000 / 9600 = 2812.5    
------------------------------------------------
	component SERIAL_RECIEVER
	generic (
		--clks_per_bit: integer := 217 --was for tinyFPGA
		clks_per_bit: integer := 2813 -- is for TangNano-1k FPGA
		);
	port (
		in_clk		: in std_logic;
		in_serial	: in std_logic;
		out_signal 	: out std_logic;
		out_msg		: out std_logic_vector(7 downto 0)
		);
	end component;

	component SENDER_MODUL
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
	end component;
	
	component MSG_SEPARATOR
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
	end component;

	component CRC_GENERATOR
	port (
		clk         : in std_logic;
        in_signal   : in std_logic;
        in_rec	    : in std_logic_vector(31 downto 0);
        in_sender   : in std_logic_vector(31 downto 0);
        in_cmd      : in std_logic_vector(23 downto 0);
        out_signal  : out std_logic;
        out_crc     : out std_logic_vector(31 downto 0)
	);
	end component;

	component STATE_LOGIC
	port (
		clk				: in std_logic;
		reset			: in std_logic;
		msg_signal     	: in std_logic;
		button_signal  	: in std_logic;
		in_cmd         	: in std_logic_vector(23 downto 0);
		in_button0     	: in std_logic;
		in_button1     	: in std_logic;
		in_button2     	: in std_logic;
		in_button3     	: in std_logic;
		state_out      	: out std_logic_vector(3 downto 0);
		state_msg		: out std_logic_vector(23 downto 0);
		request_signal	: out std_logic;
		out_e2_signal	: out std_logic;
		out_e4_signal	: out std_logic
	);
	end component;
	
--	COMPONENT OSCH
--    GENERIC(
--		NOM_FREQ: string := "2.08");
 --   PORT ( 
--		STDBY    : IN  STD_LOGIC;
--		OSC      : OUT STD_LOGIC;
--		SEDSTDBY : OUT STD_LOGIC);
--	END COMPONENT;
	
begin
	--OSCInst0: OSCH
	--	GENERIC MAP (NOM_FREQ  => "2.08")
	--	PORT MAP (	STDBY => '0', 
	--				OSC => clk, 
	--				SEDSTDBY => OPEN);
	
	reciever: SERIAL_RECIEVER
		PORT MAP (	in_clk=> clk, 
		            in_serial=> in_serial,
					out_signal => new_signal,
					out_msg => new_byte);
	sender: SENDER_MODUL
		PORT MAP (	clk => clk,
					in_reset => reset_sender,
					in_signal => sender_signal,
					in_rec => master_address,
					in_sender => slave_address,
					in_cmd => send_value,
					out_signal => send_signal,
					out_serial => send_output
					);

	separator: MSG_SEPARATOR
	port map(
		clk				=> clk,
		in_signal		=> new_signal,
		in_msg			=> new_byte,
		in_reset		=> reset_separator,
		out_reciever 	=> msg_rec,
		out_sender 		=> msg_sender,
		out_cmd			=> msg_cmd,
		out_crc			=> msg_crc,
		out_cr			=> msg_cr,
		out_signal		=> msg_signal,
		out_e3_signal	=> error3_signal
		);



	crc_gen: CRC_GENERATOR
		PORT MAP (	clk,
					gen_crc_signal,
					master_address,
					slave_address,
					msg_cmd,
					out_signal => crc_signal,
					out_crc => crc_sum);
	logic: STATE_LOGIC
		PORT MAP (	clk,
					global_reset,
					exec_cmd_signal,
					button_signal,
					msg_cmd,
					button0,
					button1,
					button2,
					button3,
					state_out => current_state,
					state_msg => state_msg,
					request_signal => request_signal,
					out_e2_signal => error2_signal,
					out_e4_signal => error4_signal);
	button_signal <= not(button0 and button1 and button2 and button3);
	global_reset <= not(in_reset);
	out_serial <= send_output;
	relais0 <= current_state(0);
	relais1 <= current_state(1);
	relais2 <= current_state(2);
	relais3 <= current_state(3);
	
	main: process(clk)
		variable v_Count : natural range 0 to 104000 := 0;
	begin
		if rising_edge(clk) then
			if global_reset = '1' then
				v_Count := 0;
				serial_enable <= '0';
				sender_signal <= '0';
				exec_cmd_signal <= '0';
				gen_crc_signal <= '0';
				reset_separator <= '1';
				fsm_state <= startup;
				error5_signal <= '0';
			else
				case fsm_state is
					when startup =>
						v_Count := v_Count + 1;
						if v_Count = 104000 then
							fsm_state <= idle;
						end if;
					when idle =>
						reset_separator <= '0';
						serial_enable <= '0';
						exec_cmd_signal <= '0';
						sender_signal <= '0';
						if msg_signal = '1' then
							fsm_state <= recieve;
						elsif error3_signal = '1' then
							if msg_rec = slave_address then
								fsm_state <= error3;
							end if;
						end if;
					when recieve =>
						gen_crc_signal <= '1';
						fsm_state <= check_crc;
					when check_crc => 
						gen_crc_signal <= '0';
						if crc_signal = '1' then
							if crc_sum = msg_crc then
								fsm_state <= check_addr;
							elsif msg_crc = X"30303030" then
								fsm_state <= check_addr;
							else
								error1_signal <= '1';
								fsm_state <= error1;
							end if;
						end if;
					when check_addr =>
						if msg_rec = slave_address then
							if msg_sender = master_address then
								v_Count := 0;
								exec_cmd_signal <= '1';
								fsm_state <= check_cmd;
							else
								error5_signal <= '1';
								fsm_state <= error5;
							end if;
						else 
							fsm_state <= idle;
						end if;
					when check_cmd =>
						exec_cmd_signal <= '0';
						fsm_state <= exec_cmd;
					when exec_cmd =>
						v_Count := v_Count + 1;
						if error4_signal = '1' then
							fsm_state <= error4;
						end if;
						if v_Count > 1 then
							v_Count := 0;
							if request_signal = '1' then
								send_value <= state_msg;
								sender_signal <= '1';
								serial_enable <= '1';
								fsm_state <= send;
							else
								reset_separator <= '1';
								fsm_state <= idle;
							end if;
						end if;
					when send =>
						sender_signal <= '0';
						if send_signal = '1' then
							reset_separator <= '1';
							fsm_state <= idle;
						end if;
					when error1 =>
						send_value <= X"313045";
						reset_separator <= '1';
						sender_signal <= '1';
						serial_enable <= '1';
						fsm_state <= send;		  
					when error2 =>
						send_value <= X"323045";
						reset_separator <= '1';
						sender_signal <= '1';
						serial_enable <= '1';
						fsm_state <= send;	
					when error3 =>
						send_value <= X"333045";
						reset_separator <= '1';
						sender_signal <= '1';
						serial_enable <= '1';
						fsm_state <= send;	
					when error4 =>
						send_value <= X"343045";
						reset_separator <= '1';
						sender_signal <= '1';
						serial_enable <= '1';
						fsm_state <= send;	
					when error5 =>
						send_value <= X"353045";
						reset_separator <= '1';
						sender_signal <= '1';
						serial_enable <= '1';
						fsm_state <= send;	
					when others =>
						fsm_state <= idle; 
				end case;
			end if;
		end if;
	end process main;
end rtl;
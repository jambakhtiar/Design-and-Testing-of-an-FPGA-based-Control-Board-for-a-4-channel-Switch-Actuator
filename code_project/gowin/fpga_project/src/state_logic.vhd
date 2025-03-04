library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity STATE_LOGIC is
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
end STATE_LOGIC;

architecture rtl of STATE_LOGIC is
    signal current_state	: std_logic_vector(3 downto 0) := (others => '0');
    signal new_state    	: std_logic_vector(3 downto 0) := (others => '0');
	signal request_trigger 	: std_logic := '0';
	
	type fsm_state is (idle, msg_proc, btn_proc, fin);
	signal fsm_lgc_state	: fsm_state := idle;

    component MSG_INTERPRETER
    port (
		clk					: in std_logic;
		in_signal			: in std_logic;
		in_cmd				: in std_logic_vector(23 downto 0);
		in_current_state	: in std_logic_vector(3 downto 0);
		out_state			: out std_logic_vector(3 downto 0);
		state_msg			: out std_logic_vector(23 downto 0);
		request_signal		: out std_logic;
		out_e4_signal		: out std_logic
	);
    end component;
    
begin
    interpreter: MSG_INTERPRETER
		PORT MAP (	clk        => clk,
					in_signal  => msg_signal,
                    in_cmd     => in_cmd,
                    in_current_state =>current_state,
                    out_state => new_state,
					state_msg => state_msg,
					request_signal => request_trigger,
					out_e4_signal => out_e4_signal
					);
	
	process(clk)
----------------------------------------------------------------------------	
		-- increment v_Count for 50ms
		-- the following calculation was for tinyFPGA
		-- with 2.08 MHz it's 0.00048076923076923ms per clk
		-- => 104,000 clks
		
		-- this calculation is for tangNano-1k board
		--50ms debounce time calculation

       -- Wait_Time = Cycles_per_ms * 50
                            -- Cycles_per_ms = 27Mhz/1000 = 27000
       -- 27000 * 50 = 135,0000
------------------------------------------------------------------------------       
		--variable v_Count : natural range 0 to 104000 := 0; --was for tinyFPGA
		variable v_Count : natural range 0 to 1350000 := 0; --for tang-nano-1k board
    begin
		if rising_edge(clk) then
			if reset = '1' then
				current_state <= (others => '0');
				request_signal <= '0';
				v_Count := 0;
				fsm_lgc_state <= idle;
			else
				case fsm_lgc_state is
					when idle =>
						request_signal <= '0';
						if msg_signal = '1' then
							fsm_lgc_state <= msg_proc;
						elsif button_signal = '1' then
							fsm_lgc_state <= btn_proc;
						end if;
					when msg_proc =>
						if request_trigger = '1' then
							request_signal <= '1';
						else
							request_signal <= '0';
						end if;
						current_state <= new_state;
						fsm_lgc_state <= idle;
					when btn_proc =>
						v_Count := v_Count + 1;
						if v_Count = 104000 then
							if button_signal = '1' then
								if in_button0 = '0' then
									current_state(0) <= not current_state(0);
								end if;
								if in_button1 = '0' then
									current_state(1) <= not current_state(1);
								end if;
								if in_button2 = '0' then
									current_state(2) <= not current_state(2);
								end if;
								if in_button3 = '0' then
									current_state(3) <= not current_state(3);
								end if;
								fsm_lgc_state <= fin;
							else
								v_Count := 0;
								fsm_lgc_state <= idle;
							end if;
						end if;
					when fin =>
						v_Count := 0;
						if button_signal = '0' then
							fsm_lgc_state <= idle;
						end if;
				end case;
				state_out <= current_state;
			end if;
		end if;
    end process;
end rtl;
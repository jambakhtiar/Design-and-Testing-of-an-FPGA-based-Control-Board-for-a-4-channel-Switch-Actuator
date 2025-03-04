
Abstract
This project work consists of two sub-projects. On the one hand, a control board for a 4-channel
switch actuator was to be newly designed. The switch actuator has four relays that can be freely
controlled. In addition to the four buttons built into the housing, the new control board should allow
control via RS485 bus. In previous project works, this had already been carried out, but for this
work, an FPGA was to be used for the first time.
The FPGA used is a MachXO2-1200 from Lattice and is on a TinyFPGA AX2 development board.
The development board is so small that it can easily be mounted on the designed board via pin
headers.
In the second part of the work, a predefined communication protocol and all necessary
functionalities, as well as the control of the four buttons, are to be implemented on the FPGA. The
hardware description of the FPGA was done in the description language VHDL and is transferred to
the FPGA via a programmer. A MicroMatch interface should be placed on the control board for the
programmer.
Table of Contents
Statutory Declaration i
Abstract ii
Table of Contents iiiList of Figures vi
List of Tables vii
List of Abbreviations viii
1. Introduction 1
1.1. Objective of the Work 1
1.2. Procedure 1
2. Fundamentals 2
2.1. Data Exchange 2
2.2. Debouncing the Buttons 3
3. Problem Analysis 4
3.1. Communication Protocol 5
3.1.1. Message Fragments 6
3.1.2. Commands 6
3.1.3. Error Messages 7
4. Solution Concept 8
4.1. Reading Serial Data 8
4.2. Assembling Data 8
4.3. Generating CRC Checksum 9
4.4. Evaluating Commands 9
4.4.1. Executing Commands 9
4.5. Sending Message 10
4.5.1. Generating a Response 10
4.5.2. Sending Serial Data 10
4.6. Top Module 11
5. Implementation 12
5.1. The Module serial_reciever 12
5.1.1. Idle 13
5.1.2. Start 13
5.1.3. Data 14
5.1.4. Stop 14
5.2. The Module msg_separator 15
5.2.1. Reset 165.2.2. States 16
5.3. The Module crc_generator 17
5.4. The Module state_logic 17
5.4.1. Button Control 18
5.4.2. The Module msg_interpreter 19
5.5. The Module sender_modul 20
5.5.1. The Module msg_composer 21
5.5.2. The Module serial_sender 22
5.6. The Clock Generator 24
5.7. The Top Module 24
5.7.1. Startup and Idle 25
5.7.2. Receive and Check_crc 26
5.7.3. Check_addr 27
5.7.4. Check_cmd and exec_cmd 27
5.7.5. Send 28
5.7.6. Error States 28
6. Board Design 29
7. Commissioning 32
8. Evaluation 34
9. Summary and Outlook 35
Literature 36
A. Source Code 37
B. Circuit Diagram 42
List of Figures
5.1. Pin Assignments of the FPGA 25
6.1. FPGA with MAX485 29
6.2. Extended Board Design 30
6.3. Copper Layer has no contact to the outside on both sides 31
7.1. Buttons 1-4 and on the far left Reset; LEDs 1-4 in the back 32
List of Tables3.1. Division of Messages 6
3.2. Overview of which Relays are associated with which Operands 7
3.3. Overview of the Defined Error Codes 7
List of Abbreviations
ASCII: American Standard Code for Information Interchange 5
CR: Carriage Return 5
CRC: Cyclic Redundancy Check 4
FPGA: Field Programmable Gate Array 1
IDE: Integrated Development Environment 25
LED: Light Emitting Diode 1
LSB: Least Significant Bit 2
UART: Universal Asynchronous Receiver Transmitter 2
VHDL: Very High Speed Integrated Circuit Hardware Description Language 1
1. Introduction
During the Bachelor's degree program in Computer Science, a project with 150 hours of work is to
be completed. Due to previous collaboration with Prof. Dr. Rainer Werthebach, the idea arose to
reimplement an older project with different hardware. This involves an ELV switching module,
whose control board is to be replaced with a variant that is operated by an FPGA (Field
Programmable Gate Array).
1.1. Objective of the Work
The main objectives of this work are the design of a control board and the description of an FPGA
located on it, which allows control via the RS485 bus.
1.2. Procedure
Initially, there was a phase of familiarization with the VHDL (Very High-Speed Integrated Circuit
Hardware Description Language) description of the FPGA using the Lattice toolchain. This was
done through small test projects where LEDs (Light Emitting Diodes) and buttons were used.
Subsequently, the functionalities to be implemented were divided into individual modules, which
were then implemented and tested one by one.
Since hardware description, unlike usual programming, does not function sequentially, an
adjustment was necessary. The use of state machines proved beneficial in this regard. As they are
also very helpful for the conceptualization of processes, they were used more frequently.In parallel, there was a familiarization with circuit diagram and PCB design using the KiCad
software version 5.1.6. Based on previous project works, the control board was designed.
2. Fundamentals
2.1 Data Exchange
While the input and output signals of the control board take place via an RS485 interface, the
signals generated from it are subject to a UART (Universal Asynchronous Receiver Transmitter)
interface. This is an asynchronous, serial interface that is implemented without a clock signal. For
this work, a baud rate of 9600 bit/s is used. Since UART only allows simplex transmission, both a
sending and a receiving line are necessary.
The lines are continuously at a logical one until a logical zero arrives with the start bit of the
message stream. The following eight bits are the data bits of the message, starting with the LSB
(Least Significant Bit), followed by a logical one as the stop bit. Thus, data is transmitted byte by
byte.
Since custom modules are to be written in VHDL for serial transmission, it is necessary to measure
the bits correctly. If the value of a bit is measured immediately at the falling or rising edge of a
signal, reading the data is prone to errors. If the signal does not change its state quickly enough, it
could not be read reliably.
To avoid this source of error, one must wait until the middle of the bit after the edge has fallen and
only then measure. This ensures that the signal is at its desired HIGH or LOW voltage.
For the receiver module, one needs the number of clock cycles between the individual bits and must
start reading the data bits after half of this number. The number is calculated from the clock
frequency and the baud rate. The clock generator is built into the FPGA and is used with a
frequency of 2.08 MHz. This results in the following calculation:
Takte_pro_Bit=BaudrateTaktfrequenz
Takte_pro_Bit=9,6002,080,000≈216.667
Thus, the signal of a bit must be maintained for 217 cycles.
This value must also be used for sending the data to set the signals at the correct intervals to achieve
a baud rate of 9600.
2.2. Debouncing the Buttons
For the use of buttons, the interference effect of bouncing must be considered. This occurs due to
the mechanical pressing, where the contacts briefly spring back before making the final contact. As
a result, a stable signal is only present after a short time, and the state is fluctuating before that.
Depending on the function of the button, bouncing can lead to unwanted effects.
There are various ways to debounce buttons. In this case, debouncing is done in the FPGA using
VHDL. Upon detecting a signal, it is measured after 50 ms to see if the signal is still present, and
only then is the desired function executed. This time period is hardly noticeable for the user and issufficient to bridge the bouncing, as the bouncing times can reach up to 10 ms depending on the
button.
For this, the necessary number of clock cycles must also be calculated.
time cycles per msWait time=Clock cycles per ms×50
2080×50=104000
Section 3: Problem Analysis
The switch actuator is controlled by four signals originating from the control board. This results in
16 different states of the relays. To visualize this, four LEDs are located on the top side of the
casing to display the current state of each relay.
Additionally, the states should be toggleable manually using the buttons also located on the top side
of the casing.
The board should have an RS485 interface, which converts RS485 signals into serial signals and
forwards them to the FPGA. It should also have the same dimensions as the original board, a
voltage converter for power supply, a reset button, and a MicroMatch interface for the TinyFPGA
Programmer.
For serial signals, implementing read and write modules is necessary. Transmitted bytes must be
linked into a coherent message to check the message length. Subsequently, the message syntax must
be correct, and the proper CRC1 checksum must be calculated. If the addresses and the command
match, the command will be executed.
The FPGA requires the following inputs and outputs for these functionalities:
•
•
•
•
•
•
•
•
•
•
•
•
reset: Input
button0: Input
button1: Input
button2: Input
button3: Input
relay0: Output
relay1: Output
relay2: Output
relay3: Output
serial_in: Input
serial_out: Output
serial_enable: Output
3.1 Communication Protocol
Communication and control should take place serially over an RS485 bus. ASCII-coded bytes are
sent to make them readable in a terminal. An existing protocol from previous projects defines the
commands. The protocol specifications are:
• Message length: 12 bytes
• Encoding in ASCII•
•
•
•
•
•
Messages end with CR3
Baud rate: 9600
One start bit
Eight data bits, LSB first
One stop bit
No parity bit
3.1.1 Message Fragments
The message fragments are structured as follows:
Fragment
Encoding
Length Example
Receiver
Four numerical values, ASCII-coded 4 bytes 1001
Sender
Four numerical values, ASCII-coded 4 bytes 1001
Message
Operator + Operand, ASCII-coded 3 bytes s01
CRC Checksum
ASCII characters
4 bytes AB01
CR - Carriage Return ASCII character: CR (0x0D)
1 byte
Table 3.1: Structure of the messages
3.1.2 Commands
There are five different commands:
•
•
•
•
•
s: Turns the relay on
c: Turns the relay off
t: Toggles the relay
g: Queries the state of all relays
d: Performs a self-test (not yet defined)
3.1.3 Error Messages
Errors should be detected and reported back. Various error codes are defined for reporting, listed in
Table 3.3.
Error Code
Description
E01
CRC checksum incorrect
E02
Unknown error
E03
Packet length incorrect
E04
Command does not match the specified syntax
E05
Sender is not authorized to issue commands
Table 3.3: Overview of the defined error codes
Section 4: Solution Concept
Most functionalities can be divided into individual modules. In almost all cases, it has proven useful
to first design state machines. These allow sequential structures to be easily implemented in VHDL.4.1. Reading Serial Data
The work of the module for serial reception was based on a template. [2] From this, the necessary
processes were determined and also code parts for later implementation were taken.
A UART frame consists of ten bits. The first is the start bit, followed by eight data bits and finally
the stop bit. The data bits can be combined into a byte. Thus, it must first wait until a start bit is
detected. Then, the data bit is read eight times with the delay calculated in 2.1 and combined into a
byte. After the stop bit, the module signals that a new byte has been read.
4.2. Assembling Data
To process the data, the individual bytes must first be combined into the components of the message
protocol.
4.3. Generating CRC Checksum
Next, the syntax of the message must be correct, and the correct CRC1 checksum must be
calculated. If the addresses and the command match, the command is executed.
The FPGA requires the following inputs and outputs for these functionalities:
•
•
•
•
•
•
•
•
•
•
•
•
reset: input
taster0: input
taster1: input
taster2: input
taster3: input
relais0: output
relais1: output
relais2: output
relais3: output
serial_in: input
serial_out: output
serial_enable: output
4.4. Evaluating Commands
Commands are interpreted and executed based on predefined protocols and syntax.
4.5. Sending Messages
This involves generating a response and transmitting it serially.
4.6. Top Module
Combines all the submodules into a cohesive system .Section 5: Implementation
5.1 The Module serial_receiver
The serial_receiver module handles the reception of serial data. It consists of several states
that manage the reception process:
•
•
•
•
Idle: The module waits for a start bit.
Start: The start bit is detected and validated.
Data: Data bits are received.
Stop: The stop bit is validated and the complete byte is transferred.
vhdl
Copy code
entity SERIAL_RECEIVER is
port (
clk : in std_logic;
reset : in std_logic;
rx : in std_logic;
data_out : out std_logic_vector(7 downto 0);
ready : out std_logic
);
end SERIAL_RECEIVER;
5.2 The Module msg_separator
The msg_separator module is responsible for splitting incoming messages into their respective
components. This includes resetting the module, handling various states, and signaling errors.
5.2.1 Reset
The reset functionality clears all internal counters and sets the state machine back to its initial state.
vhdl
Copy code
if in_reset = '1' then
out_e3_signal <= '0';
counter_rec <= 0;
counter_snd <= 0;
counter_cmd <= 0;
counter_crc <= 0;
msg_receiver <= (others => '0');
msg_sender <= (others => '0');
msg_cmd <= (others => '0');
msg_crc <= (others => '0');
fsm_state <= receiver;
end if;
5.2.2 States
The module transitions through several states to separate the message components.
vhdl
Copy code
elsif in_signal = '1' then
case fsm_state is
when receiver =>
if in_msg = cr_ref thenfsm_state <= receiver;
counter_rec <= 0;
out_e3_signal <= '1';
else
<= in_msg;
msg_receiver(7 + (counter_rec * 8) downto 0 + (counter_rec * 8))
if counter_rec < 3 then
counter_rec <= counter_rec + 1;
else
fsm_state <= sender;
counter_rec <= 0;
end if;
end if;
when sender =>
-- Additional state logic
when cmd =>
-- Additional state logic
when crc =>
-- Additional state logic
when cr =>
if in_msg = cr_ref then
msg_cr <= in_msg;
msg_done <= '1';
fsm_state <= receiver;
else
out_e3_signal <= '1';
fsm_state <= receiver;
end if;
end case;
end if;
5.3 The Module crc_generator
The crc_generator module calculates the CRC checksum for the received message.
vhdl
Copy code
entity CRC_GENERATOR is
port (
clk : in std_logic;
in_signal : in std_logic;
in_rec : in std_logic_vector(31 downto 0);
in_sender : in std_logic_vector(31 downto 0);
in_cmd : in std_logic_vector(23 downto 0);
out_signal : out std_logic;
out_crc : out std_logic_vector(31 downto 0)
);
end CRC_GENERATOR;
5.4 The Module state_logic
The state_logic module manages state transitions and the execution of commands.
vhdl
Copy code
entity STATE_LOGIC is
port (
clk : in std_logic;
reset : in std_logic;
msg_signal : in std_logic;
button_signal : in std_logic;
in_cmd : in std_logic_vector(23 downto 0);in_button0 : in std_logic;
in_button1 : in std_logic;
in_button2 : in std_logic;
in_button3 : in std_logic;
state_out : out std_logic_vector(3 downto 0);
state_msg : out std_logic_vector(23 downto 0);
request_signal : out std_logic;
out_e2_signal : out std_logic;
out_e4_signal : out std_logic
);
end STATE_LOGIC;
5.4.1 Button Operation
When a button is pressed during the idle state, the state machine transitions to btn_proc to
process the button press.
vhdl
Copy code
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
5.5 The Module sender_modul
The sender_modul handles the sending of messages, including composing the message and
transmitting it via serial communication.
5.5.1 The Module msg_composer
This module assembles the message to be sent.
5.5.2 The Module serial_sender
The serial_sender transmits the composed message over the serial interface.Section 6: PCB Design
During the project, the FPGA was only used in a test setup on breadboards.
Figure 6.1: FPGA with MAX485
However, a carrier board should be designed on which the tinyFPGA board can be mounted.
Additionally, a reset button and a MicroMatch port for programming the FPGA should be added.
For the design, power supply, RS485 interface, and dimensions from a previous project were
adopted. Expanding this was a task of lesser size.
Initially, the circuit diagram was designed, with some elements also taken from the previous work
(see Appendix B).
Figure 6.2: Extended PCB Design
When routing the traces, it must be ensured that they do not run at 90-degree angles, do not cross
each other, and are not too close together. The angles can usually be maintained with the automation
provided by KiCad, although manual correction is sometimes necessary. In case of space issues, it is
helpful to narrow the traces in places or move them to the other side of the board.
Section 7: Commissioning
For commissioning, the button/LED board was replicated on a breadboard with an additional reset
button. This setup allowed for testing whether the outputs were correctly switched and the buttons
were properly read at any time. This was particularly useful during the development phase for basic
debugging.
Figure 7.1: Buttons 1-4 and reset on the far left; LEDs 1-4 at the back
At the end, it was checked whether the actual board worked the same way with the FPGA. Since
wiring errors could have occurred during the reconstruction, this was a necessary step. It turned out
that the circuit diagram was correctly read and implemented.
The control via terminal was successfully tested. All commands are executed correctly, and in case
of errors, the corresponding error messages are returned. Only the generation of the CRC checksum
remains an unresolved problem. The development of the CRC module was mainly carried out using
the simulator to be able to trace the calculated values step by step. While the checksums were
correctly displayed in the simulator, they were always the same and therefore incorrect during
actual operation. It was not possible to determine what caused this problem.
Since the control board was only designed but not created at the time of the project, actual
commissioning was not yet possible.
It also turned out that the programmer, which is plugged into the tinyFPGA board, has an impact on
the MAX485 module. Therefore, the serial ports cannot be used without the programmer attached.
Since the programmer was attached the entire time during the development phase, this was only
noticed at the very end.Section 8: Evaluation
The fundamental tasks were successfully completed. Relays can be toggled with debounced buttons,
commands transmitted via RS485 are correctly processed, and executed according to the
communication protocol. Errors mentioned there are also detected and acknowledged with
corresponding messages.
A new control board was designed to accommodate the tinyFPGA board, featuring a MicroMatch
port and the necessary components for power supply and RS485 interface. The dimensions of the
original board were maintained to allow installation in the ELV switch actuator housing.
Section 9: Summary and Outlook
The description of the FPGA makes it possible to control the relays of an ELV switch actuator via
an RS485 bus. Control can also be achieved by pressing the built-in buttons. It is possible to control
multiple devices differently, provided they are connected via the same bus.
With the developed interface, these switch actuators can automate further actuators. Potential
applications include home automation.

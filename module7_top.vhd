----------------------------------------------------------------------------------
-- Company: University of Canterbury
-- Engineers: Jack Willson, Oliver Butler, Mae Cradock 
-- 
-- Create Date: 28.02.2024 16:09:52
-- Module Name: module7_top - Structural
-- Project Name: FPGA Reaction Timer
-- Target Devices: Nexys-A7
-- Description: Links together all lower level modules to create a Reaction timer
--
-- Revision 0.01 - Final
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

--Port map top module
entity module7_top is
    Port (
        CLK100MHZ : in STD_LOGIC;
        BTNC, BTNU, BTND, BTNL, BTNR : in STD_LOGIC;
        AN : out STD_LOGIC_VECTOR (0 to 7);
        CA : out STD_LOGIC;
        CB : out STD_LOGIC;
        CC : out STD_LOGIC;
        CD : out STD_LOGIC;
        CE : out STD_LOGIC;
        CF : out STD_LOGIC;
        CG : out STD_LOGIC;
        DP : out STD_LOGIC);
end module7_top;

architecture Structural of module7_top is

component clock_divider
    port (
        CLK : in STD_LOGIC;
        DISP_CLK : out STD_LOGIC;
        MS_CLK : out STD_LOGIC);
end component;

--Module to control anode array for 7-seg display
component module3anodes
    port ( 
        DISPLAY_SELECTED : in STD_LOGIC_VECTOR (3 downto 0);
        ANODE : out STD_LOGIC_VECTOR (7 downto 0));
end component;

--Module to control cathode array for 7-seg display
component bcd_to_7seg
    port (
        BCD : in STD_LOGIC_VECTOR (3 downto 0);
        DP : in STD_LOGIC;
        SEG : out STD_LOGIC_VECTOR (0 to 7));
end component;

--Decade counter, outputs a clock every 10 ticks
component module5_09counter
    port ( 
        EN : in STD_LOGIC;
        RESET : in STD_LOGIC;
        INCREMENT : in STD_LOGIC;
        COUNT : out STD_LOGIC_VECTOR (3 downto 0);
        TICK : out STD_LOGIC);
end component;

--Finite state machine to control behavior of program
component finite_state_machine
    port (
        CLK : in STD_LOGIC;
        HARD_RESET : out STD_LOGIC;
        BTNC, BTNU, BTND, BTNL, BTNR : in STD_LOGIC;
        COUNT_1,COUNT_2,COUNT_3,COUNT_4 : in STD_LOGIC_VECTOR (3 downto 0);
        SEG1, SEG2, SEG3, SEG4 : in STD_LOGIC_VECTOR (3 downto 0);
        RAND_NUM1, RAND_NUM2, RAND_NUM3 : in std_logic_vector(11 downto 0);
        COUNTER_EN, COUNTER_RST, CONVERT_EN, RAND_EN: out STD_LOGIC; 
        MESSAGE : out STD_LOGIC_VECTOR (31 downto 0);
        DEC_ARR : out STD_LOGIC_VECTOR (31 downto 0);
        ALU_CONTROL : out STD_LOGIC_VECTOR (3 downto 0));
end component;

--Changes active display and pulls digit from message for BCD and anode array
component display_scan
    Port (
        DISP_CLOCK : in STD_LOGIC;
        CUR_DISP : in STD_LOGIC_VECTOR (3 downto 0);
        DEC_ARR : in STD_LOGIC_VECTOR (31 downto 0);
        MESSAGE : in STD_LOGIC_VECTOR (31 downto 0);
        DECIMAL : out STD_LOGIC;
        DIGIT : out STD_LOGIC_VECTOR (3 downto 0);
        NEXT_DISP : out STD_LOGIC_VECTOR (3 downto 0));
end component;

--Converts 4 decade counters to a 16 bit unsigned and keeps track of last three records
component convert_to_unsign
    Port ( 
        EN : in std_logic;
        HARD_RESET : in std_logic;
        COUNT1, COUNT2, COUNT3, COUNT4 : in std_logic_vector (3 downto 0);
        NUM_RECORDS : out unsigned (3 downto 0);
        TIME1, TIME2, TIME3 : out unsigned (15 downto 0);
        SEED : out std_logic_vector(11 downto 0));
end component;

--Converts from a 16 bit unsigned to four 'decade counts' for displaying on 7-seg
component convert_to_count
    Port ( 
        EN : in std_logic;
        INPUT : in unsigned (15 downto 0);
        OUT1, OUT2, OUT3, OUT4 : out std_logic_vector (3 downto 0));
end component;

--Returns MAX, MIN, AVG of last three counts based off Finite state control input
component ALU
    Port ( 
        EN : in std_logic;
        EXECUTE : in std_logic_vector (3 downto 0);
        TIME1, TIME2, TIME3 : in unsigned(15 downto 0);
        NUM_REC : in unsigned(3 downto 0);
        OUTPUT : out unsigned(15 downto 0));
end component;

--Pseudo random number generator, uses a LFSR and an input seed from the last recorded time
component PRNG
    Port (
        CLK, EN: in std_logic;         -- Clock input
        SEED_IN: in std_logic_vector(11 downto 0);  -- Seed input
        RAND_OUT1, RAND_OUT2, RAND_OUT3 : out std_logic_vector(11 downto 0));  -- Random number output
end component;


signal disp_clock : STD_LOGIC := '0';
signal ms_clock : STD_LOGIC := '0';
signal cur_disp : STD_LOGIC_VECTOR (3 downto 0) := "0000";
signal anode_arr : STD_LOGIC_VECTOR (7 downto 0);
signal seg_arr : STD_LOGIC_VECTOR (0 to 7);
signal decimal : STD_LOGIC := '0';  --Display decimal on 7-seg
signal digit : STD_LOGIC_VECTOR (3 downto 0);   --Digit to be displayed
signal inc10 : STD_LOGIC := '0';    --Decade counter increment
signal inc100 : STD_LOGIC := '0';   --Decade counter increment
signal inc1000 : STD_LOGIC := '0';  --Decade counter increment
signal reset : STD_LOGIC := '0';    --Decade counter reset
signal enable : STD_LOGIC := '0';   --Decade counter enable
signal convert_en : STD_LOGIC := '0';   --Convert to unsigned enable
signal hard_reset : STD_LOGIC := '0';   --Reset all recorded times to zero
signal rand_en : STD_LOGIC := '0';      --Enable PRNG shifting

signal count1 : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');   --Decade counter 1's
signal count2 : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');   --Decade counter 10's
signal count3 : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');   --Decade counter 100's
signal count4 : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');   --Decade counter 1000's
signal print1 : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');   --Processed numbers to be printed...
signal print2 : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
signal print3 : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
signal print4 : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
signal message : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); --32 bit message array for 7-seg (8x 4 bit digits)
signal dec_arr : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); --Array for which decimal shall be lit

signal time1 : unsigned (15 downto 0) := (others => '0');   --Latest recorded time
signal time2 : unsigned (15 downto 0) := (others => '0');   --Second latest time
signal time3 : unsigned (15 downto 0) := (others => '0');   --Third latest time
signal num_records : unsigned (3 downto 0) := (others => '0');  --Number of recorded times
signal alu_control_sig : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');  --Control input signal for the ALU
signal alu_out : unsigned (15 downto 0) := (others => '0');     --Processed ALU output
signal rand_num1, rand_num2, rand_num3 : std_logic_vector(11 downto 0);  -- Random number outputs for countdown timers
signal rand_seed : std_logic_vector(11 downto 0); -- 12 Bit Seed input from recorded times

begin
    --Divide 100MHz clock for milliseconds and 7-seg display cycling
    g0: clock_divider port map (CLK => CLK100MHZ, DISP_CLK => disp_clock, MS_CLK => ms_clock);
    
    --4 decade counters for timing upto 9999ms
    g1: module5_09counter port map (EN => enable, RESET => reset, INCREMENT => ms_clock, COUNT => count1, TICK => inc10);
    
    g2: module5_09counter port map (EN => enable, RESET => reset, INCREMENT => inc10, COUNT => count2, TICK => inc100);
    
    g3: module5_09counter port map (EN => enable, RESET => reset, INCREMENT => inc100, COUNT => count3, TICK => inc1000);
    
    g4: module5_09counter port map (EN => enable, RESET => reset, INCREMENT => inc1000, COUNT => count4);
    
    
    --Convert decade counters to an unsigned
    g5: convert_to_unsign port map (EN => convert_en, HARD_RESET => hard_reset, count1 => count1, count2 => count2, count3 => count3, count4 => count4, TIME1 => time1, TIME2 => time2, TIME3 => time3, NUM_RECORDS => num_records, SEED => rand_seed);
    
    --Returns MAX, MIN, AVG of last three counts based off Finite state control input
    g6: ALU port map (EN => ms_clock, EXECUTE => alu_control_sig, TIME1 => time1, TIME2 => time2, TIME3 => time3, NUM_REC => num_records, OUTPUT => alu_out);
    
    --Converts from a 16 bit unsigned to four 'decade counts' for displaying on 7-seg
    g7: convert_to_count port map (EN => ms_clock, INPUT => alu_out, OUT1 => print1, OUT2 => print2, OUT3 => print3, OUT4 => print4);
    
    --Pseudo random number generator, uses a LFSR and an input seed from the last recorded time
    g8: PRNG port map (CLK => ms_clock, EN => rand_en, seed_in => rand_seed, RAND_OUT1 => rand_num1, RAND_OUT2 => rand_num2, RAND_OUT3 => rand_num3);
    
    --Finite state machine to control behavior of program
    g9: finite_state_machine port map (CLK => ms_clock, HARD_RESET => hard_reset, BTNC => BTNC, BTNU => BTNU, BTND => BTND, BTNL => BTNL, BTNR => BTNR, COUNT_1 => count1, COUNT_2 => count2, COUNT_3 => count3, COUNT_4 => count4, SEG1 => print1, SEG2 => print2, SEG3 => print3, SEG4 => print4, COUNTER_EN => enable, COUNTER_RST => reset, CONVERT_EN => convert_en, MESSAGE => message, DEC_ARR => dec_arr, ALU_CONTROL => alu_control_sig, RAND_EN => rand_en, RAND_NUM1 => rand_num1, RAND_NUM2 => rand_num2, RAND_NUM3 => rand_num3);
    
    --Changes active display and pulls digit from message for BCD and anode array
    g10: display_scan port map (DISP_CLOCK => disp_clock, CUR_DISP => cur_disp, DEC_ARR => dec_arr, MESSAGE => message, DECIMAL => decimal, DIGIT => digit, NEXT_DISP => cur_disp);
    
    --Module to control anode array for 7-seg display
    g11: module3anodes port map (DISPLAY_SELECTED => cur_disp, ANODE => anode_arr);
    
    --Module to control cathode array for 7-seg display
    g12: bcd_to_7seg port map (BCD => digit, DP => decimal, SEG => seg_arr);
    
    --Output results to 7-seg displays one at a time
    AN <= anode_arr;
    CA <= not(seg_arr(0));
    CB <= not(seg_arr(1));
    CC <= not(seg_arr(2));
    CD <= not(seg_arr(3));
    CE <= not(seg_arr(4));
    CF <= not(seg_arr(5));
    CG <= not(seg_arr(6));
    DP <= not(seg_arr(7));
    
end Structural;

----------------------------------------------------------------------------------
-- Company: University of Canterbury
-- Engineers: Jack Willson, Oliver Butler, Mae Cradock 
-- 
-- Create Date: 12.03.2024 17:03:52
-- Module Name: finite_state_machine - Behavioral
-- Project Name: FPGA Reaction Timer
-- Target Devices: Nexys-A7
-- Description: Finite state machine that controls nearly everything in the program, Uses mainly BTN's as inputs
--
-- Revision 0.01 - Final
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;


entity finite_state_machine is
    Port ( CLK : in STD_LOGIC; --Millisecond clock
         HARD_RESET : out STD_LOGIC;    --Reset all times on BTNL
         BTNC, BTNU, BTND, BTNL, BTNR : in STD_LOGIC;   --Button inputs
         COUNT_1,COUNT_2,COUNT_3,COUNT_4 : in STD_LOGIC_VECTOR (3 downto 0);    --Raw times from last recorded time
         SEG1, SEG2, SEG3, SEG4 : in STD_LOGIC_VECTOR (3 downto 0);             --Processed times for display
         RAND_NUM1, RAND_NUM2, RAND_NUM3 : in std_logic_vector(11 downto 0);    --Input random numbers
         COUNTER_EN, COUNTER_RST, CONVERT_EN, RAND_EN: out STD_LOGIC;           --Enables and resets for decade counter, conver to unsign and PRNG
         MESSAGE : out STD_LOGIC_VECTOR (31 downto 0);      --Message array for 7-seg
         DEC_ARR : out STD_LOGIC_VECTOR (31 downto 0);      --Decimal array for 7-seg
         ALU_CONTROL : out STD_LOGIC_VECTOR (3 downto 0));  --Control output for ALU
end finite_state_machine;

architecture Behavioral of finite_state_machine is

    type state_type is (rand_gen, warning_3, warning_2, warning_1, counting, print_recent, print_records, loop_records, error, reset, convert);
    signal current_state, next_state : state_type := rand_gen;  --Set initial state to creating random numbers
    constant T1: natural := 1000 ;
    constant T2: natural := 4095 ;
    signal t: natural range 0 to T1-1;
    signal long_t: natural range 0 to T2-1; --Long timer for long random decimals
    signal hard_rst : STD_LOGIC := '0';
    signal alu_sig : STD_LOGIC_VECTOR (3 downto 0) := "0000";

begin

    STATE_REGISTER: process (CLK)
    begin
        if (rising_edge(CLK)) then
            current_state <= next_state; --Change state on the MS clock
        end if;
    end process;

    OUTPUT_DECODE: process (current_state, COUNT_4, COUNT_3, COUNT_2, COUNT_1, SEG1, SEG2, SEG3, SEG4)
    begin
        case (current_state) is
            when rand_gen =>
                COUNTER_EN <= '0';
                COUNTER_RST <= '1';
                HARD_RESET <= '0';
                CONVERT_EN <= '0';
                MESSAGE <= X"0000AAAA"; -- 3 decimal on, blank digit
                DEC_ARR <= X"00000111";
        
            when warning_3 =>
                COUNTER_EN <= '0';
                COUNTER_RST <= '1';
                HARD_RESET <= '0';
                CONVERT_EN <= '0';
                MESSAGE <= X"0000AAAA"; -- 3 decimal on, blank digit
                DEC_ARR <= X"00000111";
            
            when warning_2 =>
                COUNTER_EN <= '0';
                COUNTER_RST <= '0';
                HARD_RESET <= '0';
                CONVERT_EN <= '0';
                MESSAGE <= X"0000AAAA"; -- 2 decimal on, blank digit
                DEC_ARR <= X"00000011";
            
            when warning_1 =>
                COUNTER_EN <= '0';
                COUNTER_RST <= '0';
                HARD_RESET <= '0';
                CONVERT_EN <= '0';
                MESSAGE <= X"0000AAAA"; -- 1 decimal on, blank digit
                DEC_ARR <= X"00000001";
            
            when counting =>
                COUNTER_EN <= '1';
                COUNTER_RST <= '0';
                HARD_RESET <= '0';
                CONVERT_EN <= '0';
                MESSAGE(31 downto 16) <= (others => '0') ;
                MESSAGE(15 downto 0) <=  COUNT_4 & COUNT_3 & COUNT_2 & COUNT_1; -- each nibble of message represent one character or digit on a 7 segment display.
                DEC_ARR <= X"00001000";
            
            when convert =>             --Extra waiting state for convert to unsigned
                COUNTER_EN <= '0';
                COUNTER_RST <= '0';
                HARD_RESET <= '0';
                CONVERT_EN <= '0';
                MESSAGE(31 downto 16) <= (others => '0') ;
                MESSAGE(15 downto 0) <=  COUNT_4 & COUNT_3 & COUNT_2 & COUNT_1;
                DEC_ARR <= X"00001000";
            
            when print_recent =>
                COUNTER_EN <= '0';
                COUNTER_RST <= '0';
                HARD_RESET <= '0';
                CONVERT_EN <= '1';
                MESSAGE(31 downto 16) <= (others => '0') ;
                MESSAGE(15 downto 0) <=  COUNT_4 & COUNT_3 & COUNT_2 & COUNT_1;
                DEC_ARR <= X"00001000";
            
            when print_records =>
                COUNTER_EN <= '0';
                COUNTER_RST <= '0';
                HARD_RESET <= '0';
                CONVERT_EN <= '0';
                MESSAGE(31 downto 16) <= (others => '0') ;
                MESSAGE(15 downto 0) <=  SEG4 & SEG3 & SEG2 & SEG1;
                DEC_ARR <= X"00001000";
            
            when loop_records =>        --Processing state for ALU to calculate
                COUNTER_EN <= '0';
                COUNTER_RST <= '0';
                HARD_RESET <= '0';
                CONVERT_EN <= '0';
                --MESSAGE(31 downto 16) <= (others => '0') ;
                MESSAGE(15 downto 0) <=  X"AAAA";
                DEC_ARR <= X"00000000";
            
            when error =>
                COUNTER_EN <= '0';
                COUNTER_RST <= '0';
                HARD_RESET <= '0';
                MESSAGE <=  X"0000AEFF"; -- Display ERR on 7seg 
                DEC_ARR <= X"00000000";
            
            when reset =>
                COUNTER_EN <= '0';
                COUNTER_RST <= '1';
                HARD_RESET <= '1';
                MESSAGE <=  X"00000000";    --Display all zeros for until BTNC pushed
                DEC_ARR <= X"00000000";
            
            when others =>
                COUNTER_EN <= '0';
                COUNTER_RST <= '0';
        end case;
    end process;

    NEXT_STATE_DECODE: process (current_state, t, long_t, BTNC, BTNL, BTNR, BTNU, BTND)
    begin
        case (current_state) is
            when rand_gen =>
                if (t > 7) then --Select random number from cycle, small buffer to let it populate
                    RAND_EN <= '0'; --Turn off generator
                    if (t > 20) then
                        next_state <= warning_3; --Start counting down
                    end if;
                else
                    RAND_EN <= '1'; --Turn on generator
                    next_state <= rand_gen;
                end if;
            when warning_3 =>
                if (BTNC = '1' and t > 500) then    --t = 500 to prevent instant state cycling
                    next_state <= error;
                else
                    if long_t >= natural(to_integer(unsigned(RAND_NUM3))) then
                    --if t >= 999 then
                        next_state <= warning_2;
                    else
                        next_state <= warning_3;
                    end if;
                end if;
            
            when warning_2 =>
                if BTNC = '1' then
                    next_state <= error;
                else
                    if long_t >= natural(to_integer(unsigned(RAND_NUM2))) then
                    --if t >= 999 then
                        next_state <= warning_1;
                    else
                        next_state <= warning_2;
                    end if;
                end if;
            
            when warning_1 =>
                if BTNC = '1' then
                    next_state <= error;
                else
                    if long_t >= natural(to_integer(unsigned(RAND_NUM1))) then
                    --if t >= 999 then
                        next_state <= counting;
                    else
                        next_state <= warning_1;
                    end if;
                end if;
            
            when counting =>
                if BTNC = '1' then
                    next_state <= convert;
                else
                    next_state <= counting;
                end if;
            
            when convert =>
                if t >= 100 then
                    next_state <= print_recent;
                else
                    next_state <= convert;
                end if;
            
            when print_recent =>                    --Prints only latest raw time
                if (BTNC = '1' and t = 999) then    --t = 999 to prevent instant state cycling
                    next_state <= rand_gen;
                elsif (BTNL = '1' and t = 999) then -- Reset all records and display 0000
                    next_state <= reset;
                    alu_sig <= "0000";
                elsif (BTNR = '1' and t = 999) then -- Display average on 7seg
                    next_state <= loop_records;
                    alu_sig <= "0001";
                elsif (BTNU = '1' and t = 999) then -- Display longest time on 7seg
                    next_state <= loop_records;
                    alu_sig <= "0010";
                elsif (BTND = '1' and t = 999) then -- Display shortest on 7seg
                    next_state <= loop_records;
                    alu_sig <= "0011";
                else
                    next_state <= print_recent;
                end if;
            
            when print_records =>                   --Prints processed numbers
                if (BTNC = '1' and t = 999) then
                    next_state <= rand_gen;
                elsif (BTNL = '1' and t = 999) then -- Reset all records and display 0000
                    next_state <= reset;
                    alu_sig <= "0000";
                elsif (BTNR = '1' and t = 999) then -- Display average on 7seg
                    next_state <= loop_records;
                    alu_sig <= "0001";
                elsif (BTNU = '1' and t = 999) then -- Display longest time on 7seg
                    next_state <= loop_records;
                    alu_sig <= "0010";
                elsif (BTND = '1' and t = 999) then -- Display shortest on 7seg
                    next_state <= loop_records;
                    alu_sig <= "0011";
                else
                    next_state <= print_records;
                end if;
            
            when loop_records =>                    --Time buffer for ALU
                if t >= 999 then
                    next_state <= print_records;
                else
                    next_state <= loop_records;
                end if;
            
            when error =>                           --Display ERR when BTNC pushed while counting down
                if (BTNC = '1' and t = 999) then
                    next_state <= rand_gen;
                else
                    next_state <= error;
                end if;
            
            when reset =>                           --Reset all recorded times and display 0000 and wait
                if (BTNC = '1' and t = 999) then
                    next_state <= rand_gen;
                else
                    next_state <= reset;
                end if;

            when others =>
                next_state <= current_state;
        end case;
    end process;

    ALU_CONTROL <= alu_sig;

    TIMER: process (CLK)
    begin
        if rising_edge(CLK) then        --MS clock
            if current_state /= next_state then
                t <= 0;
                long_t <= 0;
            elsif t /= T1-1 then
                t <= t + 1;
                long_t <= long_t + 1; --Long timer for random decimal count down
            elsif long_t < T2-1 then
                long_t <= long_t + 1;
            end if;
        end if;
    end process;

end Behavioral;
----------------------------------------------------------------------------------
-- Company: University of Canterbury
-- Engineers: Jack Willson, Oliver Butler, Mae Cradock 
-- 
-- Create Date: 24.04.2024 23:22:17
-- Module Name: convert_to_unsigned - Behavioral
-- Project Name: FPGA Reaction Timer
-- Target Devices: Nexys-A7
-- Description: Converts 4 decade counters to 
--
-- Revision 0.01 - Final
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity convert_to_unsign is
    Port ( 
    EN : in std_logic; --Enable after BTNC is pressed
    HARD_RESET : in std_logic; --When BTNL is pressed
    COUNT1, COUNT2, COUNT3, COUNT4 : in std_logic_vector (3 downto 0);
    NUM_RECORDS : out unsigned (3 downto 0);
    TIME1, TIME2, TIME3 : out unsigned (15 downto 0);
    SEED : out std_logic_vector(11 downto 0));
end convert_to_unsign;

architecture Behavioral of convert_to_unsign is
    signal t1, t2, t3 : unsigned (15 downto 0) := (others => '0');
    signal num_reads : unsigned (3 downto 0) := (others => '0');
    signal num_1 : unsigned (3 downto 0) := X"1"; --Unknown if needed but it works...
    signal rand_seed : std_logic_vector(11 downto 0) := X"73B"; -- 12 Bit Seed input
    begin
        process (EN) is
            variable num_var : unsigned (3 downto 0) := (others => '0');
            variable time_var : unsigned (15 downto 0) := (others => '0');
            begin
                if HARD_RESET = '1' then
                    num_var := (others => '0');
                    t1 <= (others => '0');
                    t2 <= (others => '0');
                    t3 <= (others => '0');
                elsif HARD_RESET = '0' then
                    if (rising_edge(EN)) then
                        --Shift recorded times down the buffer
                        t3 <= t2;
                        t2 <= t1;
                        --Times count 4 by 1000, count 3 by 100 and count 2 by 10 and sum together
                        time_var := to_unsigned(to_integer((unsigned(COUNT4) * X"3E8")) + to_integer((unsigned(COUNT3) * X"64")) + to_integer((unsigned(COUNT2) * X"A")) + to_integer((unsigned(COUNT1))), 16);
                        t1 <= time_var;
                        rand_seed <= std_logic_vector(to_unsigned(to_integer(time_var),12)); --Update seed
                        
                        num_var := num_var + num_1;
                        
                    end if;
                end if;
                
                num_reads <= num_var;
        end process;
        TIME1 <= t1;
        TIME2 <= t2;
        TIME3 <= t3;
        NUM_RECORDS <= num_reads;
        SEED <= rand_seed;
end Behavioral;

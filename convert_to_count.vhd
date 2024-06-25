----------------------------------------------------------------------------------
-- Company: University of Canterbury
-- Engineers: Jack Willson, Oliver Butler, Mae Cradock 
-- 
-- Create Date: 30.04.2024 16:44:00
-- Module Name: convert_to_count - Behavioral
-- Project Name: FPGA Reaction Timer
-- Target Devices: Nexys-A7
-- Description: Converts a 16 bit unsigned to four 'decade' counters ready to be displayed on 7-seg
--
-- Revision 0.01 - Final
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;


entity convert_to_count is
    Port (
    EN : in std_logic;  --Clk input
    INPUT : in unsigned (15 downto 0);
    OUT1, OUT2, OUT3, OUT4 : out std_logic_vector (3 downto 0));
end convert_to_count;

architecture Behavioral of convert_to_count is
    signal count1, count2, count3, count4 : unsigned (3 downto 0) := (others => '0');
    signal unsign : unsigned (15 downto 0) := (others => '0');
    signal thou : unsigned (15 downto 0) := X"03E8"; --For division by 1000
    signal hund : unsigned (15 downto 0) := X"0064";  --For division by 100
    signal ten : unsigned (15 downto 0) := X"000A";    --For division by 10
    
    begin
        process (EN) is
            variable input_sig : unsigned (15 downto 0);
            begin
                input_sig := INPUT;
                if (rising_edge(EN)) then
                    count4 <= to_unsigned(to_integer(input_sig / thou), 4); --Integer division
                    input_sig := input_sig - to_unsigned(to_integer(to_unsigned(to_integer(count4),16) * thou), 16); --Minus off the 1000's
                    
                    count3 <= to_unsigned(to_integer(input_sig / hund), 4);
                    input_sig := input_sig - to_unsigned(to_integer(to_unsigned(to_integer(count3),16) * hund), 16); --Minus off the 100's
                    
                    count2 <= to_unsigned(to_integer(input_sig / ten), 4);
                    input_sig := input_sig - to_unsigned(to_integer(to_unsigned(to_integer(count2),16) * ten), 16);  --Minus off the 10's
                    
                    count1 <= to_unsigned(to_integer(input_sig),4);
                end if;
                
        end process;
        OUT1 <= std_logic_vector(count1);
        OUT2 <= std_logic_vector(count2);
        OUT3 <= std_logic_vector(count3);
        OUT4 <= std_logic_vector(count4);
        


end Behavioral;

----------------------------------------------------------------------------------
-- Company: University of Canterbury
-- Engineers: Jack Willson, Oliver Butler, Mae Cradock 
-- 
-- Create Date: 12.03.2024 16:11:43
-- Module Name: bcd_to_7seg - Behavioral
-- Project Name: FPGA Reaction Timer
-- Target Devices: Nexys-A7
-- Description: Converts binary coded digit into an array for the seven-segment display.
--
-- Revision 0.01 - Final
----------------------------------------------------------------------------------



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity bcd_to_7seg is
    port (  BCD : in STD_LOGIC_VECTOR (3 downto 0);
            DP : in STD_LOGIC;
            SEG : out STD_LOGIC_VECTOR (0 to 7));
end bcd_to_7seg;

architecture Behavioral of bcd_to_7seg is
    begin
        process (BCD) is
        begin
            case (BCD) is
                when "0000" => SEG(0 to 6) <= "1111110"; -- 0
                when "0001" => SEG(0 to 6) <= "0110000"; -- 1
                when "0010" => SEG(0 to 6) <= "1101101"; -- 2
                when "0011" => SEG(0 to 6) <= "1111001"; -- 3
                when "0100" => SEG(0 to 6) <= "0110011"; -- 4
                when "0101" => SEG(0 to 6) <= "1011011"; -- 5
                when "0110" => SEG(0 to 6) <= "1011111"; -- 6
                when "0111" => SEG(0 to 6) <= "1110000"; -- 7
                when "1000" => SEG(0 to 6) <= "1111111"; -- 8
                when "1001" => SEG(0 to 6) <= "1110011"; -- 9
                when "1010" => SEG(0 to 6) <= "0000000"; -- blank
                when "1011" => SEG(0 to 6) <= "0100000"; -- max
                when "1100" => SEG(0 to 6) <= "0000001"; -- average
                when "1101" => SEG(0 to 6) <= "0010000"; -- min
                when "1110" => SEG(0 to 6) <= "1001111"; -- E
                when "1111" => SEG(0 to 6) <= "0000101"; -- R
                when others => NULL;
            end case;
        end process;
    SEG(7) <= DP;
end Behavioral;

----------------------------------------------------------------------------------
-- Company: University of Canterbury
-- Engineers: Jack Willson, Oliver Butler, Mae Cradock 
-- 
-- Create Date: 12.03.2024 14:19:11
-- Module Name: module3anodes - Behavioral
-- Project Name: FPGA Reaction Timer
-- Target Devices: Nexys-A7
-- Description: Outputs an anode array based on current displaying segment
--
-- Revision 0.01 - Final
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity module3anodes is
    Port ( DISPLAY_SELECTED : in STD_LOGIC_VECTOR (3 downto 0);
           ANODE : out STD_LOGIC_VECTOR (7 downto 0));
end module3anodes;

architecture Behavioral of module3anodes is

signal anode_sig : STD_LOGIC_VECTOR (7 downto 0);

begin
    anodeselector : process (DISPLAY_SELECTED) is
    begin
        case (DISPLAY_SELECTED) is
            when "0000" =>  anode_sig <= "01111111";    --Nexys A7 7-seg displays are active low
            when "0001" =>  anode_sig <= "10111111";
            when "0010" =>  anode_sig <= "11011111";
            when "0011" =>  anode_sig <= "11101111";
            when "0100" =>  anode_sig <= "11110111";
            when "0101" =>  anode_sig <= "11111011";
            when "0110" =>  anode_sig <= "11111101";
            when "0111" =>  anode_sig <= "11111110";
            when others => NULL;
        end case;
    end process; 
    ANODE <= anode_sig;

end Behavioral;

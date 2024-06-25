----------------------------------------------------------------------------------
-- Company: University of Canterbury
-- Engineers: Jack Willson, Oliver Butler, Mae Cradock 
-- 
-- Create Date: 24.04.2024 17:21:39
-- Module Name: display_scan - Behavioral
-- Project Name: FPGA Reaction Timer
-- Target Devices: Nexys-A7
-- Description: Pulls digits from MESSAGE array and set decimal point on 7-seg array, cycles through the right-hand 4 displays
--
-- Revision 0.01 - Final
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity display_scan is
    Port ( DISP_CLOCK : in STD_LOGIC;   --500Hz clock signal
           CUR_DISP : in STD_LOGIC_VECTOR (3 downto 0); --Display counter
           DEC_ARR : in STD_LOGIC_VECTOR (31 downto 0);
           MESSAGE : in STD_LOGIC_VECTOR (31 downto 0);
           DECIMAL : out STD_LOGIC;                     --Decimal out to BCD module
           DIGIT : out STD_LOGIC_VECTOR (3 downto 0);   --Digit out to BCD module
           NEXT_DISP : out STD_LOGIC_VECTOR (3 downto 0));
end display_scan;

architecture Behavioral of display_scan is
    
    signal next_disp_sig : STD_LOGIC_VECTOR (3 downto 0) := "0000";
    
    begin
    
        display : process (DISP_CLOCK) is
            begin
        
                if rising_edge(DISP_CLOCK) then
                    case (CUR_DISP) is
                        when "0000" =>
                            next_disp_sig <= "0001";    --Increment display counter
                            DECIMAL <= DEC_ARR(4);          --Pull decimal bit for this segment
                            DIGIT <= MESSAGE(7 downto 4);   --Pull 4 bit digit from MESSAGE
                        when "0001" =>
                            next_disp_sig <= "0010";
                            DECIMAL <= DEC_ARR(8);
                            DIGIT <= MESSAGE(11 downto 8);
                        when "0010" =>
                            next_disp_sig <= "0011";
                            DECIMAL <= DEC_ARR(12);
                            DIGIT <= MESSAGE(15 downto 12);
                        when "0011" =>
                            next_disp_sig <= "0000";
                            DECIMAL <= DEC_ARR(0);
                            DIGIT <= MESSAGE(3 downto 0);
                        when others =>
                            
                    end case;
                
                end if;
            end process;
            
            NEXT_DISP <= next_disp_sig;
            
    
    

end Behavioral;

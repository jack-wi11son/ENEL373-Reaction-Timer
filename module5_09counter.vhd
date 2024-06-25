----------------------------------------------------------------------------------
-- Company: University of Canterbury
-- Engineers: Jack Willson, Oliver Butler, Mae Cradock 
-- 
-- Create Date: 12.03.2024 16:18:49
-- Module Name: module5_09counter - Behavioral
-- Project Name: FPGA Reaction Timer
-- Target Devices: Nexys-A7
-- Description: Decade counter with tick output
--
-- Revision 0.01 - Final
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity module5_09counter is
    Port ( EN : in STD_LOGIC;
           RESET : in STD_LOGIC;
           INCREMENT : in STD_LOGIC;
           COUNT : out STD_LOGIC_VECTOR (3 downto 0);
           TICK : out STD_LOGIC);
end module5_09counter;

architecture Behavioral of module5_09counter is

signal count_sig : STD_LOGIC_VECTOR(3 downto 0) := "0000";
signal tick_sig : STD_LOGIC := '0';

begin
    process (EN, RESET, INCREMENT) is
        begin
            if RESET = '1' then
                count_sig <= (others => '0');
                tick_sig <= '0';
            else
                if EN = '1' then
                    if rising_edge(INCREMENT) then
                        count_sig <= std_logic_vector(unsigned(count_sig) + 1);
                        if count_sig = "1001" then --max 9
                            count_sig <= (others => '0');
                            tick_sig <= '1';
                        end if;
                        if count_sig = "0101" then -- turn tick signal low half way through
                            tick_sig <= '0';
                        end if;
                    end if;
                end if;
            end if;
            
    
    end process;
    COUNT <= count_sig;
    TICK <= tick_sig;
    
    
end Behavioral;

----------------------------------------------------------------------------------
-- Company: University of Canterbury
-- Engineers: Jack Willson, Oliver Butler, Mae Cradock 
-- 
-- Create Date: 07.05.2024 01:53:40
-- Module Name: PRNG - Behavioral
-- Project Name: FPGA Reaction Timer
-- Target Devices: Nexys-A7
-- Description: A pseudo random number generator that uses a linear feedback shift register and a input seed.
--    Outputs three pseudo random numbers for the three count down decimal points
--
-- Revision 0.01 - Final
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PRNG is
    Port (
        CLK, EN: in std_logic;         
        SEED_IN : in std_logic_vector(11 downto 0);  
        RAND_OUT1, RAND_OUT2, RAND_OUT3 : out std_logic_vector(11 downto 0));  
end PRNG;

architecture Behavioral of PRNG is
    signal lfsr1 : std_logic_vector(11 downto 0) := X"A25";  -- 12-bit LFSR -- random initial value
    signal lfsr2 : std_logic_vector(11 downto 0) := X"58d";  -- 12-bit LFSR -- random initial value
    signal lfsr3 : std_logic_vector(11 downto 0) := X"8c2";  -- 12-bit LFSR -- random initial value
begin

    -- 3x Linear Feedback Shift Register (LFSR)
    process(CLK)
    begin
        if en = '1' then
            if rising_edge(CLK) then
                
                lfsr1(11 downto 1) <= lfsr1(10 downto 0);
                lfsr1(0) <= not (lfsr1(7) xor lfsr1(2));  
                
                lfsr2(11 downto 1) <= lfsr2(10 downto 0);
                lfsr2(0) <= not (lfsr2(7) xor lfsr2(2));  
                
                lfsr3(11 downto 1) <= lfsr3(10 downto 0);
                lfsr3(0) <= not (lfsr3(7) xor lfsr3(2)); 
                 
            end if;
        end if;
    end process;

    -- Outputs the random number and XOR's with current input seed
    RAND_OUT1 <= lfsr1 XOR SEED_IN;
    RAND_OUT2 <= lfsr2 XOR SEED_IN;
    RAND_OUT3 <= lfsr3 XOR SEED_IN;

end Behavioral;



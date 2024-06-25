----------------------------------------------------------------------------------
-- Company: University of Canterbury
-- Engineers: Jack Willson, Oliver Butler, Mae Cradock 
-- 
-- Create Date: 28.02.2024 16:09:52
-- Module Name: clock_divider - Behavioral
-- Project Name: FPGA Reaction Timer
-- Target Devices: Nexys-A7
-- Description: Divides the clock for ms timing and display refresh.
--
-- Revision 0.01 - Final
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity clock_divider is
    Port ( CLK : in STD_LOGIC; --100MHz input clock
           DISP_CLK : out STD_LOGIC;
           MS_CLK : out STD_LOGIC);
end clock_divider;

architecture Behavioral of clock_divider is
    
    signal upperbound_disp : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000110000110101000000"; --Scan 7-seg displays at 500Hz
    --signal upperbound_disp : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000100100"; --fast
    signal count_disp: std_logic_vector (31 downto 0) := (others => '0');
    signal disp_clk_sig : std_logic := '0';
    
    --signal upperbound_ms : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000001100001101010000"; --Real millisecond clock
    --signal upperbound_ms : STD_LOGIC_VECTOR (31 downto 0) := "00000000000001100010010110100000"; --50 ms period
    signal upperbound_ms : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000010"; --fast for sim
    signal count_ms: std_logic_vector (31 downto 0) := (others => '0');
    signal ms_clk_sig : std_logic := '0';
    
    begin
        clock: process (CLK) is
            begin
                if rising_edge(CLK) then
                    count_disp <= std_logic_vector(unsigned(count_disp) + 1);
                    count_ms <= std_logic_vector(unsigned(count_ms) + 1); 
                    
                    
                    if count_disp = upperbound_disp then
                        count_disp <= (others => '0');
                        disp_clk_sig <= not(disp_clk_sig);
                    end if;
                    
                    if count_ms = upperbound_ms then
                        count_ms <= (others => '0');
                        ms_clk_sig <= not(ms_clk_sig);
                    end if;
                end if;
         end process;
         DISP_CLK <= disp_clk_sig;
         MS_CLK <= ms_clk_sig;
         
    
end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.05.2024 19:51:21
-- Design Name: 
-- Module Name: top_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_tb is
--  Port ( );
end top_tb;

architecture Behavioral of top_tb is

    component module7_top is
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
    end component;
    
    signal CLK : std_logic;
    signal BTNC, BTNU, BTND, BTNL, BTNR : STD_LOGIC := '0';
    signal time1 : unsigned(31 downto 0) := (others => '0');

begin
    UUT: module7_top port map (
    CLK100MHZ => CLK,
    BTNC => BTNC,
    BTNR => BTNR,
    BTNU => BTNU,
    BTND => BTND,
    BTNL => BTNL
    );
    
    top_process : process
    begin
        CLK <= '0';
        wait for 5 ns;
        CLK <= '1';
        wait for 5 ns;
        time1 <= time1 + 1; 
        
        if (time1 = 330 * 100 or time1 = 331 * 100) then 
            BTNC <= not BTNC;
        end if;
        
        if (time1 = 400 * 100 or time1 = 401 * 100) then 
            BTNR <= not BTNR;
        end if;
        
        if (time1 = 500 * 100 or time1 = 501 * 100) then 
            BTNC <= not BTNC;
        end if;
        
        if (time1 = 700 * 100 or time1 = 701 * 100) then 
            BTNC <= not BTNC;
        end if;
        
        if (time1 = 800 * 100 or time1 = 801 * 100) then 
            BTNR <= not BTNR;
        end if;
        
        if (time1 = 1000 * 100 or time1 = 1001 * 100) then 
            BTNC <= not BTNC;
        end if;
        if (time1 = 1200 * 100 or time1 = 1201 * 100) then 
            BTNC <= not BTNC;
        end if;
        if (time1 = 1300 * 100 or time1 = 1301 * 100) then 
            BTNR <= not BTNR;
        end if;
    end process;
    
    

end Behavioral;

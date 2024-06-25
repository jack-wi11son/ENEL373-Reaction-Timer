----------------------------------------------------------------------------------
-- Company: University of Canterbury
-- Engineers: Jack Willson, Oliver Butler, Mae Cradock 
-- 
-- Create Date: 30.04.2024 17:49:24
-- Module Name: ALU - Behavioral
-- Project Name: FPGA Reaction Timer
-- Target Devices: Nexys-A7
-- Description: Returns Average, Maximum and Minimum based on control line input and the last three current recorded times.
--
-- Revision 0.01 - Final
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;


entity ALU is
    Port ( 
    EN : in std_logic; --A clk signal
    EXECUTE : in std_logic_vector (3 downto 0); --Control Input
    TIME1, TIME2, TIME3 : in unsigned(15 downto 0);
    NUM_REC : in unsigned(3 downto 0);
    OUTPUT : out unsigned(15 downto 0));
end ALU;

architecture Behavioral of ALU is
    signal outout : unsigned(15 downto 0) := X"0000";
    signal test : unsigned(15 downto 0) := X"0012"; --Debuggng purposes 18
    
    begin
        alu : process (EN) is
            --Changed all time processing to variables to help debug
            variable num_var : unsigned(3 downto 0) := X"0";
            variable output_var : unsigned(15 downto 0) := X"0000";
            variable time1v : unsigned(15 downto 0);
            variable time2v : unsigned(15 downto 0);
            variable time3v : unsigned(15 downto 0);

            begin
                num_var := NUM_REC;
                output_var := X"0010"; --Debugging purposes 16
                time1v := TIME1;
                time2v := TIME2;
                time3v := TIME3;
                
                if (rising_edge(EN)) then
                    case EXECUTE is 
                        when "0000" => 
                            output_var := X"0013"; --Debuging purposes 19
                            
                        when "0001" => -- When control equals 0001 it returns the average time of the three latest inputs.
                            if (num_var > 2) then
                                output_var := to_unsigned(to_integer(((time1v + time2v + time3v) & '0') / "110"), 16); --Times by 2 using concat then divide by 6 (Because unsigned cant divide by 3)
                            elsif (num_var = 2) then
                                output_var := to_unsigned(to_integer((time1v + time2v) / "10"), 16);
                            else
                                output_var := time1v;
                            end if;
                            
                        when "0010" =>    -- When control equals 0010 it returns the largest time out of the three latest inputs.
                            if (time1v > time2v and time1v > time3v) then
                                output_var := time1v;
                            elsif (time2v > time1v and time2v > time3v) then
                                output_var := time2v;
                            else
                                output_var := time3v;
                            end if;
                            
                        when "0011" =>    -- When control equals 0011 it returns the smallest time out of the three latest inputs.
                            if (num_var = 1) then
                                output_var := time1v;
                            
                            elsif (num_var = 2) then
                                if (time1v < time2v) then
                                    output_var := time1v;
                                else
                                    output_var := time2v;
                                end if;
                            
                            elsif (num_var > 2) then
                                if (time1v < time2v and time1v < time3v) then
                                    output_var := time1v;
                                elsif (time2v < time1v and time2v < time3v) then
                                    output_var := time2v;
                                else
                                    output_var := time3v;
                                end if; 
                            end if;

                        when others =>
                            output_var := X"270E"; -- 9998 for debugging            
                    end case;
                    outout <= output_var;
                end if;
        end process;
        OUTPUT <= outout;
        

end Behavioral;

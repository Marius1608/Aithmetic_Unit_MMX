library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity compare_8bit is
    Port (
        a, b : in std_logic_vector(7 downto 0);
        result : out std_logic_vector(7 downto 0)
    );
end compare_8bit;


architecture Behavioral of compare_8bit is
begin
    process(a, b)
    begin
        if a = b then
            result <= (others => '1'); 
        else
            result <= (others => '0');  
        end if;
    end process;
end Behavioral;

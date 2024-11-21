library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity parallel_pcmpeqw is
    Port (
        a, b : in std_logic_vector(63 downto 0);
        result : out std_logic_vector(63 downto 0)
    );
end parallel_pcmpeqw;

architecture Behavioral of parallel_pcmpeqw is
begin
    process(a, b)
    begin
        for i in 0 to 3 loop
            if a((i+1)*16-1 downto i*16) = b((i+1)*16-1 downto i*16) then
                result((i+1)*16-1 downto i*16) <= X"FFFF"; 
            else
                result((i+1)*16-1 downto i*16) <= X"0000";  
            end if;
        end loop;
    end process;
end Behavioral;
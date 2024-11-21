library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity parallel_logical_ops is
    Port (
        a, b : in std_logic_vector(63 downto 0);
        operation : in std_logic_vector(1 downto 0);  -- 00: PAND, 01: POR, 10: PXOR
        result : out std_logic_vector(63 downto 0)
    );
end parallel_logical_ops;

architecture Behavioral of parallel_logical_ops is
begin
    process(a, b, operation)
    begin
        case operation is
            when "00" =>  -- PAND 
                for i in 0 to 3 loop
                    result((i+1)*16-1 downto i*16) <= a((i+1)*16-1 downto i*16) and b((i+1)*16-1 downto i*16);
                end loop;
            
            when "01" =>  -- POR 
                for i in 0 to 3 loop
                    result((i+1)*16-1 downto i*16) <= a((i+1)*16-1 downto i*16) or b((i+1)*16-1 downto i*16);
                end loop;
            
            when "10" =>  -- PXOR 
                for i in 0 to 3 loop
                    result((i+1)*16-1 downto i*16) <= a((i+1)*16-1 downto i*16) xor b((i+1)*16-1 downto i*16);
                end loop;
            
            when others =>  
                result <= (others => '0');
        end case;
    end process;
end Behavioral;
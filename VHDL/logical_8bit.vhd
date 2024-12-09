library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity logical_8bit is
    Port (
        a, b : in std_logic_vector(7 downto 0);
        op_type : in std_logic_vector(1 downto 0);  -- "00": AND, "01": OR, "10": XOR
        result : out std_logic_vector(7 downto 0);
        result_valid : out std_logic  -- Used for mux control
    );
end logical_8bit;


architecture Behavioral of logical_8bit is
begin
    process(a, b, op_type)
    begin
        case op_type is
            when "00" =>   -- PAND
                result <= a and b;
            when "01" =>   -- POR
                result <= a or b;
            when "10" =>   -- PXOR
                result <= a xor b;
            when others =>
                result <= (others => '0');
        end case;
        result_valid <= '1';  
    end process;
end Behavioral;
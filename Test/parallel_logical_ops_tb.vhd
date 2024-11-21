library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity parallel_logical_ops_tb is
end parallel_logical_ops_tb;

architecture Behavioral of parallel_logical_ops_tb is
    
    signal a, b : std_logic_vector(63 downto 0);
    signal operation : std_logic_vector(1 downto 0);
    signal result : std_logic_vector(63 downto 0);

    component parallel_logical_ops
        Port (
            a, b : in std_logic_vector(63 downto 0);
            operation : in std_logic_vector(1 downto 0);
            result : out std_logic_vector(63 downto 0)
        );
    end component;
begin
    
    component_log: parallel_logical_ops
        port map (
            a => a,
            b => b,
            operation => operation,
            result => result
        );

    
    sim: process
    begin
        
        a <= x"FFFF0000FFFF0000";
        b <= x"0F0F0F0F0F0F0F0F";
        operation <= "00"; -- PAND
        wait for 10 ns;
        -- result = x"0F0F00000F0F0000"
        
       
        a <= x"FFFF0000FFFF0000";
        b <= x"0F0F0F0F0F0F0F0F";
        operation <= "01"; -- POR
        wait for 10 ns;
        -- result = x"FFFF0F0FFFFF0F0F"
        

        a <= x"FFFF0000FFFF0000";
        b <= x"0F0F0F0F0F0F0F0F";
        operation <= "10"; -- PXOR
        wait for 10 ns;
        -- result = x"F0F00F0FF0F00F0F"
        
        
        operation <= "11"; -- Cod nevalid
        wait for 10 ns;
        -- result = (others => '0')
        
        wait;
    end process;
end Behavioral;

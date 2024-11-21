
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity parallel_packed_arithmetic_add_tb is
end parallel_packed_arithmetic_add_tb;

architecture Behavioral of parallel_packed_arithmetic_add_tb is
    
    component parallel_packed_arithmetic
        Port (
            a, b : in std_logic_vector(63 downto 0);
            operation : in std_logic_vector(2 downto 0);
            result : out std_logic_vector(63 downto 0)
        );
    end component;
    
   
    signal a_in, b_in : std_logic_vector(63 downto 0) := (others => '0');
    signal op : std_logic_vector(2 downto 0) := "000";
    signal result_out : std_logic_vector(63 downto 0);
    
begin
   
    component_add: parallel_packed_arithmetic port map (
        a => a_in,
        b => b_in,
        operation => op,
        result => result_out
    );
    
    
    stim_proc: process
    begin
        -- Test 1: Bytes 
        op <= "000";  
        a_in <= X"0102030405060708";  
        b_in <= X"0808080808080808";  
        wait for 20 ns;
        -- Rez=090A0B0C0D0E0F10
        
        -- Test 2: Words 
        op <= "001";  
        a_in <= X"0001000200030004";  
        b_in <= X"1000100010001000";  
        wait for 20 ns;
        -- Rez=1001100210031004
        
        -- Test 3: DWords 
        op <= "010";  
        a_in <= X"0000000100000002"; 
        b_in <= X"1000000010000000";  
        wait for 20 ns;
        -- Rez=1000000110000002
        
        -- Test 4: Saturatie
        op <= "000";  
        a_in <= X"FF_FF_FF_FF_FF_FF_FF_FF";  
        b_in <= X"01_01_01_01_01_01_01_01";  
        wait for 20 ns;
       
        wait;  
    end process;
end Behavioral;
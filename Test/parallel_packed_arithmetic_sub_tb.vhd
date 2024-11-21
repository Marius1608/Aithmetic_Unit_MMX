library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity parallel_packed_arithmetic_sub_tb is
end parallel_packed_arithmetic_sub_tb;

architecture Behavioral of parallel_packed_arithmetic_sub_tb is
    
    component parallel_packed_arithmetic
        Port (
            a, b : in std_logic_vector(63 downto 0);
            operation : in std_logic_vector(2 downto 0);
            result : out std_logic_vector(63 downto 0)
        );
    end component;
    
    signal a_in, b_in : std_logic_vector(63 downto 0) := (others => '0');
    signal op : std_logic_vector(2 downto 0) := "100"; --Scadere
    signal result_out : std_logic_vector(63 downto 0);
    
begin
   
    component_sub: parallel_packed_arithmetic port map (
        a => a_in,
        b => b_in,
        operation => op,
        result => result_out
    );
    
   
    stim_proc: process
    begin
        -- Test 1: Bytes 
        op <= "100";  
        a_in <= X"0808080808080808";  
        b_in <= X"0102030405060708";  
        wait for 10 ns;
        -- Rez=0706050403020100
        
        -- Test 2: Words 
        op <= "101";  
        b_in <= X"0001000200030004";  
        wait for 10 ns;
        -- Rez=0FFF0FFE0FFD0FFC
        
        -- Test Case 3: DWords 
        op <= "110";
        a_in <= X"1000000010000000";  
        b_in <= X"0000000100000002";  
        wait for 10 ns;
        -- Rez=0FFFFFFF0FFFFFFE
        
        -- Test 4:  Saturatie 
        op <= "100";  
        a_in <= X"00_00_00_00_00_00_00_00"; 
        b_in <= X"01_01_01_01_01_01_01_01"; 
        wait for 10 ns;
     
        
        -- Test 5: Numere Negative (Signed)
        op <= "100";  
        a_in <= X"80_80_80_80_80_80_80_80";  
        b_in <= X"01_01_01_01_01_01_01_01";  
        wait for 10 ns;
        -- Rez = 80 (minimum signed value)
        
        wait; 
    end process;
end Behavioral;
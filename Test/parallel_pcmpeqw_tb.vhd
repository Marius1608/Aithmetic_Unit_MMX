library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity parallel_pcmpeqw_tb is
end  parallel_pcmpeqw_tb;

architecture Behavioral of  parallel_pcmpeqw_tb is
    component parallel_pcmpeqw
        Port (
            a, b : in std_logic_vector(63 downto 0);
            result : out std_logic_vector(63 downto 0)
        );
    end component;

    signal a_tb : std_logic_vector(63 downto 0);
    signal b_tb : std_logic_vector(63 downto 0);
    signal result_tb : std_logic_vector(63 downto 0);

begin
    comp_pcmpeqw: parallel_pcmpeqw Port map (
        a => a_tb,
        b => b_tb,
        result => result_tb
    );

    stim_proc: process
    begin
        
        a_tb <= X"1234567890ABCDEF";
        b_tb <= X"1234567890ABCDEF";
        wait for 10 ns;
        
        a_tb <= X"1111222233334444";
        b_tb <= X"AAAA888877776666";
        wait for 10 ns;
       
        a_tb <= X"1111222233334444";
        b_tb <= X"1111888833337777";
        wait for 10 ns;
        
        a_tb <= X"0000000000000000";
        b_tb <= X"0000000000000000";
        wait for 10 ns;
        
        wait;
    end process;
end Behavioral;
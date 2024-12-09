library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity parallel_compare_equality_tb is
end parallel_compare_equality_tb;

architecture Behavioral of parallel_compare_equality_tb is
    -- Component Declaration
    component parallel_compare_equality is
        Port (
            a, b : in std_logic_vector(63 downto 0);
            operation : in std_logic_vector(1 downto 0);
            result : out std_logic_vector(63 downto 0)
        );
    end component;
    
    -- Test Signals
    signal a_tb, b_tb : std_logic_vector(63 downto 0);
    signal operation_tb : std_logic_vector(1 downto 0);
    signal result_tb : std_logic_vector(63 downto 0);
    
    -- Constants for readability
    constant PCMPEQB : std_logic_vector(1 downto 0) := "00";
    constant PCMPEQW : std_logic_vector(1 downto 0) := "01";
    constant PCMPEQD : std_logic_vector(1 downto 0) := "10";
    
begin
    -- Component Instantiation
    test: parallel_compare_equality port map (
        a => a_tb,
        b => b_tb,
        operation => operation_tb,
        result => result_tb
    );
    
    -- Test Process
    test_proc: process
    begin
        -- Test Case 1: Byte Compare - All Equal
        a_tb <= X"1122334455667788";
        b_tb <= X"1122334455667788";
        operation_tb <= PCMPEQB;
        wait for 10 ns;
        assert result_tb = X"FFFFFFFFFFFFFFFF"
            report "Test Case 1 Failed: Byte Compare All Equal"
            severity ERROR;
            
        -- Test Case 2: Byte Compare - Some Equal
        a_tb <= X"1122334455667788";
        b_tb <= X"1122334455667700";
        operation_tb <= PCMPEQB;
        wait for 10 ns;
        assert result_tb = X"FFFFFFFFFFFF0000"
            report "Test Case 2 Failed: Byte Compare Some Equal"
            severity ERROR;
            
        -- Test Case 3: Word Compare - All Equal
        a_tb <= X"1122334455667788";
        b_tb <= X"1122334455667788";
        operation_tb <= PCMPEQW;
        wait for 10 ns;
        assert result_tb = X"FFFFFFFFFFFFFFFF"
            report "Test Case 3 Failed: Word Compare All Equal"
            severity ERROR;
            
        -- Test Case 4: Word Compare - Some Equal
        a_tb <= X"1122334455660000";
        b_tb <= X"1122334455667788";
        operation_tb <= PCMPEQW;
        wait for 10 ns;
        assert result_tb = X"FFFFFF0000000000"
            report "Test Case 4 Failed: Word Compare Some Equal"
            severity ERROR;
            
        -- Test Case 5: Double Word Compare - All Equal
        a_tb <= X"1122334455667788";
        b_tb <= X"1122334455667788";
        operation_tb <= PCMPEQD;
        wait for 10 ns;
        assert result_tb = X"FFFFFFFFFFFFFFFF"
            report "Test Case 5 Failed: Double Word Compare All Equal"
            severity ERROR;
            
        -- Test Case 6: Double Word Compare - None Equal
        a_tb <= X"1122334400000000";
        b_tb <= X"1122334455667788";
        operation_tb <= PCMPEQD;
        wait for 10 ns;
        assert result_tb = X"00000000FFFFFFFF"
            report "Test Case 6 Failed: Double Word Compare None Equal"
            severity ERROR;
            
        -- Test Case 7: Invalid Operation
        a_tb <= X"1122334455667788";
        b_tb <= X"1122334455667788";
        operation_tb <= "11";
        wait for 10 ns;
        assert result_tb = X"0000000000000000"
            report "Test Case 7 Failed: Invalid Operation"
            severity ERROR;
        
        -- Test Case 8: Zero Values Compare
        a_tb <= X"0000000000000000";
        b_tb <= X"0000000000000000";
        operation_tb <= PCMPEQB;
        wait for 10 ns;
        assert result_tb = X"FFFFFFFFFFFFFFFF"
            report "Test Case 8 Failed: Zero Values Compare"
            severity ERROR;
        
        report "All test cases completed";
        wait;
    end process;
end Behavioral;
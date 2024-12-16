library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity parallel_compare_equality_tb is
end parallel_compare_equality_tb;


architecture Behavioral of parallel_compare_equality_tb is
   
    component parallel_compare_equality is
        Port (
            a, b : in std_logic_vector(63 downto 0);
            operation : in std_logic_vector(1 downto 0);
            result : out std_logic_vector(63 downto 0)
        );
    end component;
    
    signal a_tb, b_tb : std_logic_vector(63 downto 0);
    signal operation_tb : std_logic_vector(1 downto 0);
    signal result_tb : std_logic_vector(63 downto 0);
  
    constant PCMPEQB : std_logic_vector(1 downto 0) := "00";
    constant PCMPEQW : std_logic_vector(1 downto 0) := "01";
    constant PCMPEQD : std_logic_vector(1 downto 0) := "10";
    
begin
    
    test: parallel_compare_equality port map (
        a => a_tb,
        b => b_tb,
        operation => operation_tb,
        result => result_tb
    );
    
    test_proc: process
        variable test_count : integer := 0;
        variable pass_count : integer := 0;
    begin
    
        -- Test 1
        test_count := test_count + 1;
        a_tb <= X"1122334455667788";
        b_tb <= X"1122334455667788";
        operation_tb <= PCMPEQB;
        wait for 10 ns;
        assert result_tb = X"FFFFFFFFFFFFFFFF"
            report "Test 1 Failed";
        if result_tb = X"FFFFFFFFFFFFFFFF" then
            pass_count := pass_count + 1;
        end if;
            
        -- Test 2
        test_count := test_count + 1;
        a_tb <= X"1122334455667788";
        b_tb <= X"1122334455667788";
        operation_tb <= PCMPEQW;
        wait for 10 ns;
        assert result_tb = X"FFFFFFFFFFFFFFFF"
            report "Test 3 Failed";
        if result_tb = X"FFFFFFFFFFFFFFFF" then
            pass_count := pass_count + 1;
        end if;
            
        -- Test 3
        test_count := test_count + 1;
        a_tb <= X"1122334455667788";
        b_tb <= X"1122334455667788";
        operation_tb <= PCMPEQD;
        wait for 10 ns;
        assert result_tb = X"FFFFFFFFFFFFFFFF"
            report "Test 5 Failed";
        if result_tb = X"FFFFFFFFFFFFFFFF" then
            pass_count := pass_count + 1;
        end if;
 
        -- Test 4
        test_count := test_count + 1;
        a_tb <= X"1122334455667788";
        b_tb <= X"1122334455667788";
        operation_tb <= "11";
        wait for 10 ns;
        assert result_tb = X"0000000000000000"
            report "Test 7 Failed";
        if result_tb = X"0000000000000000" then
            pass_count := pass_count + 1;
        end if;
        
        -- Test 5
        test_count := test_count + 1;
        a_tb <= X"0000000000000000";
        b_tb <= X"0000000000000000";
        operation_tb <= PCMPEQB;
        wait for 10 ns;
        assert result_tb = X"FFFFFFFFFFFFFFFF"
            report "Test 8 Failed";
        if result_tb = X"FFFFFFFFFFFFFFFF" then
            pass_count := pass_count + 1;
        end if;
       
        report integer'image(pass_count) & " out of " & integer'image(test_count) & " tests.";
        
        wait;
    end process;
end Behavioral;
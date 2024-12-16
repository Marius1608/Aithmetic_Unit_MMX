library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity parallel_logical_tb is
end parallel_logical_tb;


architecture sim of parallel_logical_tb is
    signal a, b: std_logic_vector(63 downto 0);
    signal operation: std_logic_vector(3 downto 0);  
    signal result: std_logic_vector(63 downto 0);
    
    component parallel_logical is
        Port (
            a, b: in std_logic_vector(63 downto 0);
            operation: in std_logic_vector(3 downto 0);  
            result: out std_logic_vector(63 downto 0)
        );
    end component;

begin
    test: parallel_logical port map (a => a, b => b, operation => operation, result => result);

    process
        variable test_count : integer := 0;
        variable pass_count : integer := 0;
    begin
        -- Test 1: Byte AND (0000)
        test_count := test_count + 1;
        operation <= "0000"; 
        a <= x"FF00FF00FF00FF00";
        b <= x"0F0F0F0F0F0F0F0F";
        wait for 10 ns;
        assert result = x"0F000F000F000F00"
            report "Test 1 Failed";
        if result = x"0F000F000F000F00" then
            pass_count := pass_count + 1;
        end if;

        -- Test 2: Byte OR (1000)
        test_count := test_count + 1;
        operation <= "1000";  
        a <= x"F0F0F0F0F0F0F0F0";
        b <= x"0F0F0F0F0F0F0F0F";
        wait for 10 ns;
        assert result = x"FFFFFFFFFFFFFFFF"
            report "Test 2 Failed";
        if result = x"FFFFFFFFFFFFFFFF" then
            pass_count := pass_count + 1;
        end if;

        -- Test 3: Byte XOR (0100)
        test_count := test_count + 1;
        operation <= "0100";  
        a <= x"AAAAAAAAAAAAAAAA";
        b <= x"5555555555555555";
        wait for 10 ns;
        assert result = x"FFFFFFFFFFFFFFFF"
            report "Test 3 Failed";
        if result = x"FFFFFFFFFFFFFFFF" then
            pass_count := pass_count + 1;
        end if;

        -- Test 4: Word AND (0001)
        test_count := test_count + 1;
        operation <= "0001";  
        a <= x"FFFF0000FFFF0000";
        b <= x"0F0F0F0F0F0F0F0F";
        wait for 10 ns;
        assert result = x"0F0F00000F0F0000"
            report "Test 4 Failed";
        if result = x"0F0F00000F0F0000" then
            pass_count := pass_count + 1;
        end if;

        -- Test 5: Word OR (1001)
        test_count := test_count + 1;
        operation <= "1001"; 
        a <= x"F0F00000F0F00000";
        b <= x"0F0F0F0F0F0F0F0F";
        wait for 10 ns;
        assert result = x"FFFF0F0FFFFF0F0F"
            report "Test 5 Failed";
        if result = x"FFFF0F0FFFFF0F0F" then
            pass_count := pass_count + 1;
        end if;

        -- Test 6: Word XOR (0101)
        test_count := test_count + 1;
        operation <= "0101";  
        a <= x"AAAA0000AAAA0000";
        b <= x"5555555555555555";
        wait for 10 ns;
        assert result = x"FFFF5555FFFF5555"
            report "Test 6 Failed";
        if result = x"FFFF5555FFFF5555" then
            pass_count := pass_count + 1;
        end if;

        -- Test 7: DWord AND (0010)
        test_count := test_count + 1;
        operation <= "0010";  
        a <= x"FFFFFFFF00000000";
        b <= x"0F0F0F0F0F0F0F0F";
        wait for 10 ns;
        assert result = x"0F0F0F0F00000000"
            report "Test 7 Failed";
        if result = x"0F0F0F0F00000000" then
            pass_count := pass_count + 1;
        end if;

        -- Test 8: DWord OR (1010)
        test_count := test_count + 1;
        operation <= "1010";  
        a <= x"F0F0F0F000000000";
        b <= x"0F0F0F0F0F0F0F0F";
        wait for 10 ns;
        assert result = x"FFFFFFFF0F0F0F0F"
            report "Test 8 Failed";
        if result = x"FFFFFFFF0F0F0F0F" then
            pass_count := pass_count + 1;
        end if;

        -- Test 9: DWord XOR (0110)
        test_count := test_count + 1;
        operation <= "0110"; 
        a <= x"AAAAAAAAAAAAAAAA";
        b <= x"5555555555555555";
        wait for 10 ns;
        assert result = x"FFFFFFFFFFFFFFFF"
            report "Test 9 Failed";
        if result = x"FFFFFFFFFFFFFFFF" then
            pass_count := pass_count + 1;
        end if;

        -- Test 10: Invalid operation (1111)
        test_count := test_count + 1;
        operation <= "1111";
        a <= x"FFFFFFFFFFFFFFFF";
        b <= x"FFFFFFFFFFFFFFFF";
        wait for 10 ns;
        assert result = x"0000000000000000"
            report "Test 10 Failed";
        if result = x"0000000000000000" then
            pass_count := pass_count + 1;
        end if;

        report "Passed " & integer'image(pass_count) & " out of " & integer'image(test_count) & " tests.";
        wait;
    end process;
end sim;
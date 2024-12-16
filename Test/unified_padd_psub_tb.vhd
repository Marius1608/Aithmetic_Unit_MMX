library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity unified_padd_psub_tb is
end unified_padd_psub_tb;


architecture sim of unified_padd_psub_tb is
    signal a, b, result: std_logic_vector(63 downto 0);
    signal operation: std_logic_vector(4 downto 0);
    
    component unified_padd_psub is
        Port (
            a, b: in std_logic_vector(63 downto 0);
            operation: in std_logic_vector(4 downto 0);
            result: out std_logic_vector(63 downto 0)
        );
    end component;

begin
    test: unified_padd_psub port map (
        a => a,
        b => b,
        operation => operation,
        result => result
    );

    process
        variable test_count : integer := 0;
        variable pass_count : integer := 0;
    begin
        -- Test 1: Byte addition wraparound
        test_count := test_count + 1;
        operation <= "00000";  
        a <= x"0102030405060708";
        b <= x"0807060504030201";
        wait for 10 ns;
        assert result = x"0909090909090909"
            report "Test 1 Failed";
        if result = x"0909090909090909" then
            pass_count := pass_count + 1;
        end if;

        -- Test 2: Byte subtraction wraparound
        test_count := test_count + 1;
        operation <= "00100"; 
        wait for 10 ns;
        assert result = x"F9FBFDFF01030507"
            report "Test 2 Failed";
        if result = x"F9FBFDFF01030507" then
            pass_count := pass_count + 1;
        end if;

        -- Test 3: Word addition wraparound
        test_count := test_count + 1;
        operation <= "00001";  
        a <= x"0001000200030004";
        b <= x"0004000300020001";
        wait for 10 ns;
        assert result = x"0005000500050005"
            report "Test 3 Failed";
        if result = x"0005000500050005" then
            pass_count := pass_count + 1;
        end if;

        -- Test 4: Byte addition signed saturation
        test_count := test_count + 1;
        operation <= "01000"; 
        a <= x"7F7F7F7F7F7F7F7F";
        b <= x"0101010101010101";
        wait for 10 ns;
        assert result = x"7F7F7F7F7F7F7F7F"
            report "Test 4 Failed";
        if result = x"7F7F7F7F7F7F7F7F" then
            pass_count := pass_count + 1;
        end if;

        -- Test 5: Byte addition signed negative saturation
        test_count := test_count + 1;
        operation <= "01000";  
        a <= x"8080808080808080";
        b <= x"8080808080808080";
        wait for 10 ns;
        assert result = x"8080808080808080"
            report "Test 5 Failed";
        if result = x"8080808080808080" then
            pass_count := pass_count + 1;
        end if;

        -- Test 6: Byte addition unsigned saturation"
        test_count := test_count + 1;
        operation <= "10000"; 
        a <= x"FF01FF03FF05FF07";
        b <= x"0102030405060708";
        wait for 10 ns;
        assert result = x"FF03FF07FF0BFF0F"
            report "Test 6 Failed";
        if result = x"FF03FF07FF0BFF0F" then
            pass_count := pass_count + 1;
        end if;

        -- Test 7: Byte subtraction unsigned saturation
        test_count := test_count + 1;
        operation <= "10100";  
        a <= x"0102030405060708";
        b <= x"0807060504030201";
        wait for 10 ns;
        assert result = x"0000000001030507"
            report "Test 7 Failed";
        if result = x"0000000001030507" then
            pass_count := pass_count + 1;
        end if;

        -- Test 8: Word addition wraparound
        test_count := test_count + 1;
        operation <= "00001";  
        a <= x"FFFF000100020003";
        b <= x"0001FFFF00030004";
        wait for 10 ns;
        assert result = x"0000000000050007"
            report "Test 8 Failed";
        if result = x"0000000000050007" then
            pass_count := pass_count + 1;
        end if;

        -- Test 9: Zero input test
        test_count := test_count + 1;
        operation <= "00000";  
        a <= x"0000000000000000";
        b <= x"0102030405060708";
        wait for 10 ns;
        assert result = x"0102030405060708"
            report "Test 9 Failed";
        if result = x"0102030405060708" then
            pass_count := pass_count + 1;
        end if;

        -- Test 10: Maximum value test
        test_count := test_count + 1;
        operation <= "10000"; 
        a <= x"FFFFFFFFFFFFFFFF";
        b <= x"0101010101010101";
        wait for 10 ns;
        assert result = x"FFFFFFFFFFFFFFFF"
            report "Test 10 Failed";
        if result = x"FFFFFFFFFFFFFFFF" then
            pass_count := pass_count + 1;
        end if;

        report "Passed " & integer'image(pass_count) & " out of " & integer'image(test_count) & " tests.";
        wait;
    end process;
end sim;
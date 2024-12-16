library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity pmul_tb is
end pmul_tb;


architecture sim of pmul_tb is

    signal a, b, result: std_logic_vector(63 downto 0);
    signal op: std_logic;
    
    component pmul is
        Port (
            a, b: in std_logic_vector(63 downto 0);
            op: in std_logic;
            result: out std_logic_vector(63 downto 0)
        );
    end component;

begin
    test: pmul port map (
        a => a,
        b => b,
        op => op,
        result => result
    );

    process
        variable test_count : integer := 0;
        variable pass_count : integer := 0;
    begin
    
        -- Test 1: PMULLW
        test_count := test_count + 1;
        op <= '0';
        a <= x"0202020202020202";  
        b <= x"0303030303030303"; 
        wait for 10 ns;
        assert result = x"0606060606060606"
            report "Test 1 Failed";
        if result = x"0606060606060606" then
            pass_count := pass_count + 1;
        end if;

        -- Test 2: PMULHW
        test_count := test_count + 1;
        op <= '1';
        wait for 10 ns;
        assert result = x"0000000000000000"
            report "Test 2 Failed";
        if result = x"0000000000000000" then
            pass_count := pass_count + 1;
        end if;

        -- Test 3: Max positive * Max positive PMULLW
        test_count := test_count + 1;
        op <= '0';
        a <= x"7F7F7F7F7F7F7F7F";  
        b <= x"7F7F7F7F7F7F7F7F";  
        wait for 10 ns;
        assert result = x"0101010101010101"
            report "Test 3 Failed";
        if result = x"0101010101010101" then
            pass_count := pass_count + 1;
        end if;

        -- Test 4: Max positive * Max positive PMULHW
        test_count := test_count + 1;
        op <= '1';
        wait for 10 ns;
        assert result = x"3F3F3F3F3F3F3F3F"
            report "Test 4 Failed";
        if result = x"3F3F3F3F3F3F3F3F" then
            pass_count := pass_count + 1;
        end if;

        -- Test 5: Negative * Positive PMULLW
        test_count := test_count + 1;
        op <= '0';
        a <= x"8080808080808080";  
        b <= x"0202020202020202";  
        wait for 10 ns;
        assert result = x"0000000000000000"
            report "Test 5 Failed";
        if result = x"0000000000000000" then
            pass_count := pass_count + 1;
        end if;

        -- Test 6: Negative * Positive PMULHW
        test_count := test_count + 1;
        op <= '1';
        wait for 10 ns;
        assert result = x"FFFFFFFFFFFFFFFF"
            report "Test 6 Failed";
        if result = x"FFFFFFFFFFFFFFFF" then
            pass_count := pass_count + 1;
        end if;

        -- Test 7
        test_count := test_count + 1;
        op <= '0';
        a <= x"0000000000000000";
        b <= x"FFFFFFFFFFFFFFFF";
        wait for 10 ns;
        assert result = x"0000000000000000"
            report "Test 7 Failed";
        if result = x"0000000000000000" then
            pass_count := pass_count + 1;
        end if;

        -- Test 8: Negative * Negative PMULLW
        test_count := test_count + 1;
        op <= '0';
        a <= x"8080808080808080";  
        b <= x"8080808080808080";  
        wait for 10 ns;
        assert result = x"0000000000000000"
            report "Test 9 Failed";
        if result = x"0000000000000000" then
            pass_count := pass_count + 1;
        end if;

        -- Test 9: Negative * Negative PMULHW
        test_count := test_count + 1;
        op <= '1';
        wait for 10 ns;
        assert result = x"4040404040404040"
            report "Test 10 Failed";
        if result = x"4040404040404040" then
            pass_count := pass_count + 1;
        end if;

        report "Passed " & integer'image(pass_count) & " out of " & integer'image(test_count) & " tests.";
        wait;
    end process;
end sim;
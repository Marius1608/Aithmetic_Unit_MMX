library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity padd_psub_wraparound_tb is
end padd_psub_wraparound_tb;


architecture sim of padd_psub_wraparound_tb is

    signal a, b, result: std_logic_vector(63 downto 0);
    signal operation: std_logic_vector(2 downto 0);
    
    component padd_psub_wraparound is
        Port (
            a, b: in std_logic_vector(63 downto 0);
            operation: in std_logic_vector(2 downto 0);
            result: out std_logic_vector(63 downto 0)
        );
    end component;

begin
    test: padd_psub_wraparound port map (
        a => a,
        b => b,
        operation => operation,
        result => result
    );

    process
        variable test_count : integer := 0;
        variable pass_count : integer := 0;
    begin
    
        -- Test 1: adunare byte
        test_count := test_count + 1;
        operation <= "000"; 
        a <= x"0102030405060708";
        b <= x"0807060504030201";
        wait for 10 ns;
        assert result = x"0909090909090909"
            report "Test 1 Failed";
        if result = x"0909090909090909" then
            pass_count := pass_count + 1;
        end if;

        -- Test 2: scadere byte
        test_count := test_count + 1;
        operation <= "100";
        wait for 10 ns;
        assert result = x"F9FBFDFF01030507"
            report "Test 2 Failed";
        if result = x"F9FBFDFF01030507" then
            pass_count := pass_count + 1;
        end if;
        

        -- Test 3: adunare word
        test_count := test_count + 1;
        operation <= "001";
        a <= x"0001000200030004";
        b <= x"0004000300020001";
        wait for 10 ns;
        assert result = x"0005000500050005"
            report "Test 3 Failed";
        if result = x"0005000500050005" then
            pass_count := pass_count + 1;
        end if;

        -- Test 4: scadere word
        test_count := test_count + 1;
        operation <= "101";
        wait for 10 ns;
        assert result = x"FFFDFFFF00010003"
            report "Test 4 Failed";
        if result = x"FFFDFFFF00010003" then
            pass_count := pass_count + 1;
        end if;

        -- Test 5: adunare dword
        test_count := test_count + 1;
        operation <= "010";
        a <= x"0000000100000002";
        b <= x"0000000200000001";
        wait for 10 ns;
        assert result = x"0000000300000003"
            report "Test 5 Failed";
        if result = x"0000000300000003" then
            pass_count := pass_count + 1;
        end if;

        -- Test 6: scadere dword
        test_count := test_count + 1;
        operation <= "110";
        wait for 10 ns;
        assert result = x"FFFFFFFF00000001"
            report "Test 6 Failed";
        if result = x"FFFFFFFF00000001" then
            pass_count := pass_count + 1;
        end if;

       -- Test 7: wraparound byte
        test_count := test_count + 1;
        operation <= "000";
        a <= x"FF01FF03FF05FF07";
        b <= x"0102030405060708";
        wait for 10 ns;
        assert result = x"00030207040B060F"
            report "Test 7 Failed";
        if result = x"00030207040B060F" then
            pass_count := pass_count + 1;
        end if;
        

        -- Test 8: wraparound word
        test_count := test_count + 1;
        operation <= "001";
        a <= x"FFFF000100020003";
        b <= x"0001FFFF00030004";
        wait for 10 ns;
        assert result = x"0000000000050007"
            report "Test 8 Failed";
        if result = x"0000000000050007" then
            pass_count := pass_count + 1;
        end if;
        
        -- Test 9
        test_count := test_count + 1;
        operation <= "000";
        a <= x"0000000000000000";
        b <= x"0102030405060708";
        wait for 10 ns;
        assert result = x"0102030405060708"
            report "Test 9 Failed";
        if result = x"0102030405060708" then
            pass_count := pass_count + 1;
        end if;

        -- Test 10
        test_count := test_count + 1;
        operation <= "000";
        a <= x"FFFFFFFFFFFFFFFF";
        b <= x"0101010101010101";
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
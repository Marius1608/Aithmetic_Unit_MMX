library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity paddus_psubus_unsigned_tb is
end paddus_psubus_unsigned_tb;


architecture sim of paddus_psubus_unsigned_tb is
    signal a, b: std_logic_vector(63 downto 0);
    signal operation: std_logic_vector(2 downto 0);
    signal result: std_logic_vector(63 downto 0);
    
    component paddus_psubus_unsigned is
        Port (
            a, b: in std_logic_vector(63 downto 0);
            operation: in std_logic_vector(2 downto 0);
            result: out std_logic_vector(63 downto 0)
        );
    end component;

begin
    
    test: paddus_psubus_unsigned port map (a => a, b => b, operation => operation, result => result);

    process
        variable test_count : integer := 0;
        variable pass_count : integer := 0;
    begin
    
        -- Testul 1: adunare byte fara saturatie
        test_count := test_count + 1;
        operation <= "000";
        a <= x"0102030405060708";
        b <= x"0102030405060708";
        wait for 10 ns;
        assert result = x"020406080A0C0E10"
            report "Test 1 Failed" ;
        if result = x"020406080A0C0E10" then
            pass_count := pass_count + 1;
        end if;

        -- Testul 2: adunare byte cu saturatie
        test_count := test_count + 1;
        operation <= "000";
        a <= x"FF01FF03FF05FF07";
        b <= x"0102030405060708";
        wait for 10 ns;
        assert result = x"FF03FF07FF0BFF0F"
            report "Test 2 Failed";
        if result = x"FF03FF07FF0BFF0F" then
            pass_count := pass_count + 1;
        end if;

        -- Testul 3: scãdere byte fara saturatie
        test_count := test_count + 1;
        operation <= "100";
        a <= x"0807060504030201";
        b <= x"0102030405060708";
        wait for 10 ns;
        assert result = x"0705030100000000"
            report "Test 3 Failed";
        if result = x"0705030100000000" then
            pass_count := pass_count + 1;
        end if;

        -- Testul 4: Scãdere byte cu saturatie
        test_count := test_count + 1;
        operation <= "100";
        a <= x"0102030405060708";
        b <= x"0807060504030201";
        wait for 10 ns;
        assert result = x"0000000001030507"
            report "Test 4 Failed";
        if result = x"0000000001030507" then
            pass_count := pass_count + 1;
        end if;

        -- Testul 5: adunare word fara saturatie
        test_count := test_count + 1;
        operation <= "001";
        a <= x"0001000200030004";
        b <= x"0004000300020001";
        wait for 10 ns;
        assert result = x"0005000500050005"
            report "Test 5 Failed";
        if result = x"0005000500050005" then
            pass_count := pass_count + 1;
        end if;

        -- Testul 6: adunare word cu saturatie
        test_count := test_count + 1;
        operation <= "001";
        a <= x"FFFF000100020003";
        b <= x"0001FFFF00030004";
        wait for 10 ns;
        assert result = x"FFFFFFFF00050007"
            report "Test 6 Failed";
        if result = x"FFFFFFFF00050007" then
            pass_count := pass_count + 1;
        end if;

        -- Testul 7: scãdere word fara saturatie
        test_count := test_count + 1;
        operation <= "101";
        a <= x"0008000700060005";
        b <= x"0001000200030004";
        wait for 10 ns;
        assert result = x"0007000500030001"
            report "Test 7 Failed";
        if result = x"0007000500030001" then
            pass_count := pass_count + 1;
        end if;

        -- Testul 8: scadere word cu saturatie
        test_count := test_count + 1;
        operation <= "101";
        a <= x"0001000200030004";
        b <= x"0004000300020001";
        wait for 10 ns;
        assert result = x"0000000000010003"
            report "Test 8 Failed";
        if result = x"0000000000010003" then
            pass_count := pass_count + 1;
        end if;

        -- Testul 9: val maxima 
        test_count := test_count + 1;
        operation <= "000";
        a <= x"FFFFFFFFFFFFFFFF";
        b <= x"0101010101010101";
        wait for 10 ns;
        assert result = x"FFFFFFFFFFFFFFFF"
            report "Test 9 Failed";
        if result = x"FFFFFFFFFFFFFFFF" then
            pass_count := pass_count + 1;
        end if;

        -- Testul 10: val zero
        test_count := test_count + 1;
        operation <= "100";
        a <= x"0000000000000000";
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
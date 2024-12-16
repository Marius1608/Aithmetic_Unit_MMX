library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity padds_psubs_signed_tb is
end padds_psubs_signed_tb;


architecture sim of padds_psubs_signed_tb is

    signal a, b: std_logic_vector(63 downto 0);
    signal operation: std_logic_vector(2 downto 0);
    signal result: std_logic_vector(63 downto 0);
    
    component padds_psubs_signed is
        Port (
            a, b: in std_logic_vector(63 downto 0);
            operation: in std_logic_vector(2 downto 0);
            result: out std_logic_vector(63 downto 0)
        );
    end component;

begin
    
    test: padds_psubs_signed port map (a => a, b => b, operation => operation, result => result);

    process
        variable test_count : integer := 0;
        variable pass_count : integer := 0;
    begin
        -- Test 1: adunare byte fara saturare 
        test_count := test_count + 1;
        operation <= "000";
        a <= x"0102030405060708";
        b <= x"0102030405060708";
        wait for 10 ns;
        assert result = x"020406080A0C0E10"
            report "Test 1 Failed";
        if result = x"020406080A0C0E10" then
            pass_count := pass_count + 1;
        end if;

        -- Test 2: adunare byte cu saturare pozitiva
        test_count := test_count + 1;
        operation <= "000";
        a <= x"7F7F7F7F7F7F7F7F";
        b <= x"0101010101010101";
        wait for 10 ns;
        assert result = x"7F7F7F7F7F7F7F7F"
            report "Test 2 Failed" ;
        if result = x"7F7F7F7F7F7F7F7F" then
            pass_count := pass_count + 1;
        end if;

        -- Test 3: adunare byte cu saturare negativa
        test_count := test_count + 1;
        operation <= "000";
        a <= x"8080808080808080";
        b <= x"8080808080808080";
        wait for 10 ns;
        assert result = x"8080808080808080"
            report "Test 3 Failed";
        if result = x"8080808080808080" then
            pass_count := pass_count + 1;
        end if;

        -- Test 4: adunare byte fara saturare 
        test_count := test_count + 1;
        operation <= "100";
        a <= x"0807060504030201";
        b <= x"0102030405060708";
        wait for 10 ns;
        assert result = x"07050301FFFDFBF9"
            report "Test 4 Failed";
        if result = x"07050301FFFCFAF9" then
            pass_count := pass_count + 1;
        end if;

        -- Test 5: adunare word fara saturare 
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
  
        -- Test 6: adunare word cu saturare pozitiva
        test_count := test_count + 1;
        operation <= "001";
        a <= x"7FFF7FFF7FFF7FFF";
        b <= x"0001000100010001";
        wait for 10 ns;
        assert result = x"7FFF7FFF7FFF7FFF"
            report "Test 6 Failed";
        if result = x"7FFF7FFF7FFF7FFF" then
            pass_count := pass_count + 1;
        end if;

        -- Test 7: adunare word cu saturare negativa
        test_count := test_count + 1;
        operation <= "001";
        a <= x"8000800080008000";
        b <= x"8000800080008000";
        wait for 10 ns;
        assert result = x"8000800080008000"
            report "Test 7 Failed";
        if result = x"8000800080008000" then
            pass_count := pass_count + 1;
        end if;
 
        -- Test 8: scadere word cu saturare pozitiva 
        test_count := test_count + 1;
        operation <= "101";
        a <= x"7FFF7FFF7FFF7FFF";
        b <= x"8000800080008000";
        wait for 10 ns;
        assert result = x"7FFF7FFF7FFF7FFF"
            report "Test 8 Failed";
        if result = x"7FFF7FFF7FFF7FFF" then
            pass_count := pass_count + 1;
        end if;

         report "Passed " & integer'image(pass_count) & " out of " & integer'image(test_count) & " tests.";
        
        wait;
    end process;
end sim;
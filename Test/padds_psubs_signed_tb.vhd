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
    UUT: padds_psubs_signed port map (a => a, b => b, operation => operation, result => result);

    process
        variable test_count : integer := 0;
        variable pass_count : integer := 0;
    begin
        -- Test 1: Byte addition without saturation
        test_count := test_count + 1;
        operation <= "000";
        a <= x"0102030405060708";
        b <= x"0102030405060708";
        wait for 10 ns;
        assert result = x"020406080A080E10"
            report "Test 1 Failed: Basic byte addition" severity error;
        if result = x"0204060808080E10" then
            pass_count := pass_count + 1;
        end if;

        -- Test 2: Byte addition with positive saturation
        test_count := test_count + 1;
        operation <= "000";
        a <= x"7F7F7F7F7F7F7F7F";
        b <= x"0101010101010101";
        wait for 10 ns;
        assert result = x"7F7F7F7F7F7F7F7F"
            report "Test 2 Failed: Byte addition positive saturation" severity error;
        if result = x"7F7F7F7F7F7F7F7F" then
            pass_count := pass_count + 1;
        end if;

        -- Test 3: Byte addition with negative saturation
        test_count := test_count + 1;
        operation <= "000";
        a <= x"8080808080808080";
        b <= x"8080808080808080";
        wait for 10 ns;
        assert result = x"8080808080808080"
            report "Test 3 Failed: Byte addition negative saturation" severity error;
        if result = x"8080808080808080" then
            pass_count := pass_count + 1;
        end if;

        -- Test 4: Byte subtraction without saturation
        test_count := test_count + 1;
        operation <= "100";
        a <= x"0807060504030201";
        b <= x"0102030405060708";
        wait for 10 ns;
        assert result = x"0705030100FDFBF9"
            report "Test 4 Failed: Basic byte subtraction" severity error;
        if result = x"0705030100FCFAF9" then
            pass_count := pass_count + 1;
        end if;

        -- Test 5: Word addition without saturation
        test_count := test_count + 1;
        operation <= "001";
        a <= x"0001000200030004";
        b <= x"0004000300020001";
        wait for 10 ns;
        assert result = x"0005000500050005"
            report "Test 5 Failed: Word addition" severity error;
        if result = x"0005000500050005" then
            pass_count := pass_count + 1;
        end if;

        -- Test 6: Word addition with positive saturation
        test_count := test_count + 1;
        operation <= "001";
        a <= x"7FFF7FFF7FFF7FFF";
        b <= x"0001000100010001";
        wait for 10 ns;
        assert result = x"7FFF7FFF7FFF7FFF"
            report "Test 6 Failed: Word addition positive saturation" severity error;
        if result = x"7FFF7FFF7FFF7FFF" then
            pass_count := pass_count + 1;
        end if;

        -- Test 7: Word addition with negative saturation
        test_count := test_count + 1;
        operation <= "001";
        a <= x"8000800080008000";
        b <= x"8000800080008000";
        wait for 10 ns;
        assert result = x"8000800080008000"
            report "Test 7 Failed: Word addition negative saturation" severity error;
        if result = x"8000800080008000" then
            pass_count := pass_count + 1;
        end if;

        -- Test 8: Word subtraction with positive saturation
        test_count := test_count + 1;
        operation <= "101";
        a <= x"7FFF7FFF7FFF7FFF";
        b <= x"8000800080008000";
        wait for 10 ns;
        assert result = x"7FFF7FFF7FFF7FFF"
            report "Test 8 Failed: Word subtraction positive saturation" severity error;
        if result = x"7FFF7FFF7FFF7FFF" then
            pass_count := pass_count + 1;
        end if;

        -- Test 9: Mixed signs byte addition
        test_count := test_count + 1;
        operation <= "000";
        a <= x"807F807F807F807F";
        b <= x"7F807F807F807F80";
        wait for 10 ns;
        assert result = x"FFFFFFfFFFFFFFFF"
            report "Test 9 Failed: Mixed signs byte addition" severity error;
        if result = x"FF7FFF7FFF7FFF7F" then
            pass_count := pass_count + 1;
        end if;

        -- Test 10: Mixed signs word subtraction
        test_count := test_count + 1;
        operation <= "101";
        a <= x"7FFF80007FFF8000";
        b <= x"80007FFF80007FFF";
        wait for 10 ns;
        assert result = x"7FFF80007FFF8000"
            report "Test 10 Failed: Mixed signs word subtraction" severity error;
        if result = x"7FFF80007FFF8000" then
            pass_count := pass_count + 1;
        end if;

       
        wait;
    end process;
end sim;
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
    UUT: paddus_psubus_unsigned port map (a => a, b => b, operation => operation, result => result);

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
        assert result = x"0204060808080E10"
            report "Test 1 Failed: Basic byte addition" severity error;
        if result = x"0204060808080E10" then
            pass_count := pass_count + 1;
        end if;

        -- Test 2: Byte addition with saturation
        test_count := test_count + 1;
        operation <= "000";
        a <= x"FF01FF03FF05FF07";
        b <= x"0102030405060708";
        wait for 10 ns;
        assert result = x"FF03FF07FF0BFF0F"
            report "Test 2 Failed: Byte addition with saturation" severity error;
        if result = x"FF03FF07FF0BFF0F" then
            pass_count := pass_count + 1;
        end if;

        -- Test 3: Byte subtraction without saturation
        test_count := test_count + 1;
        operation <= "100";
        a <= x"0807060504030201";
        b <= x"0102030405060708";
        wait for 10 ns;
        assert result = x"0705030100000000"
            report "Test 3 Failed: Byte subtraction" severity error;
        if result = x"0705030100000000" then
            pass_count := pass_count + 1;
        end if;

        -- Test 4: Byte subtraction with saturation
        test_count := test_count + 1;
        operation <= "100";
        a <= x"0102030405060708";
        b <= x"0807060504030201";
        wait for 10 ns;
        assert result = x"0000000000030507"
            report "Test 4 Failed: Byte subtraction with saturation" severity error;
        if result = x"0000000000030507" then
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

        -- Test 6: Word addition with saturation
        test_count := test_count + 1;
        operation <= "001";
        a <= x"FFFF000100020003";
        b <= x"0001FFFF00030004";
        wait for 10 ns;
        assert result = x"FFFFFFFFFFFF0007"
            report "Test 6 Failed: Word addition with saturation" severity error;
        if result = x"FFFFFFFFFFFF0007" then
            pass_count := pass_count + 1;
        end if;

        -- Test 7: Word subtraction without saturation
        test_count := test_count + 1;
        operation <= "101";
        a <= x"0008000700060005";
        b <= x"0001000200030004";
        wait for 10 ns;
        assert result = x"0007000500030001"
            report "Test 7 Failed: Word subtraction" severity error;
        if result = x"0007000500030001" then
            pass_count := pass_count + 1;
        end if;

        -- Test 8: Word subtraction with saturation
        test_count := test_count + 1;
        operation <= "101";
        a <= x"0001000200030004";
        b <= x"0004000300020001";
        wait for 10 ns;
        assert result = x"0000000000010003"
            report "Test 8 Failed: Word subtraction with saturation" severity error;
        if result = x"0000000000010003" then
            pass_count := pass_count + 1;
        end if;

        -- Test 9: Maximum value test
        test_count := test_count + 1;
        operation <= "000";
        a <= x"FFFFFFFFFFFFFFFF";
        b <= x"0101010101010101";
        wait for 10 ns;
        assert result = x"FFFFFFFFFFFFFFFF"
            report "Test 9 Failed: Maximum value test" severity error;
        if result = x"FFFFFFFFFFFFFFFF" then
            pass_count := pass_count + 1;
        end if;

        -- Test 10: Zero value test
        test_count := test_count + 1;
        operation <= "100";
        a <= x"0000000000000000";
        b <= x"0101010101010101";
        wait for 10 ns;
        assert result = x"0000000000000000"
            report "Test 10 Failed: Zero value test" severity error;
        if result = x"0000000000000000" then
            pass_count := pass_count + 1;
        end if;

        
        wait;
    end process;
end sim;
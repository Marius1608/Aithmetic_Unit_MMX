library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity parallel_logical_tb is
end parallel_logical_tb;

architecture sim of parallel_logical_tb is
    signal a, b: std_logic_vector(63 downto 0);
    signal operation: std_logic_vector(2 downto 0);
    signal result: std_logic_vector(63 downto 0);
    
    component parallel_logical is
        Port (
            a, b: in std_logic_vector(63 downto 0);
            operation: in std_logic_vector(2 downto 0);
            result: out std_logic_vector(63 downto 0)
        );
    end component;

begin
    UUT: parallel_logical port map (a => a, b => b, operation => operation, result => result);

    process
        variable test_count : integer := 0;
        variable pass_count : integer := 0;
    begin
        -- Test 1: Byte AND
        test_count := test_count + 1;
        operation <= "000";
        a <= x"FF00FF00FF00FF00";
        b <= x"0F0F0F0F0F0F0F0F";
        wait for 10 ns;
        assert result = x"0F000F000F000F00"
            report "Test 1 Failed: Byte AND" severity error;
        if result = x"0F000F000F000F00" then
            pass_count := pass_count + 1;
        end if;

        -- Test 2: Byte OR
        test_count := test_count + 1;
        operation <= "100";
        a <= x"F0F0F0F0F0F0F0F0";
        b <= x"0F0F0F0F0F0F0F0F";
        wait for 10 ns;
        assert result = x"FFFFFFFFFFFFFFFF"
            report "Test 2 Failed: Byte OR" severity error;
        if result = x"FFFFFFFFFFFFFFFF" then
            pass_count := pass_count + 1;
        end if;

        -- Test 3: Byte XOR
        test_count := test_count + 1;
        operation <= "010";
        a <= x"AAAAAAAAAAAAAAAA";
        b <= x"5555555555555555";
        wait for 10 ns;
        assert result = x"FFFFFFFFFFFFFFFF"
            report "Test 3 Failed: Byte XOR" severity error;
        if result = x"FFFFFFFFFFFFFFFF" then
            pass_count := pass_count + 1;
        end if;

        -- Test 4: Word AND
        test_count := test_count + 1;
        operation <= "001";
        a <= x"FFFF0000FFFF0000";
        b <= x"0F0F0F0F0F0F0F0F";
        wait for 10 ns;
        assert result = x"0F0F00000F0F0000"
            report "Test 4 Failed: Word AND" severity error;
        if result = x"0F0F00000F0F0000" then
            pass_count := pass_count + 1;
        end if;

        -- Test 5: Word OR
        test_count := test_count + 1;
        operation <= "101";
        a <= x"F0F00000F0F00000";
        b <= x"0F0F0F0F0F0F0F0F";
        wait for 10 ns;
        assert result = x"FFFF0F0FFFFF0F0F"
            report "Test 5 Failed: Word OR" severity error;
        if result = x"FFFF0F0FFFFF0F0F" then
            pass_count := pass_count + 1;
        end if;

        -- Test 6: Word XOR
        test_count := test_count + 1;
        operation <= "011";
        a <= x"AAAA0000AAAA0000";
        b <= x"5555555555555555";
        wait for 10 ns;
        assert result = x"FFFF5555FFFF5555"
            report "Test 6 Failed: Word XOR" severity error;
        if result = x"FFFF5555FFFF5555" then
            pass_count := pass_count + 1;
        end if;

        -- Test 7: DWord AND
        test_count := test_count + 1;
        operation <= "010";
        a <= x"FFFFFFFF00000000";
        b <= x"0F0F0F0F0F0F0F0F";
        wait for 10 ns;
        assert result = x"0F0F0F0F00000000"
            report "Test 7 Failed: DWord AND" severity error;
        if result = x"0F0F0F0F00000000" then
            pass_count := pass_count + 1;
        end if;

        -- Test 8: DWord OR
        test_count := test_count + 1;
        operation <= "110";
        a <= x"F0F0F0F000000000";
        b <= x"0F0F0F0F0F0F0F0F";
        wait for 10 ns;
        assert result = x"FFFFFFFF0F0F0F0F"
            report "Test 8 Failed: DWord OR" severity error;
        if result = x"FFFFFFFF0F0F0F0F" then
            pass_count := pass_count + 1;
        end if;

        -- Test 9: DWord XOR
        test_count := test_count + 1;
        operation <= "010";
        a <= x"AAAAAAAAAAAAAAAA";
        b <= x"5555555555555555";
        wait for 10 ns;
        assert result = x"FFFFFFFFFFFFFFFF"
            report "Test 9 Failed: DWord XOR" severity error;
        if result = x"FFFFFFFFFFFFFFFF" then
            pass_count := pass_count + 1;
        end if;

        -- Test 10: Invalid operation
        test_count := test_count + 1;
        operation <= "111";
        a <= x"FFFFFFFFFFFFFFFF";
        b <= x"FFFFFFFFFFFFFFFF";
        wait for 10 ns;
        assert result = x"0000000000000000"
            report "Test 10 Failed: Invalid operation" severity error;
        if result = x"0000000000000000" then
            pass_count := pass_count + 1;
        end if;

        
        wait;
    end process;
end sim;
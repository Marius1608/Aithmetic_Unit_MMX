library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity mmx_unit_tb is
end mmx_unit_tb;


architecture sim of mmx_unit_tb is
    signal a, b, result: std_logic_vector(63 downto 0);
    signal opcode: std_logic_vector(6 downto 0);
    
    component mmx_unit is
        Port (
            a, b     : in  std_logic_vector(63 downto 0);
            opcode   : in  std_logic_vector(6 downto 0);
            result   : out std_logic_vector(63 downto 0)
        );
    end component;

begin
    test: mmx_unit port map (
        a => a,
        b => b,
        opcode => opcode,
        result => result
    );

    process
        variable test_count : integer := 0;
        variable pass_count : integer := 0;
    begin
        
        -- Test 1: Byte addition (wraparound)
        test_count := test_count + 1;
        opcode <= "0000000"; 
        a <= x"0102030405060708";
        b <= x"0807060504030201";
        wait for 10 ns;
        assert result = x"0909090909090909"
            report "Test 1 Failed";
        if result = x"0909090909090909" then
            pass_count := pass_count + 1;
        end if;

        -- Test 2: Word addition (wraparound)
        test_count := test_count + 1;
        opcode <= "0000001"; 
        a <= x"0001000200030004";
        b <= x"0004000300020001";
        wait for 10 ns;
        assert result = x"0005000500050005"
            report "Test 2 Failed";
        if result = x"0005000500050005" then
            pass_count := pass_count + 1;
        end if;

        -- Test 3: Byte subtraction (signed saturation)
        test_count := test_count + 1;
        opcode <= "0001100";  
        a <= x"7F7F7F7F7F7F7F7F";
        b <= x"8080808080808080";
        wait for 10 ns;
        assert result = x"7F7F7F7F7F7F7F7F"
            report "Test 3 Failed";
        if result = x"7F7F7F7F7F7F7F7F" then
            pass_count := pass_count + 1;
        end if;

        -- Test 4: Word addition (unsigned saturation)
        test_count := test_count + 1;
        opcode <= "0010001";  
        a <= x"FFFF000100020003";
        b <= x"0001FFFF00030004";
        wait for 10 ns;
        assert result = x"FFFFFFFF00050007"
            report "Test 4 Failed";
        if result = x"FFFFFFFF00050007" then
            pass_count := pass_count + 1;
        end if;

        -- Test 5: Byte AND
        test_count := test_count + 1;
        opcode <= "0100000";  
        a <= x"FF00FF00FF00FF00";
        b <= x"0F0F0F0F0F0F0F0F";
        wait for 10 ns;
        assert result = x"0F000F000F000F00"
            report "Test 5 Failed";
        if result = x"0F000F000F000F00" then
            pass_count := pass_count + 1;
        end if;

        -- Test 6: Word OR
        test_count := test_count + 1;
        opcode <= "0101001";  
        a <= x"F0F00000F0F00000";
        b <= x"0F0F0F0F0F0F0F0F";
        wait for 10 ns;
        assert result = x"FFFF0F0FFFFF0F0F"
            report "Test 6 Failed";
        if result = x"FFFF0F0FFFFF0F0F" then
            pass_count := pass_count + 1;
        end if;

        -- Test 7: DWord XOR
        test_count := test_count + 1;
        opcode <= "0100110";  
        a <= x"AAAAAAAAAAAAAAAA";
        b <= x"5555555555555555";
        wait for 10 ns;
        assert result = x"FFFFFFFFFFFFFFFF"
            report "Test 7 Failed";
        if result = x"FFFFFFFFFFFFFFFF" then
            pass_count := pass_count + 1;
        end if;

        -- Test 8: Byte equality 
        test_count := test_count + 1;
        opcode <= "1000000";  
        a <= x"1122334455667788";
        b <= x"1122334455667788";
        wait for 10 ns;
        assert result = x"FFFFFFFFFFFFFFFF"
            report "Test 8 Failed";
        if result = x"FFFFFFFFFFFFFFFF" then
            pass_count := pass_count + 1;
        end if;

        -- Test 9: Word equality (some equal)
        test_count := test_count + 1;
        opcode <= "1000001";  
        a <= x"1122334455667788";
        b <= x"1122334455667799";
        wait for 10 ns;
        assert result = x"FFFFFFFFFFFF0000"
            report "Test 9 Failed";
        if result = x"FFFFFFFFFFFF0000" then
            pass_count := pass_count + 1;
        end if;

        -- Test 10: PMULLW (positive * positive)
        test_count := test_count + 1;
        opcode <= "1100000"; 
        a <= x"0202020202020202";
        b <= x"0303030303030303";
        wait for 10 ns;
        assert result = x"0606060606060606"
            report "Test 10 Failed";
        if result = x"0606060606060606" then
            pass_count := pass_count + 1;
        end if;

        -- Test 11: PMULLW (negative * positive)
        test_count := test_count + 1;
        opcode <= "1100000";  
        a <= x"8080808080808080";
        b <= x"0202020202020202";
        wait for 10 ns;
        assert result = x"0000000000000000"
            report "Test 11 Failed";
        if result = x"0000000000000000" then
            pass_count := pass_count + 1;
        end if;

        -- Test 12: Zero operands test
        test_count := test_count + 1;
        opcode <= "0000000";  
        a <= x"0000000000000000";
        b <= x"0000000000000000";
        wait for 10 ns;
        assert result = x"0000000000000000"
            report "Test 12 Failed";
        if result = x"0000000000000000" then
            pass_count := pass_count + 1;
        end if;

        -- Test 13: Invalid operation code
        test_count := test_count + 1;
        opcode <= "1111111";  
        a <= x"FFFFFFFFFFFFFFFF";
        b <= x"FFFFFFFFFFFFFFFF";
        wait for 10 ns;
        assert result = x"0000000000000000"
            report "Test 13 Failed";
        if result = x"0000000000000000" then
            pass_count := pass_count + 1;
        end if;
        
        -- Test 14: Word subtraction (unsigned saturation, test underflow)
        test_count := test_count + 1;
        opcode <= "0010101"; 
        a <= x"0001000200030004";
        b <= x"0002000300040005";
        wait for 10 ns;
        assert result = x"0000000000000000"
            report "Test 14 Failed";
        if result = x"0000000000000000" then
            pass_count := pass_count + 1;
        end if;
       
        -- Test 15: DWord equality compare
        test_count := test_count + 1;
        opcode <= "1000010";  
        a <= x"1234567812345678";
        b <= x"1234567812345678";
        wait for 10 ns;
        assert result = x"FFFFFFFFFFFFFFFF"
            report "Test 15 Failed";
        if result = x"FFFFFFFFFFFFFFFF" then
            pass_count := pass_count + 1;
        end if;
        
        -- Test 16: PMULHW (signed high word multiplication)
        test_count := test_count + 1;
        opcode <= "1100001";  -- 
        a <= x"4000400040004000";  
        b <= x"4000400040004000";  
        wait for 10 ns;
        assert result = x"1000100010001000"  
            report "Test 16 Failed";
        if result = x"1000100010001000" then
            pass_count := pass_count + 1;
        end if;
        

        report "Passed " & integer'image(pass_count) & " out of " & integer'image(test_count) & " tests.";
        wait;
    end process;
end sim;
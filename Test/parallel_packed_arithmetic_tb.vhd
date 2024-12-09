library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity parallel_packed_arithmetic_tb is
end parallel_packed_arithmetic_tb;

architecture Behavioral of parallel_packed_arithmetic_tb is
    signal a, b : std_logic_vector(63 downto 0);
    signal operation : std_logic_vector(4 downto 0);
    signal result : std_logic_vector(63 downto 0);
    
    component parallel_packed_arithmetic is
        Port (
            a, b : in std_logic_vector(63 downto 0);
            operation : in std_logic_vector(4 downto 0);
            result : out std_logic_vector(63 downto 0)
        );
    end component;

begin
    test: parallel_packed_arithmetic port map (
        a => a,
        b => b,
        operation => operation,
        result => result
    );

    process
        variable test_count : integer := 0;
        variable pass_count : integer := 0;
    begin
        -- Test 1: Byte addition normal (wraparound)
        test_count := test_count + 1;
        a <= x"FF02FF02FF02FF02";
        b <= x"0101010101010101";
        operation <= "00000"; -- Normal byte addition
        wait for 10 ns;
        assert result = x"0003000300030003"
            report "Test 1 Failed: Byte addition wraparound"
            severity error;
        if result = x"0003000300030003" then
            pass_count := pass_count + 1;
        end if;

        -- Test 2: Byte addition with saturation
        test_count := test_count + 1;
        a <= x"FF02FF02FF02FF02";
        b <= x"0101010101010101";
        operation <= "01000"; -- Saturated byte addition
        wait for 10 ns;
        assert result = x"FF03FF03FF03FF03"
            report "Test 2 Failed: Byte addition saturation"
            severity error;
        if result = x"FF03FF03FF03FF03" then
            pass_count := pass_count + 1;
        end if;

        -- Test 3: Byte subtraction normal
        test_count := test_count + 1;
        a <= x"0303030303030303";
        b <= x"0101010101010101";
        operation <= "00100"; -- Normal byte subtraction
        wait for 10 ns;
        assert result = x"0202020202020202"
            report "Test 3 Failed: Byte subtraction normal"
            severity error;
        if result = x"0202020202020202" then
            pass_count := pass_count + 1;
        end if;

        -- Test 4: Byte subtraction with saturation
        test_count := test_count + 1;
        a <= x"0001000100010001";
        b <= x"0202020202020202";
        operation <= "01100"; -- Saturated byte subtraction
        wait for 10 ns;
        assert result = x"0000000000000000"
            report "Test 4 Failed: Byte subtraction saturation"
            severity error;
        if result = x"0000000000000000" then
            pass_count := pass_count + 1;
        end if;

        -- Test 5: Word addition normal
        test_count := test_count + 1;
        a <= x"FFFF0002FFFF0002";
        b <= x"0000000300000003";
        operation <= "00001"; -- Normal word addition
        wait for 10 ns;
        assert result = x"FFFF0005FFFF0005"
            report "Test 5 Failed: Word addition normal"
            severity error;
        if result = x"FFFF0005FFFF0005" then
            pass_count := pass_count + 1;
        end if;

        -- Test 6: Word addition with saturation
        test_count := test_count + 1;
        a <= x"FFFF0002FFFF0002";
        b <= x"0000000300000003";
        operation <= "01001"; -- Saturated word addition
        wait for 10 ns;
        assert result = x"FFFF0005FFFF0005"
            report "Test 6 Failed: Word addition saturation"
            severity error;
        if result = x"FFFF0005FFFF0005" then
            pass_count := pass_count + 1;
        end if;

        -- Test 7: Word subtraction normal
        test_count := test_count + 1;
        a <= x"0005000500050005";
        b <= x"0002000200020002";
        operation <= "00101"; -- Normal word subtraction
        wait for 10 ns;
        assert result = x"0003000300030003"
            report "Test 7 Failed: Word subtraction normal"
            severity error;
        if result = x"0003000300030003" then
            pass_count := pass_count + 1;
        end if;

        -- Test 8: Word subtraction with saturation
        test_count := test_count + 1;
        a <= x"0001000100010001";
        b <= x"0002000200020002";
        operation <= "01101"; -- Saturated word subtraction
        wait for 10 ns;
        assert result = x"0000000000000000"
            report "Test 8 Failed: Word subtraction saturation"
            severity error;
        if result = x"0000000000000000" then
            pass_count := pass_count + 1;
        end if;

        -- Test 9: DWord addition normal
        test_count := test_count + 1;
        a <= x"FFFFFFFF00000002";
        b <= x"0000000100000003";
        operation <= "00010"; -- Normal dword addition
        wait for 10 ns;
        assert result = x"0000000000000005"
            report "Test 9 Failed: DWord addition normal"
            severity error;
        if result = x"0000000000000005" then
            pass_count := pass_count + 1;
        end if;

        -- Test 10: DWord addition with saturation
        test_count := test_count + 1;
        a <= x"FFFFFFFF00000002";
        b <= x"0000000100000003";
        operation <= "01010"; -- Saturated dword addition
        wait for 10 ns;
        assert result = x"FFFFFFFF00000005"
            report "Test 10 Failed: DWord addition saturation"
            severity error;
        if result = x"FFFFFFFF00000005" then
            pass_count := pass_count + 1;
        end if;

        -- Test 11: Maximum byte value tests
        test_count := test_count + 1;
        a <= x"FFFFFFFFFFFFFFFF";
        b <= x"0101010101010101";
        operation <= "01000"; -- Saturated byte addition
        wait for 10 ns;
        assert result = x"FFFFFFFFFFFFFFFF"
            report "Test 11 Failed: Maximum byte value"
            severity error;
        if result = x"FFFFFFFFFFFFFFFF" then
            pass_count := pass_count + 1;
        end if;

        -- Test 12: Zero value tests
        test_count := test_count + 1;
        a <= x"0000000000000000";
        b <= x"0101010101010101";
        operation <= "01100"; -- Saturated byte subtraction
        wait for 10 ns;
        assert result = x"0000000000000000"
            report "Test 12 Failed: Zero value"
            severity error;
        if result = x"0000000000000000" then
            pass_count := pass_count + 1;
        end if;

        -- Test 13: Alternating patterns word
        test_count := test_count + 1;
        a <= x"AAAA5555AAAA5555";
        b <= x"5555AAAA5555AAAA";
        operation <= "00001"; -- Normal word addition
        wait for 10 ns;
        assert result = x"FFFFFFFFFFFFFFFF"
            report "Test 13 Failed: Alternating patterns"
            severity error;
        if result = x"FFFFFFFFFFFFFFFF" then
            pass_count := pass_count + 1;
        end if;

        -- Test 14: DWord boundary test
        test_count := test_count + 1;
        a <= x"FFFFFFFF80000000";
        b <= x"0000000100000001";
        operation <= "00010"; -- Normal dword addition
        wait for 10 ns;
        assert result = x"0000000080000001"
            report "Test 14 Failed: DWord boundary"
            severity error;
        if result = x"0000000080000001" then
            pass_count := pass_count + 1;
        end if;

        -- Test 15: Mixed values byte operation
        test_count := test_count + 1;
        a <= x"0102030405060708";
        b <= x"0807060504030201";
        operation <= "01000"; -- Saturated byte addition
        wait for 10 ns;
        assert result = x"0909090909090909"
            report "Test 15 Failed: Mixed values byte"
            severity error;
        if result = x"0909090909090909" then
            pass_count := pass_count + 1;
        end if;

        -- Test 16: Sequential word values
        test_count := test_count + 1;
        a <= x"0001000200030004";
        b <= x"0004000300020001";
        operation <= "00001"; -- Normal word addition
        wait for 10 ns;
        assert result = x"0005000500050005"
            report "Test 16 Failed: Sequential word values"
            severity error;
        if result = x"0005000500050005" then
            pass_count := pass_count + 1;
        end if;

        -- Test 17: Edge case for byte saturation
        test_count := test_count + 1;
        a <= x"FEFEFEFEFEFEFEFE";
        b <= x"0202020202020202";
        operation <= "01000"; -- Saturated byte addition
        wait for 10 ns;
        assert result = x"FFFFFFFFFFFFFFFF"
            report "Test 17 Failed: Edge case byte saturation"
            severity error;
        if result = x"FFFFFFFFFFFFFFFF" then
            pass_count := pass_count + 1;
        end if;

        -- Test 18: Multiple overflow word test
        test_count := test_count + 1;
        a <= x"FFFF8000FFFF8000";
        b <= x"80007FFF80007FFF";
        operation <= "01001"; -- Saturated word addition
        wait for 10 ns;
        assert result = x"FFFFFFFFFFFFFFFF"
            report "Test 18 Failed: Multiple overflow word"
            severity error;
        if result = x"FFFFFFFFFFFFFFFF" then
            pass_count := pass_count + 1;
        end if;

        -- Test 19: Zero difference test
        test_count := test_count + 1;
        a <= x"1111111111111111";
        b <= x"1111111111111111";
        operation <= "00101"; -- Normal word subtraction
        wait for 10 ns;
        assert result = x"0000000000000000"
            report "Test 19 Failed: Zero difference"
            severity error;
        if result = x"0000000000000000" then
            pass_count := pass_count + 1;
        end if;

        -- Test 21: Byte boundary test
        test_count := test_count + 1;
        a <= x"7F7F7F7F7F7F7F7F";
        b <= x"8181818181818181";
        operation <= "01000"; -- Saturated byte addition
        wait for 10 ns;
        assert result = x"FFFFFFFFFFFFFFFF"
            report "Test 21 Failed: Byte boundary"
            severity error;
        if result = x"FFFFFFFFFFFFFFFF" then
            pass_count := pass_count + 1;
        end if;

        -- Test 22: Word boundary saturation
        test_count := test_count + 1;
        a <= x"7FFF7FFF7FFF7FFF";
        b <= x"0001000100010001";
        operation <= "01001"; -- Saturated word addition
        wait for 10 ns;
        assert result = x"FFFFFFFFFFFFFFFF"
            report "Test 22 Failed: Word boundary saturation"
            severity error;
        if result = x"FFFFFFFFFFFFFFFF" then
            pass_count := pass_count + 1;
        end if;

        -- Test 23: Dword underflow test
        test_count := test_count + 1;
        a <= x"0000000100000001";
        b <= x"0000000200000002";
        operation <= "01110"; -- Saturated dword subtraction
        wait for 10 ns;
        assert result = x"0000000000000000"
            report "Test 23 Failed: Dword underflow"
            severity error;
        if result = x"0000000000000000" then
            pass_count := pass_count + 1;
        end if;

        -- Test 24: Mixed operations test
        test_count := test_count + 1;
        a <= x"FF00FF00FF00FF00";
        b <= x"00FF00FF00FF00FF";
        operation <= "01000"; -- Saturated byte addition
        wait for 10 ns;
        assert result = x"FFFFFFFFFFFFFFFF"
            report "Test 24 Failed: Mixed operations"
            severity error;
        if result = x"FFFFFFFFFFFFFFFF" then
            pass_count := pass_count + 1;
        end if;

        -- Test 25: Edge case test
        test_count := test_count + 1;
        a <= x"FFFFFFFFFFFFFFFE";
        b <= x"0000000000000001";
        operation <= "01010"; -- Saturated dword addition
        wait for 10 ns;
        assert result = x"FFFFFFFFFFFFFFFF"
            report "Test 25 Failed: Edge case"
            severity error;
        if result = x"FFFFFFFFFFFFFFFF" then
            pass_count := pass_count + 1;
        end if;
        
        -- Test 26: Sequential word boundary cases
        test_count := test_count + 1;
        a <= x"7FFE7FFE7FFE7FFE";
        b <= x"0002000200020002";
        operation <= "01001"; -- Saturated word addition
        wait for 10 ns;
        assert result = x"FFFFFFFFFFFFFFFF"
            report "Test 26 Failed: Sequential word boundary"
            severity error;
        if result = x"FFFFFFFFFFFFFFFF" then
            pass_count := pass_count + 1;
        end if;

        -- Test 27: Alternating word patterns with saturation
        test_count := test_count + 1;
        a <= x"FFFE0001FFFE0001";
        b <= x"0002FFFE0002FFFE";
        operation <= "01001"; -- Saturated word addition
        wait for 10 ns;
        assert result = x"FFFFFFFFFFFFFFFFFF"
            report "Test 27 Failed: Alternating word patterns"
            severity error;
        if result = x"FFFFFFFFFFFFFFFFFF" then
            pass_count := pass_count + 1;
        end if;

        -- Test 28: Near boundary byte subtraction
        test_count := test_count + 1;
        a <= x"0100010001000100";
        b <= x"0101010101010101";
        operation <= "01100"; -- Saturated byte subtraction
        wait for 10 ns;
        assert result = x"0000000000000000"
            report "Test 28 Failed: Near boundary byte subtraction"
            severity error;
        if result = x"0000000000000000" then
            pass_count := pass_count + 1;
        end if;

        -- Test 29: Mixed pattern dword operations
        test_count := test_count + 1;
        a <= x"FFFFFF00FFFFFF00";
        b <= x"000000FF000000FF";
        operation <= "01010"; -- Saturated dword addition
        wait for 10 ns;
        assert result = x"FFFFFFFFFFFFFFFF"
            report "Test 29 Failed: Mixed pattern dword"
            severity error;
        if result = x"FFFFFFFFFFFFFFFF" then
            pass_count := pass_count + 1;
        end if;

        -- Test 30: Cascading byte overflow
        test_count := test_count + 1;
        a <= x"FEFEFEFEFEFEFEFC";
        b <= x"0202020202020204";
        operation <= "01000"; -- Saturated byte addition
        wait for 10 ns;
        assert result = x"FFFFFFFFFFFFFFFF"
            report "Test 30 Failed: Cascading byte overflow"
            severity error;
        if result = x"FFFFFFFFFFFFFFFF" then
            pass_count := pass_count + 1;
        end if;

        -- Test 31: Word subtraction near zero
        test_count := test_count + 1;
        a <= x"0000000100000001";
        b <= x"0000000200000002";
        operation <= "01101"; -- Saturated word subtraction
        wait for 10 ns;
        assert result = x"0000000000000000"
            report "Test 31 Failed: Word subtraction near zero"
            severity error;
        if result = x"0000000000000000" then
            pass_count := pass_count + 1;
        end if;

        -- Test 32: Alternating byte patterns
        test_count := test_count + 1;
        a <= x"F0F0F0F0F0F0F0F0";
        b <= x"0F0F0F0F0F0F0F0F";
        operation <= "01000"; -- Saturated byte addition
        wait for 10 ns;
        assert result = x"FFFFFFFFFFFFFFFF"
            report "Test 32 Failed: Alternating byte patterns"
            severity error;
        if result = x"FFFFFFFFFFFFFFFF" then
            pass_count := pass_count + 1;
        end if;

        -- Test 33: DWord mixed operations
        test_count := test_count + 1;
        a <= x"7FFFFFFF00000000";
        b <= x"0000000180000000";
        operation <= "01010"; -- Saturated dword addition
        wait for 10 ns;
        assert result = x"FFFFFFFF80000000"
            report "Test 33 Failed: DWord mixed operations"
            severity error;
        if result = x"FFFFFFFF80000000" then
            pass_count := pass_count + 1;
        end if;

        -- Test 34: Sequential subtraction with saturation
        test_count := test_count + 1;
        a <= x"0100020003000400";
        b <= x"0200030004000500";
        operation <= "01101"; -- Saturated word subtraction
        wait for 10 ns;
        assert result = x"0000000000000000"
            report "Test 34 Failed: Sequential subtraction"
            severity error;
        if result = x"0000000000000000" then
            pass_count := pass_count + 1;
        end if;

        -- Test 35: Complex pattern with mixed operations
        test_count := test_count + 1;
        a <= x"ABCDEF0123456789";
        b <= x"1234567890ABCDEF";
        operation <= "01010"; -- Saturated dword addition
        wait for 10 ns;
        assert result = x"FFFFFFFFB3F13578"
            report "Test 35 Failed: Complex pattern mixed operations"
            severity error;
        if result = x"FFFFFFFFB3F13578" then
            pass_count := pass_count + 1;
        end if;
        
        --Test 36
        test_count := test_count + 1;
        a <= x"7F7F7F7F7F7F7F7F";  -- All bytes = +127
        b <= x"0101010101010101";  -- All bytes = +1
        operation <= "11000";  -- Signed saturated byte addition
        wait for 10 ns;
        assert result = x"7F7F7F7F7F7F7F7F"  -- Should saturate to +127
            report "Test 36 Failed: Signed byte addition positive overflow"
            severity error;
        if result = x"7F7F7F7F7F7F7F7F" then
            pass_count := pass_count + 1;
        end if;

        -- Test 37: Signed byte addition with negative overflow
        test_count := test_count + 1;
        a <= x"8080808080808080";  -- All bytes = -128
        b <= x"8080808080808080";  -- All bytes = -128
        operation <= "11000";  -- Signed saturated byte addition
        wait for 10 ns;
        assert result = x"8080808080808080"  -- Should saturate to -128
            report "Test 37 Failed: Signed byte addition negative overflow"
            severity error;
        if result = x"8080808080808080" then
            pass_count := pass_count + 1;
        end if;

        -- Test 38: Signed word addition with positive overflow
        test_count := test_count + 1;
        a <= x"7FFF7FFF7FFF7FFF";  -- All words = +32767
        b <= x"0001000100010001";  -- All words = +1
        operation <= "11001";  -- Signed saturated word addition
        wait for 10 ns;
        assert result = x"7FFF7FFF7FFF7FFF"  -- Should saturate to +32767
            report "Test 38 Failed: Signed word addition positive overflow"
            severity error;
        if result = x"7FFF7FFF7FFF7FFF" then
            pass_count := pass_count + 1;
        end if;

        -- Test 39: Signed word addition with negative overflow
        test_count := test_count + 1;
        a <= x"8000800080008000";  -- All words = -32768
        b <= x"8000800080008000";  -- All words = -32768
        operation <= "11001";  -- Signed saturated word addition
        wait for 10 ns;
        assert result = x"8000800080008000"  -- Should saturate to -32768
            report "Test 39 Failed: Signed word addition negative overflow"
            severity error;
        if result = x"8000800080008000" then
            pass_count := pass_count + 1;
        end if;

        -- Test 40: Signed dword addition with positive overflow
        test_count := test_count + 1;
        a <= x"7FFFFFFF7FFFFFFF";  -- Both dwords = +2^31-1
        b <= x"0000000100000001";  -- Both dwords = +1
        operation <= "11010";  -- Signed saturated dword addition
        wait for 10 ns;
        assert result = x"7FFFFFFF7FFFFFFF"  -- Should saturate to +2^31-1
            report "Test 40 Failed: Signed dword addition positive overflow"
            severity error;
        if result = x"7FFFFFFF7FFFFFFF" then
            pass_count := pass_count + 1;
        end if;

        -- Test 41: Signed byte subtraction with positive overflow
        test_count := test_count + 1;
        a <= x"7F7F7F7F7F7F7F7F";  -- All bytes = +127
        b <= x"8080808080808080";  -- All bytes = -128
        operation <= "11100";  -- Signed saturated byte subtraction
        wait for 10 ns;
        assert result = x"7F7F7F7F7F7F7F7F"  -- Should saturate to +127
            report "Test 41 Failed: Signed byte subtraction positive overflow"
            severity error;
        if result = x"7F7F7F7F7F7F7F7F" then
            pass_count := pass_count + 1;
        end if;

        -- Test 42: Signed byte subtraction with negative overflow
        test_count := test_count + 1;
        a <= x"8080808080808080";  -- All bytes = -128
        b <= x"7F7F7F7F7F7F7F7F";  -- All bytes = +127
        operation <= "11100";  -- Signed saturated byte subtraction
        wait for 10 ns;
        assert result = x"8080808080808080"  -- Should saturate to -128
            report "Test 42 Failed: Signed byte subtraction negative overflow"
            severity error;
        if result = x"8080808080808080" then
            pass_count := pass_count + 1;
        end if;

        -- Test 43: Signed word subtraction with positive overflow
        test_count := test_count + 1;
        a <= x"7FFF7FFF7FFF7FFF";  -- All words = +32767
        b <= x"8000800080008000";  -- All words = -32768
        operation <= "11101";  -- Signed saturated word subtraction
        wait for 10 ns;
        assert result = x"7FFF7FFF7FFF7FFF"  -- Should saturate to +32767
            report "Test 43 Failed: Signed word subtraction positive overflow"
            severity error;
        if result = x"7FFF7FFF7FFF7FFF" then
            pass_count := pass_count + 1;
        end if;

        -- Test 44: Signed word subtraction with negative overflow
        test_count := test_count + 1;
        a <= x"8000800080008000";  -- All words = -32768
        b <= x"7FFF7FFF7FFF7FFF";  -- All words = +32767
        operation <= "11101";  -- Signed saturated word subtraction
        wait for 10 ns;
        assert result = x"8000800080008000"  -- Should saturate to -32768
            report "Test 44 Failed: Signed word subtraction negative overflow"
            severity error;
        if result = x"8000800080008000" then
            pass_count := pass_count + 1;
        end if;

        -- Test 45: Signed dword mixed operations
        test_count := test_count + 1;
        a <= x"7FFFFFFF80000000";  -- First dword = max positive, second = min negative
        b <= x"0000000100000001";  -- Small positive values
        operation <= "11010";  -- Signed saturated dword addition
        wait for 10 ns;
        assert result = x"7FFFFFFF80000001"  -- First should saturate, second should add
            report "Test 45 Failed: Signed dword mixed operations"
            severity error;
        if result = x"7FFFFFFF80000001" then
            pass_count := pass_count + 1;
        end if;
        
        
        if pass_count = test_count then
            report "ALL TESTS PASSED!"
            severity note;
        else
            report "SOME TESTS FAILED!"
            severity failure;
        end if;

        wait;
    end process;
end Behavioral;
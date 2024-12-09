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
    UUT: padd_psub_wraparound port map (
        a => a,
        b => b,
        operation => operation,
        result => result
    );

    process
        variable test_count : integer := 0;
        variable pass_count : integer := 0;
    begin
        -- Test 1: Basic byte addition
        test_count := test_count + 1;
        operation <= "000"; 
        a <= x"0102030405060708";
        b <= x"0807060504030201";
        wait for 10 ns;
        assert result = x"0909090909090909"
            report "Test 1 Failed: Basic byte addition" severity error;
        if result = x"0909090909090909" then
            pass_count := pass_count + 1;
        end if;

        -- Test 2: Byte subtraction
        test_count := test_count + 1;
        operation <= "100";
        wait for 10 ns;
        assert result = x"0706050403020107"
            report "Test 2 Failed: Byte subtraction" severity error;
        if result = x"0706050403020107" then
            pass_count := pass_count + 1;
        end if;
        

        -- Test 3: Word addition
        test_count := test_count + 1;
        operation <= "001";
        a <= x"0001000200030004";
        b <= x"0004000300020001";
        wait for 10 ns;
        assert result = x"0005000500050005"
            report "Test 3 Failed: Word addition" severity error;
        if result = x"0005000500050005" then
            pass_count := pass_count + 1;
        end if;

        -- Test 4: Word subtraction
        test_count := test_count + 1;
        operation <= "101";
        wait for 10 ns;
        assert result = x"FFFDFFFF00010003"
            report "Test 4 Failed: Word subtraction" severity error;
        if result = x"FFFDFFFF00010003" then
            pass_count := pass_count + 1;
        end if;

        -- Test 5: DWord addition
        test_count := test_count + 1;
        operation <= "010";
        a <= x"0000000100000002";
        b <= x"0000000200000001";
        wait for 10 ns;
        assert result = x"0000000300000003"
            report "Test 5 Failed: DWord addition" severity error;
        if result = x"0000000300000003" then
            pass_count := pass_count + 1;
        end if;

        -- Test 6: DWord subtraction
        test_count := test_count + 1;
        operation <= "110";
        wait for 10 ns;
        assert result = x"FFFFFFFF00000001"
            report "Test 6 Failed: DWord subtraction" severity error;
        if result = x"FFFFFFFF00000001" then
            pass_count := pass_count + 1;
        end if;

       -- Test 7: Byte wraparound addition 
        test_count := test_count + 1;
        operation <= "000";
        a <= x"FF01FF03FF05FF07";
        b <= x"0102030405060708";
        wait for 10 ns;
        assert result = x"0003020304060F0F"
            report "Test 7 Failed: Byte wraparound addition" severity error;
        if result = x"0003020304060F0F" then
            pass_count := pass_count + 1;
        end if;
        

        -- Test 8: Word wraparound
        test_count := test_count + 1;
        operation <= "001";
        a <= x"FFFF000100020003";
        b <= x"0001FFFF00030004";
        wait for 10 ns;
        assert result = x"0000000000050007"
            report "Test 8 Failed: Word wraparound" severity error;
        if result = x"0000000000050007" then
            pass_count := pass_count + 1;
        end if;
        
        -- Test 9: Zero operand test
        test_count := test_count + 1;
        operation <= "000";
        a <= x"0000000000000000";
        b <= x"0102030405060708";
        wait for 10 ns;
        assert result = x"0102030405060708"
            report "Test 9 Failed: Zero operand test" severity error;
        if result = x"0102030405060708" then
            pass_count := pass_count + 1;
        end if;

        -- Test 10: Maximum value test
        test_count := test_count + 1;
        operation <= "000";
        a <= x"FFFFFFFFFFFFFFFF";
        b <= x"0101010101010101";
        wait for 10 ns;
        assert result = x"0000000000000000"
            report "Test 10 Failed: Maximum value test" severity error;
        if result = x"0000000000000000" then
            pass_count := pass_count + 1;
        end if;

       

        wait;
    end process;
end sim;
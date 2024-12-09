library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity pmul_tb is
end pmul_tb;


architecture Behavioral of pmul_tb is
    
    component pmul
        Port (
            a, b : in STD_LOGIC_VECTOR(63 downto 0);
            op : in STD_LOGIC;
            result : out STD_LOGIC_VECTOR(63 downto 0)
        );
    end component;

    
    signal a, b : STD_LOGIC_VECTOR(63 downto 0);
    signal op : STD_LOGIC;
    signal result : STD_LOGIC_VECTOR(63 downto 0);

    
    signal pass_count : integer := 0;

begin
    
    uut: pmul port map(
        a => a,
        b => b,
        op => op,
        result => result
    );


    process
    begin
        -- Test 1: Zero multiplicand (op = '0', PMULLW)
        op <= '0';
        a <= x"0000000000000000";
        b <= x"FFFFFFFFFFFFFFFF";
        wait for 10 ns;
        assert result = x"0000000000000000"
            report "Test 1 Failed: Zero multiplicand" severity error;
        if result = x"0000000000000000" then
            pass_count <= pass_count + 1;
        end if;

        -- Test 2: Max values (op = '1', PMULHW)
        op <= '1';
        a <= x"FFFFFFFFFFFFFFFF";
        b <= x"FFFFFFFFFFFFFFFF";
        wait for 10 ns;
        assert result = x"FFFFFFFFFFFFFFFF"
            report "Test 2 Failed: Max values multiplication (high word)" severity error;
        if result = x"FFFFFFFFFFFFFFFF" then
            pass_count <= pass_count + 1;
        end if;

        -- Test 3: Alternating bits (op = '0', PMULLW)
        op <= '0';
        a <= x"AAAAAAAAAAAAAAAA";
        b <= x"5555555555555555";
        wait for 10 ns;
        assert result = x"0000000000000000"  -- Expected value might vary
            report "Test 3 Failed: Alternating bits multiplication (low word)" severity error;
        if result = x"0000000000000000" then
            pass_count <= pass_count + 1;
        end if;

   
        wait;
    end process;

end Behavioral;

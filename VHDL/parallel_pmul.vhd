library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pmul is
    Port (
        a, b : in STD_LOGIC_VECTOR(63 downto 0);
        op : in STD_LOGIC;
        result : out STD_LOGIC_VECTOR(63 downto 0)
    );
end pmul;

architecture Behavioral of pmul is
    component WallaceMultiplier16bit is 
        Port (
            x, y : in STD_LOGIC_VECTOR(15 downto 0);
            p : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    signal mul_result0, mul_result1, mul_result2, mul_result3 : STD_LOGIC_VECTOR(31 downto 0);
begin
    -- Instantiate 4 16-bit Wallace multipliers
    mul0: WallaceMultiplier16bit port map(
        x => a(15 downto 0),
        y => b(15 downto 0),
        p => mul_result0
    );
    
    mul1: WallaceMultiplier16bit port map(
        x => a(31 downto 16),
        y => b(31 downto 16),
        p => mul_result1
    );
    
    mul2: WallaceMultiplier16bit port map(
        x => a(47 downto 32),
        y => b(47 downto 32),
        p => mul_result2
    );
    
    mul3: WallaceMultiplier16bit port map(
        x => a(63 downto 48),
        y => b(63 downto 48),
        p => mul_result3
    );

    
    process(op, mul_result0, mul_result1, mul_result2, mul_result3)
    begin
        if op = '0' then -- pmullw
            result(15 downto 0) <= mul_result0(15 downto 0);
            result(31 downto 16) <= mul_result1(15 downto 0);
            result(47 downto 32) <= mul_result2(15 downto 0);
            result(63 downto 48) <= mul_result3(15 downto 0);
        else -- pmulhw
            result(15 downto 0) <= mul_result0(31 downto 16);
            result(31 downto 16) <= mul_result1(31 downto 16);
            result(47 downto 32) <= mul_result2(31 downto 16);
            result(63 downto 48) <= mul_result3(31 downto 16);
        end if;
    end process;
end Behavioral;
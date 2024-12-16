library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;


entity pmul is
    port (
        a, b : in std_logic_vector(63 downto 0);
        op : in std_logic; -- '0' for pmullw, '1' for pmulhw
        result : out std_logic_vector(63 downto 0)
    );
end pmul;


architecture behavioral of pmul is
    component booth_multiplier is
        port(
            m : in std_logic_vector(7 downto 0);
            r : in std_logic_vector(7 downto 0);
            result : out std_logic_vector(15 downto 0)
        );
    end component;

    type mul_results_array is array (0 to 7) of std_logic_vector(15 downto 0);
    signal mul_results : mul_results_array;
    
begin
    
    gen_mul: for i in 0 to 7 generate
        multi: booth_multiplier port map (
            m => a((i*8+7) downto (i*8)),
            r => b((i*8+7) downto (i*8)),
            result => mul_results(i)
        );
    end generate;

    process(mul_results, op)
    begin
        for i in 0 to 7 loop
            if op = '0' then
                -- PMULLW: lower byte
                result((i*8+7) downto (i*8)) <= mul_results(i)(7 downto 0);
            else
                -- PMULHW: upper byte
                result((i*8+7) downto (i*8)) <= mul_results(i)(15 downto 8);
            end if;
        end loop;
    end process;

end behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity WallaceMultiplier16bit is
    Port (
        x, y : in STD_LOGIC_VECTOR(15 downto 0);
        p : out STD_LOGIC_VECTOR(31 downto 0)
    );
end WallaceMultiplier16bit;

architecture Behavioral of WallaceMultiplier16bit is
    type pp_type is array(0 to 15) of unsigned(31 downto 0);
    signal pp_array : pp_type;
    signal stage1, stage2, stage3, stage4 : unsigned(31 downto 0);
begin
    -- produse partiale 
    gen_pp: process(x, y)
    begin
        for i in 0 to 15 loop
            if y(i) = '1' then
                pp_array(i) <= shift_left(resize(unsigned(x), 32), i);
            else
                pp_array(i) <= (others => '0');
            end if;
        end loop;
    end process;

    
    stage1 <= pp_array(0) + pp_array(1) + pp_array(2) + pp_array(3);
    stage2 <= pp_array(4) + pp_array(5) + pp_array(6) + pp_array(7);
    stage3 <= pp_array(8) + pp_array(9) + pp_array(10) + pp_array(11);
    stage4 <= pp_array(12) + pp_array(13) + pp_array(14) + pp_array(15);
    
    p <= std_logic_vector(stage1 + stage2 + stage3 + stage4);

end Behavioral;
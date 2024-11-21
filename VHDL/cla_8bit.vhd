
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cla_8bit is
    Port (
        a, b : in std_logic_vector(7 downto 0);
        cin : in std_logic;
        sum : out std_logic_vector(7 downto 0);
        cout : out std_logic;
        p, g : out std_logic_vector(7 downto 0)  
    );
end cla_8bit;

architecture Behavioral of cla_8bit is
    signal p_int, g_int : std_logic_vector(7 downto 0);  
    signal c : std_logic_vector(8 downto 0);  
begin
    
    p_gen: for i in 0 to 7 generate
        p_int(i) <= a(i) xor b(i); -- indicã dacã bi?ii pot propaga carry
        g_int(i) <= a(i) and b(i); -- indicã dacã bi?ii genereazã carry
    end generate;

  
    p <= p_int;
    g <= g_int;

    --logica de propagare 
    c(0) <= cin;
    c(1) <= g_int(0) or (p_int(0) and c(0));
    c(2) <= g_int(1) or (p_int(1) and g_int(0)) or (p_int(1) and p_int(0) and c(0));
    c(3) <= g_int(2) or (p_int(2) and g_int(1)) or (p_int(2) and p_int(1) and g_int(0)) or 
            (p_int(2) and p_int(1) and p_int(0) and c(0));
    c(4) <= g_int(3) or (p_int(3) and g_int(2)) or (p_int(3) and p_int(2) and g_int(1)) or 
            (p_int(3) and p_int(2) and p_int(1) and g_int(0)) or 
            (p_int(3) and p_int(2) and p_int(1) and p_int(0) and c(0));
    c(5) <= g_int(4) or (p_int(4) and c(4));
    c(6) <= g_int(5) or (p_int(5) and c(5));
    c(7) <= g_int(6) or (p_int(6) and c(6));
    c(8) <= g_int(7) or (p_int(7) and c(7));

    
    --generarea sumei   
    sum_gen: for i in 0 to 7 generate
        sum(i) <= p_int(i) xor c(i);
    end generate;

    
    cout <= c(8); --ultimul carry devine cel de iesire
end Behavioral;
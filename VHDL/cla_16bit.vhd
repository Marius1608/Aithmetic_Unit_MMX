library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cla_16bit is
    Port (
        a, b : in std_logic_vector(15 downto 0);
        cin : in std_logic;
        sum : out std_logic_vector(15 downto 0);
        cout : out std_logic;
        p, g : out std_logic_vector(15 downto 0)
    );
end cla_16bit;

architecture Behavioral of cla_16bit is
    component cla_8bit is
        Port (
            a, b : in std_logic_vector(7 downto 0);
            cin : in std_logic;
            sum : out std_logic_vector(7 downto 0);
            cout : out std_logic;
            p, g : out std_logic_vector(7 downto 0)
        );
    end component;

    signal c_middle : std_logic;  
    signal p_low, p_high : std_logic_vector(7 downto 0);
    signal g_low, g_high : std_logic_vector(7 downto 0);
begin
    
    CLA_LOW: cla_8bit port map (
        a => a(7 downto 0),
        b => b(7 downto 0),
        cin => cin,
        sum => sum(7 downto 0),
        cout => c_middle,
        p => p_low,
        g => g_low
    );

   
    CLA_HIGH: cla_8bit port map (
        a => a(15 downto 8),
        b => b(15 downto 8),
        cin => c_middle,
        sum => sum(15 downto 8),
        cout => cout,
        p => p_high,
        g => g_high
    );

    
    p(7 downto 0) <= p_low;
    p(15 downto 8) <= p_high;
    g(7 downto 0) <= g_low;
    g(15 downto 8) <= g_high;
    
end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cla_32bit is
    Port (
        a, b : in std_logic_vector(31 downto 0);
        cin : in std_logic;
        sum : out std_logic_vector(31 downto 0);
        cout : out std_logic;
        p, g : out std_logic_vector(31 downto 0)
    );
end cla_32bit;

architecture Behavioral of cla_32bit is
    component cla_16bit is
        Port (
            a, b : in std_logic_vector(15 downto 0);
            cin : in std_logic;
            sum : out std_logic_vector(15 downto 0);
            cout : out std_logic;
            p, g : out std_logic_vector(15 downto 0)
        );
    end component;

    signal c_middle : std_logic;  
    signal p_low, p_high : std_logic_vector(15 downto 0);
    signal g_low, g_high : std_logic_vector(15 downto 0);
begin
    
    CLA_LOW: cla_16bit port map (
        a => a(15 downto 0),
        b => b(15 downto 0),
        cin => cin,
        sum => sum(15 downto 0),
        cout => c_middle,
        p => p_low,
        g => g_low
    );

    
    CLA_HIGH: cla_16bit port map (
        a => a(31 downto 16),
        b => b(31 downto 16),
        cin => c_middle,
        sum => sum(31 downto 16),
        cout => cout,
        p => p_high,
        g => g_high
    );

    p(15 downto 0) <= p_low;
    p(31 downto 16) <= p_high;
    g(15 downto 0) <= g_low;
    g(31 downto 16) <= g_high;
end Behavioral;

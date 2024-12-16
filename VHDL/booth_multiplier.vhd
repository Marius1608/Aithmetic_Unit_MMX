library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;


entity booth_multiplier is
    port(
        m : in std_logic_vector(7 downto 0);
        r : in std_logic_vector(7 downto 0);
        result : out std_logic_vector(15 downto 0)
    );           
end booth_multiplier;


architecture behavior of booth_multiplier is
begin
    process(m, r)
        constant x_zeros : std_logic_vector(7 downto 0) := (others => '0');
        constant y_zeros : std_logic_vector(7 downto 0) := (others => '0');
        variable a, s, p : std_logic_vector(17 downto 0);
        variable mn      : std_logic_vector(7 downto 0);
    
    begin
        a := (others => '0');
        s := (others => '0');
        p := (others => '0');
        
        if (m /= x_zeros and r /= y_zeros) then
        
            -- Load multiplicand into a
            a(16 downto 9) := m;
            a(17):= m(7);  -- Sign extension
            
            -- Create negative of multiplicand
            mn:=(not m) + 1;
            
            -- Load negative value into s
            s(16 downto 9) := mn;
            s(17) := not(m(7));
            
            -- Load multiplier into p
            p(8 downto 1) := r;
            
            -- Main booth algorithm loop
            for i in 1 to 8 loop
                if (p(1 downto 0) = "01") then
                    p := p + a;
                elsif (p(1 downto 0) = "10") then
                    p := p + s;
                end if;
                
                -- Arithmetic right shift
                p(16 downto 0) := p(17 downto 1);
            end loop;
        end if;
        
        result <= p(16 downto 1);
        
    end process;
end behavior;
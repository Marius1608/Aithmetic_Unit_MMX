library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--000: Adunare pe 8 bi?i (byte), fãrã satura?ie
--001: Adunare pe 16 bi?i (word), fãrã satura?ie
--010: Adunare pe 32 bi?i (dword), fãrã satura?ie
--100: Scãdere pe 8 bi?i (byte), cu satura?ie pentru semnat
--101: Scãdere pe 16 bi?i (word), cu satura?ie pentru semnat
--110: Scãdere pe 32 bi?i (dword), cu satura?ie pentru semnat
--011/111


entity parallel_packed_arithmetic is
    Port (
        a, b : in std_logic_vector(63 downto 0);
        operation : in std_logic_vector(2 downto 0);
        result : out std_logic_vector(63 downto 0)
    );
end parallel_packed_arithmetic;

architecture Behavioral of parallel_packed_arithmetic is

    -- 8-bit CLA
    component cla_8bit is
        Port (
            a, b : in std_logic_vector(7 downto 0);
            cin : in std_logic;
            sum : out std_logic_vector(7 downto 0);
            cout : out std_logic;
            p, g : out std_logic_vector(7 downto 0)
        );
    end component;

    -- 16-bit CLA
    component cla_16bit is
        Port (
            a, b : in std_logic_vector(15 downto 0);
            cin : in std_logic;
            sum : out std_logic_vector(15 downto 0);
            cout : out std_logic;
            p, g : out std_logic_vector(15 downto 0)
        );
    end component;

    -- 32-bit CLA
    component cla_32bit is
        Port (
            a, b : in std_logic_vector(31 downto 0);
            cin : in std_logic;
            sum : out std_logic_vector(31 downto 0);
            cout : out std_logic;
            p, g : out std_logic_vector(31 downto 0)
        );
    end component;

    
    type byte_array is array (0 to 7) of std_logic_vector(7 downto 0);
    type word_array is array (0 to 3) of std_logic_vector(15 downto 0);
    type dword_array is array (0 to 1) of std_logic_vector(31 downto 0);

    signal byte_sums : byte_array; --rezultatul sumelor
    signal byte_couts : std_logic_vector(7 downto 0); --carry-urile pentru fiecare suma
    signal byte_ps, byte_gs : byte_array; --semnalele de propagare si generare 

    signal word_sums : word_array;
    signal word_couts : std_logic_vector(3 downto 0);
    signal word_ps, word_gs : word_array;

    signal dword_sums : dword_array;
    signal dword_couts : std_logic_vector(1 downto 0);
    signal dword_ps, dword_gs : dword_array;
    
    signal b_input : std_logic_vector(63 downto 0);

begin
   
    b_input <= not b when operation(2) = '1' else b; 
    
    BYTE_ADDERS: for i in 0 to 7 generate
        CLA8: cla_8bit port map (
            a => a((i+1)*8-1 downto i*8),
            b => b_input((i+1)*8-1 downto i*8),
            cin => operation(2), 
            sum => byte_sums(i),
            cout => byte_couts(i),
            p => byte_ps(i),
            g => byte_gs(i)
        );
    end generate;

    WORD_ADDERS: for i in 0 to 3 generate
        CLA16: cla_16bit port map (
            a => a((i+1)*16-1 downto i*16),
            b => b_input((i+1)*16-1 downto i*16),
            cin => operation(2),
            sum => word_sums(i),
            cout => word_couts(i),
            p => word_ps(i),
            g => word_gs(i)
        );
    end generate;

    DWORD_ADDERS: for i in 0 to 1 generate
        CLA32: cla_32bit port map (
            a => a((i+1)*32-1 downto i*32),
            b => b_input((i+1)*32-1 downto i*32),
            cin => operation(2),
            sum => dword_sums(i),
            cout => dword_couts(i),
            p => dword_ps(i),
            g => dword_gs(i)
        );
    end generate;
    
    process(byte_sums, word_sums, dword_sums, byte_couts, word_couts, dword_couts, operation)
        variable is_signed : boolean;
    begin
        is_signed := operation(2) = '1';

        case operation(1 downto 0) is
            when "00" =>  -- Byte
                for i in 0 to 7 loop
                    if is_signed then
                    
                        -- Verificare saturare cu semn
                        if (a((i+1)*8-1) = '0' and b_input((i+1)*8-1) = '1' and byte_sums(i)(7) = '1') or
                           (a((i+1)*8-1) = '1' and b_input((i+1)*8-1) = '0' and byte_sums(i)(7) = '0') then
                           
                            -- Overflow 
                            if byte_sums(i)(7) = '1' then
                                result((i+1)*8-1 downto i*8) <= "10000000";  -- Minimum value (-128)
                            else
                                result((i+1)*8-1 downto i*8) <= "01111111";  -- Maximum value (127)
                            end if;
                        else
                            result((i+1)*8-1 downto i*8) <= byte_sums(i);
                        end if;
                   
                    else
                        -- Verificare saturare fara semn
                        if byte_couts(i) = '1' then
                            result((i+1)*8-1 downto i*8) <= (others => '1');  -- Saturare to 255
                        else
                            result((i+1)*8-1 downto i*8) <= byte_sums(i);
                        end if;
                    end if;
                end loop;

            when "01" =>  -- Word 
                for i in 0 to 3 loop
                    if is_signed then
                    
                        -- Saturare cu semn 
                        if (a((i+1)*16-1) = '0' and b_input((i+1)*16-1) = '1' and word_sums(i)(15) = '1') or
                           (a((i+1)*16-1) = '1' and b_input((i+1)*16-1) = '0' and word_sums(i)(15) = '0') then
                           
                            -- Overflow 
                            if word_sums(i)(15) = '1' then
                                result((i+1)*16-1 downto i*16) <= "1000000000000000";  -- Min (-32768)
                            else
                                result((i+1)*16-1 downto i*16) <= "0111111111111111";  -- Max (32767)
                            end if;
                        else
                            result((i+1)*16-1 downto i*16) <= word_sums(i);
                        end if;
                    else
                        -- Saturatie fara semn
                        if word_couts(i) = '1' then
                            result((i+1)*16-1 downto i*16) <= (others => '1');  -- Saturare to 65535
                        else
                            result((i+1)*16-1 downto i*16) <= word_sums(i);
                        end if;
                    end if;
                end loop;

            when "10" =>  -- Dword o
                for i in 0 to 1 loop
                    if is_signed then
                    
                        -- Saturare cu semn 
                        if (a((i+1)*32-1) = '0' and b_input((i+1)*32-1) = '1' and dword_sums(i)(31) = '1') or
                           (a((i+1)*32-1) = '1' and b_input((i+1)*32-1) = '0' and dword_sums(i)(31) = '0') then
                           
                            -- Overflow 
                            if dword_sums(i)(31) = '1' then
                                result((i+1)*32-1 downto i*32) <= X"80000000";  -- Min (-2^31)
                            else
                                result((i+1)*32-1 downto i*32) <= X"7FFFFFFF";  -- Max (2^31-1)
                            end if;
                        else
                            result((i+1)*32-1 downto i*32) <= dword_sums(i);
                        end if;
                    else
                        -- Saturare fara semnn 
                        if dword_couts(i) = '1' then
                            result((i+1)*32-1 downto i*32) <= (others => '1');  -- Saturare to 2^32-1
                        else
                            result((i+1)*32-1 downto i*32) <= dword_sums(i);
                        end if;
                    end if;
                end loop;

            when others =>
                result <= (others => '0');
        end case;
    end process;
    
end Behavioral;
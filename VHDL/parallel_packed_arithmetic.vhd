library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity parallel_packed_arithmetic is
    Port (
        a, b     : in  std_logic_vector(63 downto 0);
        operation: in  std_logic_vector(4 downto 0); 
        
        -- operation(4) = signed ('1') / unsigned ('0')
        -- operation(3) = saturatie ('1)' / normal ('0')
        -- operation(2) = sc?dere ('1') /adunare ('0')
        -- operation(1:0) = dimensiune operanzi (00=byte, 01=word, 10=dword)
        
        result   : out std_logic_vector(63 downto 0)
    );
end parallel_packed_arithmetic;

architecture Behavioral of parallel_packed_arithmetic is
    component cla_8bit is
        Port (
            a, b : in  std_logic_vector(7 downto 0);
            cin  : in  std_logic;
            sum  : out std_logic_vector(7 downto 0);
            cout : out std_logic
        );
    end component;

    type byte_array is array (0 to 7) of std_logic_vector(7 downto 0);
    signal byte_sums     : byte_array;
    signal byte_couts    : std_logic_vector(7 downto 0);
    signal carry_inputs  : std_logic_vector(7 downto 0);
    signal b_input      : std_logic_vector(63 downto 0);

begin
    -- Logica pentru b_input (negare pentru scãdere)
    b_input <= not b when operation(2) = '1' else b;
    
    -- Logica de mux control integratã direct
    process(operation, byte_couts)
    begin
        case operation(1 downto 0) is
            when "00" =>  -- Byte operations
                for i in 0 to 7 loop
                    carry_inputs(i) <= operation(2);  -- '1' pentru scãdere, '0' pentru adunare
                end loop;
                
            when "01" =>  -- Word operations
                for i in 0 to 3 loop
                    carry_inputs(i*2) <= operation(2);  -- Prima pozi?ie din word
                    carry_inputs(i*2+1) <= byte_couts(i*2);  -- A doua pozi?ie ia carry din prima
                end loop;
                
            when "10" =>  -- DWord operations
                for i in 0 to 1 loop
                    carry_inputs(i*4) <= operation(2);  -- Prima pozi?ie din dword
                    carry_inputs(i*4+1) <= byte_couts(i*4);     -- Pozi?iile urmãtoare iau
                    carry_inputs(i*4+2) <= byte_couts(i*4+1);   -- carry-ul din pozi?ia
                    carry_inputs(i*4+3) <= byte_couts(i*4+2);   -- anterioarã
                end loop;
                
            when others =>
                carry_inputs <= (others => '0');
        end case;
    end process;

    -- Generare CLA pentru fiecare byte
    gen_cla: for i in 0 to 7 generate
        inst_cla8: cla_8bit port map (
            a   => a((i+1)*8-1 downto i*8),
            b   => b_input((i+1)*8-1 downto i*8),
            cin => carry_inputs(i),
            sum => byte_sums(i),
            cout => byte_couts(i)
        );
    end generate;

    -- Restul codului rãmâne neschimbat
    process(byte_sums, byte_couts, operation, a, b_input, b, carry_inputs)
    begin
        case operation(1 downto 0) is
            when "00" =>  -- Byte 
                for i in 0 to 7 loop
                    if operation(3) = '0' then
                        -- Normal wraparound
                        result((i+1)*8-1 downto i*8) <= byte_sums(i);
                    else
                        if operation(4) = '0' then  -- Unsigned
                            if operation(2) = '0' then  -- Addition
                                if byte_couts(i) = '1' then
                                    result((i+1)*8-1 downto i*8) <= (others => '1');  -- 255
                                else
                                    result((i+1)*8-1 downto i*8) <= byte_sums(i);
                                end if;
                            else  -- Subtraction
                                if (carry_inputs(i) = '0') or
                                   (unsigned(a((i+1)*8-1 downto i*8)) < unsigned(b((i+1)*8-1 downto i*8))) then
                                    result((i+1)*8-1 downto i*8) <= (others => '0');  -- 0
                                else
                                    result((i+1)*8-1 downto i*8) <= byte_sums(i);
                                end if;
                            end if;
                        else  -- Signed
                            if operation(2) = '0' then  -- Addition
                                -- positive overflow
                                if (a((i+1)*8-1) = '0' and b((i+1)*8-1) = '0' and byte_sums(i)(7) = '1') then
                                    result((i+1)*8-1 downto i*8) <= "01111111";  -- +127
                                -- negative overflow
                                elsif (a((i+1)*8-1) = '1' and b((i+1)*8-1) = '1' and byte_sums(i)(7) = '0') then
                                    result((i+1)*8-1 downto i*8) <= "10000000";  -- -128
                                else
                                    result((i+1)*8-1 downto i*8) <= byte_sums(i);
                                end if;
                            else  -- Subtraction
                                -- positive overflow
                                if (a((i+1)*8-1) = '0' and b((i+1)*8-1) = '1' and byte_sums(i)(7) = '1') then
                                    result((i+1)*8-1 downto i*8) <= "01111111";  -- +127
                                -- negative overflow
                                elsif (a((i+1)*8-1) = '1' and b((i+1)*8-1) = '0' and byte_sums(i)(7) = '0') then
                                    result((i+1)*8-1 downto i*8) <= "10000000";  -- -128
                                else
                                    result((i+1)*8-1 downto i*8) <= byte_sums(i);
                                end if;
                            end if;
                        end if;
                    end if;
                end loop;

            when "01" =>  -- Word 
                for i in 0 to 3 loop
                    if operation(3) = '0' then
                        -- Normal wraparound
                        result((i+1)*16-1 downto i*16) <= byte_sums(i*2+1) & byte_sums(i*2);
                    else
                        if operation(4) = '0' then  -- Unsigned
                            if operation(2) = '0' then  -- Addition
                                if (byte_couts(i*2) = '1') or (byte_couts(i*2+1) = '1') then
                                    result((i+1)*16-1 downto i*16) <= (others => '1');  -- 65535
                                else
                                    result((i+1)*16-1 downto i*16) <= byte_sums(i*2+1) & byte_sums(i*2);
                                end if;
                            else  -- Subtraction
                                if (carry_inputs(i*2) = '0') or
                                   (unsigned(a((i+1)*16-1 downto i*16)) < unsigned(b((i+1)*16-1 downto i*16))) then
                                    result((i+1)*16-1 downto i*16) <= (others => '0');  -- 0
                                else
                                    result((i+1)*16-1 downto i*16) <= byte_sums(i*2+1) & byte_sums(i*2);
                                end if;
                            end if;
                        else  -- Signed
                            if operation(2) = '0' then  -- Addition
                                -- Check for positive overflow
                                if (a((i+1)*16-1) = '0' and b((i+1)*16-1) = '0' and byte_sums(i*2+1)(7) = '1') then
                                    result((i+1)*16-1 downto i*16) <= "0111111111111111";  -- +32767
                                -- Check for negative overflow
                                elsif (a((i+1)*16-1) = '1' and b((i+1)*16-1) = '1' and byte_sums(i*2+1)(7) = '0') then
                                    result((i+1)*16-1 downto i*16) <= "1000000000000000";  -- -32768
                                else
                                    result((i+1)*16-1 downto i*16) <= byte_sums(i*2+1) & byte_sums(i*2);
                                end if;
                            else  -- Subtraction
                                -- Check for positive overflow
                                if (a((i+1)*16-1) = '0' and b((i+1)*16-1) = '1' and byte_sums(i*2+1)(7) = '1') then
                                    result((i+1)*16-1 downto i*16) <= "0111111111111111";  -- +32767
                                -- Check for negative overflow
                                elsif (a((i+1)*16-1) = '1' and b((i+1)*16-1) = '0' and byte_sums(i*2+1)(7) = '0') then
                                    result((i+1)*16-1 downto i*16) <= "1000000000000000";  -- -32768
                                else
                                    result((i+1)*16-1 downto i*16) <= byte_sums(i*2+1) & byte_sums(i*2);
                                end if;
                            end if;
                        end if;
                    end if;
                end loop;

            when "10" =>  -- DWord operations
                for i in 0 to 1 loop
                    if operation(3) = '0' then
                        -- Normal wraparound
                        result((i+1)*32-1 downto i*32) <= byte_sums(i*4+3) & byte_sums(i*4+2) & byte_sums(i*4+1) & byte_sums(i*4);
                    else
                        if operation(4) = '0' then  -- Unsigned
                            if operation(2) = '0' then  -- Addition
                                if byte_couts(i*4+3) = '1' then
                                    result((i+1)*32-1 downto i*32) <= (others => '1');  -- 2^32-1
                                else
                                    result((i+1)*32-1 downto i*32) <= byte_sums(i*4+3) & byte_sums(i*4+2) & byte_sums(i*4+1) & byte_sums(i*4);
                                end if;
                            else  -- Subtraction
                                if (carry_inputs(i*4) = '0') or
                                   (unsigned(a((i+1)*32-1 downto i*32)) < unsigned(b((i+1)*32-1 downto i*32))) then
                                    result((i+1)*32-1 downto i*32) <= (others => '0');  -- 0
                                else
                                    result((i+1)*32-1 downto i*32) <= byte_sums(i*4+3) & byte_sums(i*4+2) & byte_sums(i*4+1) & byte_sums(i*4);
                                end if;
                            end if;
                        else  -- Signed
                            if operation(2) = '0' then  -- Addition
                                -- positive overflow
                                if (a((i+1)*32-1) = '0' and b((i+1)*32-1) = '0' and byte_sums(i*4+3)(7) = '1') then
                                    result((i+1)*32-1 downto i*32) <= X"7FFFFFFF";  -- +2^31-1
                                -- negative overflow
                                elsif (a((i+1)*32-1) = '1' and b((i+1)*32-1) = '1' and byte_sums(i*4+3)(7) = '0') then
                                    result((i+1)*32-1 downto i*32) <= X"80000000";  -- -2^31
                                else
                                    result((i+1)*32-1 downto i*32) <= byte_sums(i*4+3) & byte_sums(i*4+2) & byte_sums(i*4+1) & byte_sums(i*4);
                                end if;
                            else  -- Subtraction
                                -- positive overflow
                                if (a((i+1)*32-1) = '0' and b((i+1)*32-1) = '1' and byte_sums(i*4+3)(7) = '1') then
                                    result((i+1)*32-1 downto i*32) <= X"7FFFFFFF";  -- +2^31-1
                                -- negative overflow
                                elsif (a((i+1)*32-1) = '1' and b((i+1)*32-1) = '0' and byte_sums(i*4+3)(7) = '0') then
                                    result((i+1)*32-1 downto i*32) <= X"80000000";  -- -2^31
                                else
                                    result((i+1)*32-1 downto i*32) <= byte_sums(i*4+3) & byte_sums(i*4+2) & byte_sums(i*4+1) & byte_sums(i*4);
                                end if;
                            end if;
                        end if;
                    end if;
                end loop;

            when others =>
                result <= (others => '0');
        end case;
    end process;

end Behavioral;
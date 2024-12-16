library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity unified_padd_psub is
    Port (
        a, b     : in  std_logic_vector(63 downto 0);
        operation: in  std_logic_vector(4 downto 0); 
        -- operation(4 downto 3) = operation type:
        --   00: wraparound
        --   01: signed saturation
        --   10: unsigned saturation
        --   11: --
        -- operation(2) = subtract ('1') / add ('0')
        -- operation(1:0) = operand size (00=byte, 01=word, 10=dword)
        result   : out std_logic_vector(63 downto 0)
    );
end unified_padd_psub;


architecture Behavioral of unified_padd_psub is
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

    constant MAX_POS_BYTE : std_logic_vector(7 downto 0) := "01111111";  -- +127
    constant MIN_NEG_BYTE : std_logic_vector(7 downto 0) := "10000000";  -- -128
    constant MAX_POS_WORD : std_logic_vector(15 downto 0) := "0111111111111111";  -- +32767
    constant MIN_NEG_WORD : std_logic_vector(15 downto 0) := "1000000000000000";  -- -32768
    constant MAX_UNSIGNED_BYTE : std_logic_vector(7 downto 0) := "11111111";  -- 255
    constant MAX_UNSIGNED_WORD : std_logic_vector(15 downto 0) := "1111111111111111";  -- 65535

begin
    
    b_input <= not b when operation(2) = '1' else b;
    
    process(operation, byte_couts)
    begin
        case operation(1 downto 0) is
            when "00" =>  -- Byte 
                for i in 0 to 7 loop
                    carry_inputs(i) <= operation(2);
                end loop;
                
            when "01" =>  -- Word 
                for i in 0 to 3 loop
                    carry_inputs(i*2) <= operation(2);
                    carry_inputs(i*2+1) <= byte_couts(i*2);
                end loop;
                
            when "10" =>  -- DWord 
                for i in 0 to 1 loop
                    carry_inputs(i*4) <= operation(2);
                    carry_inputs(i*4+1) <= byte_couts(i*4);
                    carry_inputs(i*4+2) <= byte_couts(i*4+1);
                    carry_inputs(i*4+3) <= byte_couts(i*4+2);
                end loop;
                
            when others =>
                carry_inputs <= (others => '0');
        end case;
    end process;

    gen_cla: for i in 0 to 7 generate
        inst_cla8: cla_8bit port map (
            a   => a((i+1)*8-1 downto i*8),
            b   => b_input((i+1)*8-1 downto i*8),
            cin => carry_inputs(i),
            sum => byte_sums(i),
            cout => byte_couts(i)
        );
    end generate;

    process(byte_sums, a, b, operation, byte_couts, carry_inputs)
    begin
        case operation(4 downto 3) is
            -- Wraparound mode
            when "00" =>
                case operation(1 downto 0) is
                    when "00" =>  
                        -- Byte 
                        for i in 0 to 7 loop
                            result((i+1)*8-1 downto i*8) <= byte_sums(i);
                        end loop;

                    when "01" =>  
                        -- Word 
                        for i in 0 to 3 loop
                            result((i+1)*16-1 downto i*16) <= byte_sums(i*2+1) & byte_sums(i*2);
                        end loop;

                    when "10" =>  
                        -- DWord 
                        for i in 0 to 1 loop
                            result((i+1)*32-1 downto i*32) <= byte_sums(i*4+3) & byte_sums(i*4+2) & 
                                                            byte_sums(i*4+1) & byte_sums(i*4);
                        end loop;

                    when others =>
                        result <= (others => '0');
                end case;

            -- Signed saturation 
            when "01" =>
                case operation(1 downto 0) is
                    when "00" =>  
                        -- Byte 
                        for i in 0 to 7 loop
                            if operation(2) = '0' then  
                                -- Addition
                                -- Positive overflow
                                if (a((i+1)*8-1) = '0' and b((i+1)*8-1) = '0' and byte_sums(i)(7) = '1') then
                                    result((i+1)*8-1 downto i*8) <= MAX_POS_BYTE;
                                -- Negative overflow
                                elsif (a((i+1)*8-1) = '1' and b((i+1)*8-1) = '1' and byte_sums(i)(7) = '0') then
                                    result((i+1)*8-1 downto i*8) <= MIN_NEG_BYTE;
                                else
                                    result((i+1)*8-1 downto i*8) <= byte_sums(i);
                                end if;
                            else  
                                -- Subtraction
                                -- Positive overflow
                                if (a((i+1)*8-1) = '0' and b((i+1)*8-1) = '1' and byte_sums(i)(7) = '1') then
                                    result((i+1)*8-1 downto i*8) <= MAX_POS_BYTE;
                                -- Negative overflow
                                elsif (a((i+1)*8-1) = '1' and b((i+1)*8-1) = '0' and byte_sums(i)(7) = '0') then
                                    result((i+1)*8-1 downto i*8) <= MIN_NEG_BYTE;
                                else
                                    result((i+1)*8-1 downto i*8) <= byte_sums(i);
                                end if;
                            end if;
                        end loop;

                    when "01" =>  
                        -- Word 
                        for i in 0 to 3 loop
                            if operation(2) = '0' then 
                                -- Addition
                                -- Positive overflow
                                if (a((i+1)*16-1) = '0' and b((i+1)*16-1) = '0' and byte_sums(i*2+1)(7) = '1') then
                                    result((i+1)*16-1 downto i*16) <= MAX_POS_WORD;
                                -- Negative overflow
                                elsif (a((i+1)*16-1) = '1' and b((i+1)*16-1) = '1' and byte_sums(i*2+1)(7) = '0') then
                                    result((i+1)*16-1 downto i*16) <= MIN_NEG_WORD;
                                else
                                    result((i+1)*16-1 downto i*16) <= byte_sums(i*2+1) & byte_sums(i*2);
                                end if;
                            else  
                                -- Subtraction
                                -- Positive overflow
                                if (a((i+1)*16-1) = '0' and b((i+1)*16-1) = '1' and byte_sums(i*2+1)(7) = '1') then
                                    result((i+1)*16-1 downto i*16) <= MAX_POS_WORD;
                                -- Negative overflow
                                elsif (a((i+1)*16-1) = '1' and b((i+1)*16-1) = '0' and byte_sums(i*2+1)(7) = '0') then
                                    result((i+1)*16-1 downto i*16) <= MIN_NEG_WORD;
                                else
                                    result((i+1)*16-1 downto i*16) <= byte_sums(i*2+1) & byte_sums(i*2);
                                end if;
                            end if;
                        end loop;

                    when others =>
                        result <= (others => '0');
                end case;

            -- Unsigned saturation 
            when "10" =>
                case operation(1 downto 0) is
                    when "00" =>  
                        -- Byte 
                        for i in 0 to 7 loop
                            if operation(2) = '0' then  
                                -- Addition
                                if byte_couts(i) = '1' then
                                    result((i+1)*8-1 downto i*8) <= MAX_UNSIGNED_BYTE;
                                else
                                    result((i+1)*8-1 downto i*8) <= byte_sums(i);
                                end if;
                            else  -- Subtraction
                                if (carry_inputs(i) = '0') or 
                                   (unsigned(a((i+1)*8-1 downto i*8)) < unsigned(b((i+1)*8-1 downto i*8))) then
                                    result((i+1)*8-1 downto i*8) <= (others => '0');
                                else
                                    result((i+1)*8-1 downto i*8) <= byte_sums(i);
                                end if;
                            end if;
                        end loop;

                    when "01" =>  
                        -- Word operations
                        for i in 0 to 3 loop
                            if operation(2) = '0' then  
                                -- Addition
                                if (byte_couts(i*2) = '1') or (byte_couts(i*2+1) = '1') then
                                    result((i+1)*16-1 downto i*16) <= MAX_UNSIGNED_WORD;
                                else
                                    result((i+1)*16-1 downto i*16) <= byte_sums(i*2+1) & byte_sums(i*2);
                                end if;
                            else  -- Subtraction
                                if (carry_inputs(i*2) = '0') or 
                                   (unsigned(a((i+1)*16-1 downto i*16)) < unsigned(b((i+1)*16-1 downto i*16))) then
                                    result((i+1)*16-1 downto i*16) <= (others => '0');
                                else
                                    result((i+1)*16-1 downto i*16) <= byte_sums(i*2+1) & byte_sums(i*2);
                                end if;
                            end if;
                        end loop;

                    when others =>
                        result <= (others => '0');
                end case;

            when others =>
                result <= (others => '0');
        end case;
    end process;

end Behavioral;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity padd_psub_wraparound is
    Port (
        a, b     : in  std_logic_vector(63 downto 0);
        operation: in  std_logic_vector(2 downto 0); 
        -- operation(2) = scãdere ('1') /adunare ('0')
        -- operation(1:0) = dimensiune operanzi (00=byte, 01=word, 10=dword)
        result   : out std_logic_vector(63 downto 0)
    );
end padd_psub_wraparound;


architecture Behavioral of padd_psub_wraparound is
    
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

    
    process(byte_sums, operation)
    begin
        case operation(1 downto 0) is
            when "00" =>  -- Byte 
                for i in 0 to 7 loop
                    result((i+1)*8-1 downto i*8) <= byte_sums(i);
                end loop;

            when "01" =>  -- Word 
                for i in 0 to 3 loop
                    result((i+1)*16-1 downto i*16) <= byte_sums(i*2+1) & byte_sums(i*2);
                end loop;

            when "10" =>  -- DWord 
                for i in 0 to 1 loop
                    result((i+1)*32-1 downto i*32) <= byte_sums(i*4+3) & byte_sums(i*4+2) & 
                                                     byte_sums(i*4+1) & byte_sums(i*4);
                end loop;

            when others =>
                result <= (others => '0');
        end case;
    end process;

end Behavioral;
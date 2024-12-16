library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity parallel_logical is
    Port (
        a, b : in std_logic_vector(63 downto 0);
        operation : in std_logic_vector(3 downto 0);  
        -- operation(3 downto 2) = operation type
        -- 00-AND 10-OR 01-XOR
        -- operation(1 downto 0) = size(00:byte, 01:word, 10:dword)
        result : out std_logic_vector(63 downto 0)
    );
end parallel_logical;


architecture Behavioral of parallel_logical is
    component logical_8bit is
        Port (
            a, b : in std_logic_vector(7 downto 0);
            op_type : in std_logic_vector(1 downto 0);
            result : out std_logic_vector(7 downto 0);
            result_valid : out std_logic
        );
    end component;

    type byte_array is array (0 to 7) of std_logic_vector(7 downto 0);
    signal byte_results : byte_array;
    signal valid_signals : std_logic_vector(7 downto 0);
    signal final_results : std_logic_vector(63 downto 0);
    
    signal byte_select : std_logic_vector(7 downto 0);
    signal word_select : std_logic_vector(3 downto 0);
    signal dword_select : std_logic_vector(1 downto 0);

begin
   
    gen_logic: for i in 0 to 7 generate
        logic_inst: logical_8bit port map (
            a => a((i+1)*8-1 downto i*8),
            b => b((i+1)*8-1 downto i*8),
            op_type => operation(3 downto 2),
            result => byte_results(i),
            result_valid => valid_signals(i)
        );
    end generate;
  
    process(operation, valid_signals)
    begin
        byte_select <= (others => '0');
        word_select <= (others => '0');
        dword_select <= (others => '0');
        
        case operation(1 downto 0) is
            when "00" =>  -- Byte 
                for i in 0 to 7 loop
                    byte_select(i) <= valid_signals(i);
                end loop;
                
            when "01" =>  -- Word
                for i in 0 to 3 loop
                    word_select(i) <= valid_signals(i*2) and valid_signals(i*2+1);
                end loop;
                
            when "10" =>  -- Dword 
                for i in 0 to 1 loop
                    dword_select(i) <= valid_signals(i*4) and valid_signals(i*4+1) and 
                                     valid_signals(i*4+2) and valid_signals(i*4+3);
                end loop;
                
            when others =>
                byte_select <= (others => '0');
                word_select <= (others => '0');
                dword_select <= (others => '0');
        end case;
    end process;

    process(byte_results, operation, byte_select, word_select, dword_select)
    begin
        final_results <= (others => '0');  
      
        case operation(1 downto 0) is
            when "00" =>  -- Byte 
                for i in 0 to 7 loop
                    if byte_select(i) = '1' then
                        final_results((i+1)*8-1 downto i*8) <= byte_results(i);
                    end if;
                end loop;

            when "01" =>  -- Word 
                for i in 0 to 3 loop
                    if word_select(i) = '1' then
                        final_results((i+1)*16-1 downto i*16) <= byte_results(i*2+1) & byte_results(i*2);
                    end if;
                end loop;

            when "10" =>  -- Dword 
                for i in 0 to 1 loop
                    if dword_select(i) = '1' then
                        final_results((i+1)*32-1 downto i*32) <= byte_results(i*4+3) & byte_results(i*4+2) & 
                                                                byte_results(i*4+1) & byte_results(i*4);
                    end if;
                end loop;

            when others =>
                final_results <= (others => '0');
        end case;
    end process;

    result <= final_results;
    
end Behavioral;
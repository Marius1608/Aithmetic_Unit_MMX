library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity parallel_compare_equality is
    Port (
        a, b : in std_logic_vector(63 downto 0);
        operation : in std_logic_vector(1 downto 0);  
        -- "00":PCMPEQB, "01":PCMPEQW, "10":PCMPEQD
        result : out std_logic_vector(63 downto 0)
    );
end parallel_compare_equality;


architecture Behavioral of parallel_compare_equality is
    component compare_8bit is
        Port (
            a, b : in std_logic_vector(7 downto 0);
            result : out std_logic_vector(7 downto 0)
        );
    end component;

    type byte_array is array (0 to 7) of std_logic_vector(7 downto 0);
    signal compare_results : byte_array;
    signal final_results : std_logic_vector(63 downto 0);

    signal byte_select : std_logic_vector(7 downto 0);
    signal word_select : std_logic_vector(3 downto 0);
    signal dword_select : std_logic_vector(1 downto 0);

begin
   
    gen_comp: for i in 0 to 7 generate
        inst_comp: compare_8bit port map (
            a => a((i+1)*8-1 downto i*8),
            b => b((i+1)*8-1 downto i*8),
            result => compare_results(i)
        );
    end generate;

   
    process(operation)
    begin
        
        byte_select <= (others => '0');
        word_select <= (others => '0');
        dword_select <= (others => '0');
        
        case operation is
            when "00" =>  -- PCMPEQB
                byte_select <= (others => '1');
                
            when "01" =>  -- PCMPEQW
                word_select <= (others => '1');
                
            when "10" =>  -- PCMPEQD
                dword_select <= (others => '1');
                
            when others =>
                byte_select <= (others => '0');
                word_select <= (others => '0');
                dword_select <= (others => '0');
        end case;
    end process;

    
    process(compare_results, operation, byte_select, word_select, dword_select)
        variable word_eq : std_logic;
        variable dword_eq : std_logic;
    begin
    
        final_results <= (others => '0'); 
        
        case operation is
            when "00" =>  -- PCMPEQB
                for i in 0 to 7 loop
                    if byte_select(i) = '1' then
                        final_results((i+1)*8-1 downto i*8) <= compare_results(i);
                    end if;
                end loop;

            when "01" =>  -- PCMPEQW
                for i in 0 to 3 loop
                    if word_select(i) = '1' then
                        if (compare_results(i*2) = x"FF" and compare_results(i*2+1) = x"FF") then
                            final_results((i+1)*16-1 downto i*16) <= (others => '1');
                        else
                            final_results((i+1)*16-1 downto i*16) <= (others => '0');
                        end if;
                    end if;
                end loop;

            when "10" =>  -- PCMPEQD
                for i in 0 to 1 loop
                    if dword_select(i) = '1' then
                        if (compare_results(i*4) = x"FF" and compare_results(i*4+1) = x"FF" and compare_results(i*4+2) = x"FF" and compare_results(i*4+3) = x"FF") then
                            final_results((i+1)*32-1 downto i*32) <= (others => '1');
                        else
                            final_results((i+1)*32-1 downto i*32) <= (others => '0');
                        end if;
                    end if;
                end loop;

            when others =>
                final_results <= (others => '0');
        end case;
    end process;

    result <= final_results;
    
end Behavioral;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity mmx_unit is
    Port (
        a, b     : in  std_logic_vector(63 downto 0);
        opcode   : in  std_logic_vector(6 downto 0);
        -- opcode(6:5) = operation type
        --   00: unified add/sub
        --   01: logical
        --   10: compare
        --   11: multiply
        -- For unified add/sub:
        --   opcode(4:3) = mode (00:wraparound, 01:signed sat, 10:unsigned sat)
        --   opcode(2) = subtract/add
        --   opcode(1:0) = size (00:byte, 01:word, 10:dword)
        -- For logical:
        --   opcode(3:2) = operation (00:AND, 10:OR, 01:XOR)
        --   opcode(1:0) = size
        -- For compare:
        --   opcode(1:0) = size
        -- For multiply:
        --   opcode(0) = operation (0:PMULLW, 1:PMULHW)
        result   : out std_logic_vector(63 downto 0)
    );
end mmx_unit;


architecture Behavioral of mmx_unit is
 
    component unified_padd_psub is
        Port (
            a, b     : in  std_logic_vector(63 downto 0);
            operation: in  std_logic_vector(4 downto 0);
            result   : out std_logic_vector(63 downto 0)
        );
    end component;
    
    component parallel_logical is
        Port (
            a, b       : in  std_logic_vector(63 downto 0);
            operation  : in  std_logic_vector(3 downto 0);
            result     : out std_logic_vector(63 downto 0)
        );
    end component;
    
    component parallel_compare_equality is
        Port (
            a, b       : in  std_logic_vector(63 downto 0);
            operation  : in  std_logic_vector(1 downto 0);
            result     : out std_logic_vector(63 downto 0)
        );
    end component;
    
    component pmul is
        Port (
            a, b     : in  std_logic_vector(63 downto 0);
            op       : in  std_logic;
            result   : out std_logic_vector(63 downto 0)
        );
    end component;

    signal unified_result    : std_logic_vector(63 downto 0);
    signal logical_result    : std_logic_vector(63 downto 0);
    signal compare_result    : std_logic_vector(63 downto 0);
    signal multiply_result   : std_logic_vector(63 downto 0);
    
begin
    
    unified_inst: unified_padd_psub port map (
        a => a,
        b => b,
        operation(4 downto 3) => opcode(4 downto 3),  
        operation(2) => opcode(2),                     
        operation(1 downto 0) => opcode(1 downto 0),   
        result => unified_result
    );
    
    logical_inst: parallel_logical port map (
        a => a,
        b => b,
        operation => opcode(3 downto 0),
        result => logical_result
    );
    
    compare_inst: parallel_compare_equality port map (
        a => a,
        b => b,
        operation => opcode(1 downto 0),
        result => compare_result
    );
    
    multiply_inst: pmul port map (
        a => a,
        b => b,
        op => opcode(0),
        result => multiply_result
    );
    
    process(opcode, unified_result, logical_result, compare_result, multiply_result)
    begin
        case opcode(6 downto 5) is
            when "00" =>   
                result <= unified_result;
            when "01" =>   
                result <= logical_result;
            when "10" =>  
                result <= compare_result;
            when "11" =>   
                result <= multiply_result;
            when others =>
                result <= (others => '0');
        end case;
    end process;

end Behavioral;
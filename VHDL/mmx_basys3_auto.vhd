library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mmx_basys3_auto is
    Port (
        clk     : in  STD_LOGIC;
        reset   : in  STD_LOGIC; 
        seg     : out STD_LOGIC_VECTOR(6 downto 0);
        an      : out STD_LOGIC_VECTOR(3 downto 0);
        dp      : out STD_LOGIC;
        led     : out STD_LOGIC_VECTOR(15 downto 0)
    );
end mmx_basys3_auto;

architecture Behavioral of mmx_basys3_auto is
    -- MMX Unit component
    component mmx_unit is
        Port (
            a, b     : in  std_logic_vector(63 downto 0);
            opcode   : in  std_logic_vector(6 downto 0);
            result   : out std_logic_vector(63 downto 0)
        );
    end component;

    type test_state_type is (
        INIT,
        EXECUTE,
        VERIFY,
        DISPLAY_RESULT,
        WAIT_STATE
    );
    signal test_state : test_state_type := INIT;
    
    -- Test case structure
    type test_case_type is record
        a       : std_logic_vector(63 downto 0);
        b       : std_logic_vector(63 downto 0);
        opcode  : std_logic_vector(6 downto 0);
        expected: std_logic_vector(63 downto 0);
    end record;
    
    type test_array is array (0 to 9) of test_case_type;
    constant TEST_CASES : test_array := (
    
        -- Test case 1: Byte addition (wraparound)
        0 => (
        a => x"0102030405060708",
        b => x"0807060504030201",
        opcode => "0000000",
        expected => x"0909090909090909"
        ),
        
        -- Test case 2: Word addition (wraparound)
        1 => (
            a => x"0001000200030004",
            b => x"0004000300020001",
            opcode => "0000001",
            expected => x"0005000500050005"
        ),
        
        -- Test case 3: Byte subtraction (signed saturation)
        2 => (
            a => x"7F7F7F7F7F7F7F7F",
            b => x"8080808080808080",
            opcode => "0001100",
            expected => x"7F7F7F7F7F7F7F7F"
        ),
        
        -- Test case 4: Word addition (unsigned saturation)
        3 => (
            a => x"FFFF000100020003",
            b => x"0001FFFF00030004",
            opcode => "0010001",
            expected => x"FFFFFFFF00050007"
        ),
        
        -- Test case 5: Byte AND
        4 => (
            a => x"FF00FF00FF00FF00",
            b => x"0F0F0F0F0F0F0F0F",
            opcode => "0100000",
            expected => x"0F000F000F000F00"
        ),
        
        -- Test case 6: Word OR
        5 => (
            a => x"F0F00000F0F00000",
            b => x"0F0F0F0F0F0F0F0F",
            opcode => "0101001",
            expected => x"FFFF0F0FFFFF0F0F"
        ),
        
        -- Test case 7: DWord XOR
        6 => (
            a => x"AAAAAAAAAAAAAAAA",
            b => x"5555555555555555",
            opcode => "0100110",
            expected => x"FFFFFFFFFFFFFFFF"
        ),
        
        -- Test case 8: Byte equality
        7 => (
            a => x"1122334455667788",
            b => x"1122334455667788",
            opcode => "1000000",
            expected => x"FFFFFFFFFFFFFFFF"
        ),
        
        -- Test case 9: Word equality (some equal)
        8 => (
            a => x"1122334455667788",
            b => x"1122334455667799",
            opcode => "1000001",
            expected => x"FFFFFFFFFFFF0000"
        ),
        
        -- Test case 10: PMULLW (positive * positive)
        9 => (
            a => x"0202020202020202",
            b => x"0303030303030303",
            opcode => "1100000",
            expected => x"0606060606060606"
        )
    );

    signal current_test  : integer range 0 to 9 := 0;
    signal reg_a        : std_logic_vector(63 downto 0);
    signal reg_b        : std_logic_vector(63 downto 0);
    signal reg_op       : std_logic_vector(6 downto 0);
    signal result       : std_logic_vector(63 downto 0);
    signal test_passed  : std_logic;
    
    signal display_value : std_logic_vector(15 downto 0);
    signal display_sel   : integer range 0 to 3 := 0;
    signal refresh_counter : integer range 0 to 100000 := 0;
    signal chunk_sel    : integer range 0 to 3 := 0;
    
    signal wait_counter : integer range 0 to 200000000 := 0;
    constant WAIT_TIME : integer := 200000000;  
    constant CHUNK_DISPLAY_TIME : integer := 50000000; 
    
    signal display_timer : integer range 0 to 50000000 := 0;
    
    function hex_to_7seg(hex: std_logic_vector(3 downto 0)) return std_logic_vector is
    begin
        case hex is
            when "0000" => return "1000000"; -- 0
            when "0001" => return "1111001"; -- 1
            when "0010" => return "0100100"; -- 2
            when "0011" => return "0110000"; -- 3
            when "0100" => return "0011001"; -- 4
            when "0101" => return "0010010"; -- 5
            when "0110" => return "0000010"; -- 6
            when "0111" => return "1111000"; -- 7
            when "1000" => return "0000000"; -- 8
            when "1001" => return "0010000"; -- 9
            when "1010" => return "0001000"; -- A
            when "1011" => return "0000011"; -- b
            when "1100" => return "1000110"; -- C
            when "1101" => return "0100001"; -- d
            when "1110" => return "0000110"; -- E
            when "1111" => return "0001110"; -- F
            when others => return "1111111";
        end case;
    end function;

begin
    -- Instantiate MMX Unit
    mmx_inst: mmx_unit port map (
        a => reg_a,
        b => reg_b,
        opcode => reg_op,
        result => result
    );

    -- Main test control process
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                test_state <= INIT;
                current_test <= 0;
                wait_counter <= 0;
                chunk_sel <= 0;
                test_passed <= '0';
                display_timer <= 0;
            else
                case test_state is
                    when INIT =>
                        
                        if wait_counter < 50000000 then  
                            wait_counter <= wait_counter + 1;
                        else
                            -- Load test case
                            reg_a <= TEST_CASES(current_test).a;
                            reg_b <= TEST_CASES(current_test).b;
                            reg_op <= TEST_CASES(current_test).opcode;
                            test_state <= EXECUTE;
                            wait_counter <= 0;
                        end if;
                        
                    when EXECUTE =>
                        if wait_counter < 1000000 then  
                            wait_counter <= wait_counter + 1;
                        else
                            test_state <= VERIFY;
                            wait_counter <= 0;
                        end if;
                        
                    when VERIFY =>
                        if result = TEST_CASES(current_test).expected then
                            test_passed <= '1';
                        else
                            test_passed <= '0';
                        end if;
                        test_state <= DISPLAY_RESULT;
                        wait_counter <= 0;
                        display_timer <= 0;
                        
                    when DISPLAY_RESULT =>
                        if wait_counter < WAIT_TIME then
                            wait_counter <= wait_counter + 1;
                            
                            if display_timer >= CHUNK_DISPLAY_TIME then
                                display_timer <= 0;
                                if chunk_sel = 3 then
                                    chunk_sel <= 0;
                                else
                                    chunk_sel <= chunk_sel + 1;
                                end if;
                            else
                                display_timer <= display_timer + 1;
                            end if;
                        else
                            test_state <= WAIT_STATE;
                            wait_counter <= 0;
                        end if;
                        
                    when WAIT_STATE =>
                        if wait_counter < 25000000 then  
                            wait_counter <= wait_counter + 1;
                        else
                            if current_test < 9 then
                                current_test <= current_test + 1;
                            else
                                current_test <= 0;
                            end if;
                            test_state <= INIT;
                            wait_counter <= 0;
                        end if;
                end case;
            end if;
        end if;
    end process;

    -- Display control process
    process(clk)
    begin
        if rising_edge(clk) then
           
            display_value <= result((chunk_sel * 16 + 15) downto (chunk_sel * 16));
            
            if refresh_counter = 99999 then
                refresh_counter <= 0;
                if display_sel = 3 then
                    display_sel <= 0;
                else
                    display_sel <= display_sel + 1;
                end if;
            else
                refresh_counter <= refresh_counter + 1;
            end if;
        end if;
    end process;

    -- 7-segment display output
    process(display_sel, display_value)
    begin
        case display_sel is
            when 0 =>
                seg <= hex_to_7seg(display_value(3 downto 0));
                an <= "1110";
            when 1 =>
                seg <= hex_to_7seg(display_value(7 downto 4));
                an <= "1101";
            when 2 =>
                seg <= hex_to_7seg(display_value(11 downto 8));
                an <= "1011";
            when 3 =>
                seg <= hex_to_7seg(display_value(15 downto 12));
                an <= "0111";
        end case;
    end process;

    -- LED output for status
    -- LED(15) shows test pass/fail
    -- LED(14 downto 12) shows current test number
    -- LED(11 downto 8) shows current chunk being displayed
    -- LED(7 downto 0) shows lower byte of current result chunk
    led <= test_passed & std_logic_vector(to_unsigned(current_test, 3)) &
           std_logic_vector(to_unsigned(chunk_sel, 4)) & 
           display_value(7 downto 0);

    -- Decimal point control
    dp <= '0' when test_state = DISPLAY_RESULT else '1';

end Behavioral;
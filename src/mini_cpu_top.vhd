library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mini_cpu_top is
    Port (
        clk_fpga  : in  STD_LOGIC;
        btn_reset : in  STD_LOGIC;
        led_data  : out STD_LOGIC_VECTOR(7 downto 0);
        led_pc    : out STD_LOGIC_VECTOR(3 downto 0)
    );
end mini_cpu_top;

architecture Structural of mini_cpu_top is

    ---signal clk_div_count : integer range 0 to 50 := 0;
    ---signal clk_slow      : std_logic := '0';
	 
    signal pc    : std_logic_vector(3 downto 0) := "0000";
    signal reg_a : std_logic_vector(7 downto 0) := (others => '0');
    --signal instr : std_logic_vector(7 downto 0);
    signal instr : std_logic_vector(7 downto 0) := (others => '0'); -- ADD THIS
    signal s_pc_inc    : std_logic;
    signal s_pc_load   : std_logic;
    signal s_reg_write : std_logic;
    signal s_alu_sel   : std_logic_vector(1 downto 0);
	 signal s_fetch     : std_logic;          -- NEW: FETCH strobe from CU


    type rom_array is array (0 to 15) of std_logic_vector(7 downto 0);
    constant ROM : rom_array := (
        0 => "00010101", -- LOAD 5
        1 => "00100011", -- ADD 3
        2 => "00110010", -- SUB 2
        3 => "01000001", -- JUMP 1
        others => "00000000"
    );

begin

    --instr    <= ROM(to_integer(unsigned(pc)));
    led_pc   <= pc;
    led_data <= reg_a;


    -- CONTROL UNIT
    CPU_BRAIN: entity work.control_unit
        port map (
            clk       => clk_fpga,
            reset     => btn_reset,
				opcode    => instr(7 downto 4),
            pc_inc    => s_pc_inc,
            pc_load   => s_pc_load,
            reg_write => s_reg_write,
            alu_sel   => s_alu_sel,
				do_fetch     => s_fetch             -- NEW port
        );

    process(clk_fpga, btn_reset)
    begin
         if btn_reset = '0' then
                pc    <= "0000";
                reg_a <= (others => '0');	 
					 instr <= (others => '0');
					  
         elsif rising_edge(clk_fpga) then				-- EXECUTE
       
           -- FETCH state: latch instruction from ROM
             if s_fetch = '1' then
                 instr <= ROM(to_integer(unsigned(pc)));
             end if;
            --instr_r <= instr;
				
        		 if s_reg_write = '1' then
                   case s_alu_sel is

                        when "00" => -- LOAD
                            reg_a <= std_logic_vector(resize(unsigned(instr(3 downto 0)), 8));

                        when "01" => -- ADD
                            reg_a <= std_logic_vector(unsigned(reg_a) + resize(unsigned(instr(3 downto 0)), 8));

                        when "10" => -- SUB
                            reg_a <= std_logic_vector(unsigned(reg_a) - resize(unsigned(instr(3 downto 0)), 8));

                        when others =>
                            null;
                    end case;
                end if;

                -- PC UPDATE (CRITICAL FOR LOOP)
                if s_pc_load = '1' then
                    pc <= std_logic_vector(resize(unsigned(instr(3 downto 0)), 4));

                elsif s_pc_inc = '1' then
                    pc <= std_logic_vector(unsigned(pc) + 1);
                end if;

        end if;
    end process;

end Structural;
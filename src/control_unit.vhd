library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control_unit is
    Port(
        clk       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        opcode    : in  STD_LOGIC_VECTOR(3 downto 0);
        pc_inc    : out STD_LOGIC;
        pc_load   : out STD_LOGIC;
        reg_write : out STD_LOGIC;
        alu_sel   : out STD_LOGIC_VECTOR(1 downto 0);
        do_fetch     : out STD_LOGIC             -- NEW
    );
end control_unit;

architecture Behavioral of control_unit is
    type state_type is (ST_FETCH, ST_DECODE, ST_EXECUTE, ST_WRITEBACK);
    signal state : state_type := ST_FETCH;
begin

    -- Clocked: state transitions only
    process(clk, reset)
    begin
        if reset = '0' then
            state <= ST_FETCH;
        elsif rising_edge(clk) then
            case state is
                when ST_FETCH     => state <= ST_DECODE;
                when ST_DECODE    => state <= ST_EXECUTE;
                when ST_EXECUTE   => state <= ST_WRITEBACK;
                when ST_WRITEBACK => state <= ST_FETCH;
            end case;
        end if;
    end process;

    -- Combinatorial: outputs from current state
    process(state, opcode)
    begin
        pc_inc    <= '0';
        pc_load   <= '0';
        reg_write <= '0';
        alu_sel   <= "00";
        do_fetch     <= '0';

        case state is
            when ST_FETCH =>
                do_fetch <= '1';        -- latch ROM into instr register

            when ST_DECODE =>
                null;                -- decode happens combinatorially

            when ST_EXECUTE =>
                case opcode is
                    when "0001" =>   -- LOAD
                        alu_sel   <= "00";
                        reg_write <= '1';
                        pc_inc    <= '1';
                    when "0010" =>   -- ADD
	                        alu_sel   <= "01";
                        reg_write <= '1';
                        pc_inc    <= '1';
                    when "0011" =>   -- SUB
                        alu_sel   <= "10";
                        reg_write <= '1';
                        pc_inc    <= '1';
                    when "0100" =>   -- JUMP
                        pc_load   <= '1';
                    when others =>
                        pc_inc    <= '1';		
                end case;

            when ST_WRITEBACK =>
                null;
        end case;
    end process;

end Behavioral;
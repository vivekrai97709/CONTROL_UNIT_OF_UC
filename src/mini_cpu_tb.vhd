library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mini_cpu_tb is
end mini_cpu_tb;

architecture Behavioral of mini_cpu_tb is

    component mini_cpu_top 
        Port (
            clk_fpga  : in  STD_LOGIC;
            btn_reset : in  STD_LOGIC;
            led_data  : out STD_LOGIC_VECTOR(7 downto 0);
            led_pc    : out STD_LOGIC_VECTOR(3 downto 0)
        ); 
    end component;
	 
    signal clk   : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '1'; -- start HIGH
    signal data  : STD_LOGIC_VECTOR(7 downto 0);
    signal pc    : STD_LOGIC_VECTOR(3 downto 0);

    ---constant CLK_PERIOD : time := 10 ns;

begin

    uut: mini_cpu_top
        port map (
            clk_fpga  => clk,
            btn_reset => reset,
            led_data  => data,
            led_pc    => pc
        );

    clk <= not clk after 5 ns;

    -- RESET
    stim_proc: process
    begin
        reset <= '0';   -- APPLY RESET
        wait for 100 ns;

        reset <= '1';   -- RELEASE RESET

        wait for 10000 ns;
        wait;
    end process;

end Behavioral;
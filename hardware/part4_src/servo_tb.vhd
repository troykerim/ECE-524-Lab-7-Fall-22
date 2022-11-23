--Servo TB
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity servo_tb is
--  Port ( );
end servo_tb;

architecture Behavioral of servo_tb is

component servo is
    generic(
    clk_hz : real;
    pulse_hz : real;
    min_pulse_us : real;
    max_pulse_us : real;
    step_count : positive
    );
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           position : in integer range 0 to step_count - 1;
           pwm : out STD_LOGIC);
end component;

signal clk_hz_tb : real;
signal pulse_hz_tb : real;
signal min_pulse_us_tb : real;
signal max_pulse_us_tb : real;
signal step_count_tb : positive; 

constant CP: time := 10 ns;
signal clk_tb, rst_tb, pwm_tb : std_logic;
signal position_tb : integer range 0 to step_count-1;

begin

    process
    begin
    clk_tb <= '1';
    wait for CP/2;
    clk_tb <= '0';
    wait for CP/2;
    end process;
    
    rst_tb <= '0', '1' after 20 ns, '0' after 40 ns;
    
    --Process block for testing the Servo
--    process
--    begin
--    end process;


end Behavioral;

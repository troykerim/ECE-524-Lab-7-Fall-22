--Part 4

--NO XDC file needed
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ROUND;

entity servo is
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
end servo;

architecture Behavioral of servo is
    component pwm_enhanced_part4 is
    generic(
           R: integer := 8
            );
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           dvsr : in STD_LOGIC_VECTOR(31 downto 0);
           duty : in STD_LOGIC_VECTOR (R downto 0);
           pwm_out : out STD_LOGIC);
    end component;


function cycles_per_us (us_count : real) return integer is
begin
 return integer(round(clk_hz / 1.0e6 * us_count));
end function;

constant min_count : integer := cycles_per_us(min_pulse_us);
constant max_count : integer := cycles_per_us(max_pulse_us);
constant min_max_range_us : real := max_pulse_us - min_pulse_us;
constant step_us : real := min_max_range_us / real(step_count - 1);
constant cycles_per_step : positive := cycles_per_us(step_us);
constant counter_max : integer := integer(round(clk_hz / pulse_hz)) - 1;
signal counter : integer range 0 to counter_max;
signal duty_cycle : integer range 0 to max_count;

begin


--
-- Port mapping for pwm
--
--pwm1: pwm_enhanced_part4 generic map (R => resolution)
--                   port map( clk => clk,
--                             rst => rst,
--                             dvsr => dvsr,
--                             duty => duty, --std_logic_vector(to_unsigned(13, resolution+1)),
--                             pwm_out => pwm_reg1);

COUNTER_PROC : process(clk)
begin
 if rising_edge(clk) then
   if rst = '1' then
     counter <= 0;

   else
     if counter < counter_max then
       counter <= counter + 1;
     else
       counter <= 0;
     end if;

   end if;
 end if;
end process;
PWM_PROC : process(clk)
begin
 if rising_edge(clk) then
   if rst = '1' then
     pwm <= '0';

   else
     pwm <= '0';

     if counter < duty_cycle then
       pwm <= '1';
     end if;

   end if;
 end if;
end process;
DUTY_CYCLE_PROC : process(clk)
begin
 if rising_edge(clk) then
   if rst = '1' then
     duty_cycle <= min_count;

   else
     duty_cycle <= position * cycles_per_step + min_count;

   end if;
 end if;
end process;

end Behavioral;

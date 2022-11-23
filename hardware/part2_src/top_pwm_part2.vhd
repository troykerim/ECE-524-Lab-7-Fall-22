--part 2 Sine Wave
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity top_pwm_part2 is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           rgb : out STD_LOGIC_VECTOR (2 downto 0);
           sw : in STD_LOGIC_VECTOR (3 downto 0));
end top_pwm_part2;

architecture Behavioral of top_pwm_part2 is

    component pwm_enhanced_part2 is
    generic(
           R: integer := 8
            );
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           dvsr : in STD_LOGIC_VECTOR(31 downto 0);
           duty : in STD_LOGIC_VECTOR (R downto 0);
           pwm_out : out STD_LOGIC);
    end component;
    
    constant resolution : integer := 8;
    constant dvsr: std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(4882, 32));
    
--    signal pwm_reg1 : std_logic;
--    signal pwm_reg2 : std_logic; modifying for part 2
--    signal pwm_reg3 : std_logic;
    
    signal counter : integer;
--    signal clk_200Hz: std_logic; --we want to toggle this
--    constant clk_200Hz_half_period: integer := 312499; --125_000_000 / (200*2) since we have 50% duty cycle
    --Change to 625_000
    signal clk_50Hz: std_logic;
    constant clk_50Hz_half_cp : integer := 125000000;
    
------------------------------------------------------------------------
    
    --Added for part 2
    signal addr: unsigned(resolution-1 downto 0);
    subtype addr_range is integer range 0 to 2**resolution-1;
    type rom_type is array(addr_range) of unsigned(resolution-1 downto 0);
    
    function init_rom return rom_type is
        variable rom_v : rom_type;
        variable angle : real;
        variable sin_scaled : real;
    begin 
        for i in addr_range loop
            angle := real(i)*((2.0*MATH_PI)/2.0**resolution);
            sin_scaled := (1.0 + sin(angle) * (2.0**resolution-1.0)/2.0);
            rom_v(i) := to_unsigned(integer(round(sin_scaled)), resolution);
        end loop;
        return rom_v;
    end init_rom;
    
    constant rom: rom_type := init_rom; 
    --synthesis tool will use function to calc all sine values based on resoultion we provided
    signal sin_data: unsigned(resolution-1 downto 0);
    
    signal duty_linear: std_logic_vector(resolution downto 0);
    signal duty_sin: std_logic_vector(resolution downto 0);
    
    signal pwm_linear_reg : std_logic;
    signal pwm_sin_reg : std_logic;
    signal pwm_reg3 : std_logic;
    

begin

    pwm1: pwm_enhanced_part2 generic map (R => resolution)
                           port map( clk => clk,
                                     rst => rst,
                                     dvsr => dvsr,
                                     duty => duty_linear,
                                     pwm_out => pwm_linear_reg);
                                     
    pwm2: pwm_enhanced_part2 generic map (R => resolution)
                           port map( clk => clk,
                                     rst => rst,
                                     dvsr => dvsr,
                                     duty => duty_sin,
                                     pwm_out => pwm_sin_reg);
    process(clk, rst) -- counter and clk
    begin
        if rst = '1' then
            counter <= 0;
            clk_50Hz <= '0';
        elsif rising_edge(clk) then
            if counter < clk_50Hz_half_cp-1 then
                counter <= counter + 1;
            else 
                counter <= 0;
                clk_50Hz <= NOT clk_50Hz;
            end if;
        end if;
        end process;

    --Part 2
    process(clk_50Hz, rst)
    begin 
        if rst = '1' then
            duty_linear <= (others => '0');
        elsif rising_edge(clk_50hz) then
            if unsigned(duty_linear) <= 2**resolution then
                duty_linear <= std_logic_vector(unsigned(duty_linear) + 1);
            else
                duty_linear <= (others => '0');
            end if;   
        end if;
    end process;
    
    process(clk_50Hz, rst)
    begin 
        if rst = '1' then
            duty_sin <= (others => '0');
        elsif rising_edge(clk_50hz) then
            if unsigned(duty_sin) <= 2**resolution then
                addr <= unsigned(addr) + 1;
                sin_data <= rom(to_integer(addr));
                duty_sin <= '0' & std_logic_vector(unsigned(sin_data));
            else
                duty_sin <= (others => '0');
            end if;   
        end if;
    end process;
    
    rgb(0) <= pwm_linear_reg  when sw = "0000" else
              pwm_sin_reg when sw = "0001";
    rgb(1) <= '0';
    rgb(2) <= '0';
end Behavioral;

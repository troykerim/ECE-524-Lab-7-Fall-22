--Part 3 Rainbow effect

--This part, all the rgbs from rgb(0) to rgb(2) we modify
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity top_pwm_part3 is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           rgb : out STD_LOGIC_VECTOR (2 downto 0);
           sw : in STD_LOGIC_VECTOR (3 downto 0));
end top_pwm_part3;

architecture Behavioral of top_pwm_part3 is

    component pwm_enhanced_part3 is
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
    
    signal counter : integer;
    signal clk_50Hz: std_logic;
    constant clk_50Hz_half_cp : integer := 125000000;
-------------------------------------------------------------------    
    --From part 2 originally
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
-------------------------------------------------------------------------
    --part 3
    signal rainbow_cntr: unsigned(10 downto 0); --rainbow counter
    signal duty_rainbow: std_logic_vector(resolution downto 0);
    signal red_reg: std_logic;
    signal green_reg: std_logic;
    signal blue_reg: std_logic;
    --signal duty_rainbow: unsigned(10 downto 0);
begin
    --from part2 renamed to part3
    pwm1: pwm_enhanced_part3 generic map (R => resolution)
                           port map( clk => clk,
                                     rst => rst,
                                     dvsr => dvsr,
                                     duty => duty_linear,
                                     pwm_out => pwm_linear_reg);
                                     
    pwm2: pwm_enhanced_part3 generic map (R => resolution)
                           port map( clk => clk,
                                     rst => rst,
                                     dvsr => dvsr,
                                     duty => duty_sin,
                                     pwm_out => pwm_sin_reg);
    --Part3 
    pwm3: pwm_enhanced_part3 generic map (R => resolution)
                           port map( clk => clk,
                                     rst => rst,
                                     dvsr => dvsr,
                                     duty => duty_rainbow,  --updated for part3
                                     pwm_out => pwm_reg3);  --updated for part3
                                     
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
--------------------------------------------------------------------------    
    --part 3 
    process(clk_50Hz, rst)
    begin
        if rst = '1' then
            rainbow_cntr <= (others => '0');   
        elsif rising_edge(clk_50Hz) then 
            if rainbow_cntr <= 255*6 then
                rainbow_cntr <= rainbow_cntr + 1;
            else
                rainbow_cntr <= (others => '0');
            end if;
        end if;
    end process;
    
    process(clk_50Hz, rst)
    begin
        if rst = '1' then
            duty_rainbow <= (others => '0');
        elsif rising_edge(clk_50Hz) then
            if rainbow_cntr(10 downto 8) = 0 then --upper 3 bits
                red_reg <= '1';
                green_reg <= pwm_reg3;
                blue_reg <= '0';
                duty_rainbow <= '0' & std_logic_vector(rainbow_cntr(7 downto 0));
            elsif rainbow_cntr(10 downto 8) = 1 then
                red_reg <= pwm_reg3;
                green_reg <= '1';
                blue_reg <= '0';
                duty_rainbow <= '0' & (NOT std_logic_vector(rainbow_cntr(7 downto 0)));
            elsif rainbow_cntr(10 downto 8) = 2 then
                red_reg <= '0';
                green_reg <= '1';
                blue_reg <= pwm_reg3;
                duty_rainbow <= '0' & std_logic_vector(rainbow_cntr(7 downto 0));
            elsif rainbow_cntr(10 downto 8) = 3 then
                red_reg <= '0';
                green_reg <= pwm_reg3;
                blue_reg <= '1';
                duty_rainbow <= '0' & (NOT std_logic_vector(rainbow_cntr(7 downto 0)));               
            elsif rainbow_cntr(10 downto 8) = 4 then
                red_reg <= pwm_reg3;
                green_reg <= '0';
                blue_reg <= '1';
                duty_rainbow <= '0' & std_logic_vector(rainbow_cntr(7 downto 0));
            elsif rainbow_cntr(10 downto 8) = 5 then
                red_reg <= '1';
                green_reg <= '0';
                blue_reg <= pwm_reg3;
                duty_rainbow <= '0' & (NOT std_logic_vector(rainbow_cntr(7 downto 0)));  
            else
                red_reg <= '0';
                green_reg <= '0';
                blue_reg <= '0';
            end if;
        end if;
    end process;
    
    rgb(0) <= red_reg;
    rgb(1) <= green_reg;
    rgb(2) <= blue_reg;


end Behavioral;

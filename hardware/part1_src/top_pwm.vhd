--Part 1
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity top_pwm is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           rgb : out STD_LOGIC_VECTOR (2 downto 0);
           sw : in STD_LOGIC_VECTOR (3 downto 0));
end top_pwm;

architecture Behavioral of top_pwm is

component pwm_enhanced is
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
    
    signal pwm_reg1 : std_logic;
    signal pwm_reg2 : std_logic;
    signal pwm_reg3 : std_logic;
    
    signal counter : integer;
    signal clk_200Hz: std_logic; --we want to toggle this
    constant clk_200Hz_half_period: integer := 1250000; --125_000_000 / (200*2) since we have 50% duty cycle
    --Change to 625_000
    signal duty: std_logic_vector(resolution downto 0);
   
begin

process(clk, rst) -- counter and clk
begin
    if rst = '1' then
        counter <= 0;
        clk_200Hz <= '0';
    elsif rising_edge(clk) then
        if counter < clk_200Hz_half_period-1 then
            counter <= counter + 1;
        else 
            counter <= 0;
            clk_200Hz <= NOT clk_200Hz;
        end if;
    end if;
end process;

pwm1: pwm_enhanced generic map (R => resolution)
                   port map( clk => clk,
                             rst => rst,
                             dvsr => dvsr,
                             duty => duty, --std_logic_vector(to_unsigned(13, resolution+1)),
                             pwm_out => pwm_reg1);
                             
--pwm2: pwm_enhanced generic map (R => resolution)
--                   port map( clk => clk,
--                             rst => rst,
--                             dvsr => dvsr,
--                             duty => std_logic_vector(to_unsigned(64, resolution+1)),
--                             pwm_out => pwm_reg2);
                             
--pwm3: pwm_enhanced generic map (R => resolution)
--                   port map( clk => clk,
--                             rst => rst,
--                             dvsr => dvsr,
--                             duty => std_logic_vector(to_unsigned(128, resolution+1)),
--                             pwm_out => pwm_reg3);
                             
    process(clk_200Hz, rst)
    begin 
        if rst = '1' then
            duty <= (others => '0');
        elsif rising_edge(clk) then
            duty <= std_logic_vector(unsigned(duty) + 1);            
        end if;
    end process;

    rgb(0) <= pwm_reg1;
-- rgb(0) <= pwm_reg1 when sw = "0000";
--              pwm_reg2 when sw = "0001" else
--              pwm_reg3 when sw = "0010";
    rgb(1) <= '0';
    rgb(2) <= '0';

end Behavioral;

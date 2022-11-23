--Part 1 
--DO NOT USE THIS 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity pwd_basic is
    generic(
        R: integer := 8 --parameterize the duty
    );
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           duty : in STD_LOGIC_VECTOR (R-1 downto 0);
           pwm_out : out STD_LOGIC);
end pwd_basic;

architecture Behavioral of pwd_basic is

    signal d_reg: unsigned(R-1 downto 0);
    signal d_next: unsigned(R-1 downto 0);
    
    signal pwm_reg: std_logic; --connects to outside
    signal pwm_next: std_logic;--wire to go from counter to pwm_reg
    
begin
    process(clk, rst)
    begin 
        if rst = '1' then --Async rst
            d_reg <= (others => '0'); -- reset our registers
            pwm_reg <= '0'; 
        elsif rising_edge(clk) then
            d_reg <= d_next;
            pwm_reg <= pwm_next;
        end if;
    end process;
    
    --duty cycle counter
    d_next <= d_reg + 1;
    pwm_next <= '1' when d_reg < unsigned(duty) else '0';
    pwm_out <= pwm_reg;
    

end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pwm_enhanced_part3 is
    generic(
           R: integer := 8
    );
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           dvsr : in STD_LOGIC_VECTOR(31 downto 0);
           duty : in STD_LOGIC_VECTOR (R downto 0);
           pwm_out : out STD_LOGIC);
end pwm_enhanced_part3;

architecture Behavioral of pwm_enhanced_part3 is
    signal q_reg: unsigned(31 downto 0);
    signal q_next: unsigned(31 downto 0);
    signal d_reg: unsigned(R-1 downto 0);
    signal d_next: unsigned(R-1 downto 0);
    signal d_ext: unsigned(R downto 0);
    signal pwm_reg: std_logic;
    signal pwm_next: std_logic;
    signal tick : std_logic;
begin
    process(clk,rst)
    begin
        if rst = '1' then
            q_reg <= (others => '0');
            d_reg <= (others => '0');
            pwm_reg <= '0';
        elsif rising_edge(clk) then
            q_reg <= q_next;
            d_reg <= d_next;
            pwm_reg <= pwm_next;
        end if;
    end process;
    
    --prescaler counter
    q_next <= (others => '0') when q_reg = unsigned(dvsr) else q_reg + 1;
    tick <= '1' when q_reg = 0 else '0';
    
    --duty cycle counter
    d_next <= d_reg + 1 when tick = '1' else d_reg;
    d_ext <= '0' & d_reg; --Handles extra bit
    pwm_next <= '1' when d_ext < unsigned(duty) else '0'; --RHS comparator
    pwm_out <= pwm_reg;

end Behavioral;

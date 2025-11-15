library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity neuron is
    generic (
        WIDTH : positive := 16;
        N_INPUTS : positive := 4
    );
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        enable  : in  std_logic;
        inputs  : in  std_logic_vector(N_INPUTS*WIDTH-1 downto 0);
        weights : in  std_logic_vector(N_INPUTS*WIDTH-1 downto 0);
        bias    : in  std_logic_vector(WIDTH-1 downto 0);
        output  : out std_logic_vector(WIDTH-1 downto 0)
    );
end neuron;

architecture rtl of neuron is
    signal acc : signed(WIDTH+8 downto 0) := (others => '0');  -- extra bits for sum
begin
    process(clk)
        variable sum : signed(WIDTH+8 downto 0);
    begin
        if rising_edge(clk) then
            if rst = '1' then
                acc <= (others => '0');
            elsif enable = '1' then
                sum := signed(bias);
                for i in 0 to N_INPUTS-1 loop
                    sum := sum + signed(inputs((i+1)*WIDTH-1 downto i*WIDTH)) *
                                 signed(weights((i+1)*WIDTH-1 downto i*WIDTH));
                end loop;
                -- ReLU
                if sum < 0 then
                    acc <= (others => '0');
                else
                    acc <= sum;
                end if;
            end if;
        end if;
    end process;

    output <= std_logic_vector(acc(WIDTH+7 downto 8));  -- Q8.8 back to 16-bit
end rtl;

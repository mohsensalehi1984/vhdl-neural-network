library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity layer is
    generic (
        WIDTH      : positive := 16;
        N_INPUTS   : positive := 4;
        N_NEURONS  : positive := 3
    );
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        enable  : in  std_logic;
        inputs  : in  std_logic_vector(N_INPUTS*WIDTH-1 downto 0);
        weights : in  std_logic_vector(N_NEURONS*N_INPUTS*WIDTH-1 downto 0);
        biases  : in  std_logic_vector(N_NEURONS*WIDTH-1 downto 0);
        outputs : out std_logic_vector(N_NEURONS*WIDTH-1 downto 0)
    );
end layer;

architecture struct of layer is
    component neuron
        generic (WIDTH : positive; N_INPUTS : positive);
        port (
            clk, rst, enable : in  std_logic;
            inputs, weights  : in  std_logic_vector;
            bias             : in  std_logic_vector;
            output           : out std_logic_vector
        );
    end component;
begin
    GEN_NEURONS: for i in 0 to N_NEURONS-1 generate
        U: neuron
            generic map (WIDTH => WIDTH, N_INPUTS => N_INPUTS)
            port map (
                clk     => clk,
                rst     => rst,
                enable  => enable,
                inputs  => inputs,
                weights => weights((i+1)*N_INPUTS*WIDTH-1 downto i*N_INPUTS*WIDTH),
                bias    => biases((i+1)*WIDTH-1 downto i*WIDTH),
                output  => outputs((i+1)*WIDTH-1 downto i*WIDTH)
            );
    end generate;
end struct;

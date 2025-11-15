library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity network is
    generic (
        WIDTH      : positive := 16;
        I_SIZE     : positive := 4;
        H1_SIZE    : positive := 8;
        H2_SIZE    : positive := 8;
        O_SIZE     : positive := 2
    );
    port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        enable     : in  std_logic;
        input_vec  : in  std_logic_vector(I_SIZE*WIDTH-1 downto 0);
        output_vec : out std_logic_vector(O_SIZE*WIDTH-1 downto 0)
    );
end network;

architecture struct of network is
    component layer
        generic (WIDTH, N_INPUTS, N_NEURONS : positive);
        port (clk, rst, enable : in std_logic;
              inputs, weights, biases : in std_logic_vector;
              outputs : out std_logic_vector);
    end component;

    signal h1_out, h2_out : std_logic_vector(H1_SIZE*WIDTH-1 downto 0);
    -- Weight ROMs (loaded from file in TB)
    signal w1, w2, w3 : std_logic_vector(0 downto 0)(WIDTH-1 downto 0);
    -- Bias ROMs
    signal b1, b2, b3 : std_logic_vector(0 downto 0)(WIDTH-1 downto 0);

begin
    -- Layer 1
    L1: layer generic map (WIDTH=>WIDTH, N_INPUTS=>I_SIZE,  N_NEURONS=>H1_SIZE)
              port map (clk,rst,enable, input_vec, w1, b1, h1_out);

    -- Layer 2
    L2: layer generic map (WIDTH=>WIDTH, N_INPUTS=>H1_SIZE, N_NEURONS=>H2_SIZE)
              port map (clk,rst,enable, h1_out, w2, b2, h2_out);

    -- Output layer (no activation)
    L3: layer generic map (WIDTH=>WIDTH, N_INPUTS=>H2_SIZE, N_NEURONS=>O_SIZE)
              port map (clk,rst,enable, h2_out, w3, b3, output_vec);
end struct;

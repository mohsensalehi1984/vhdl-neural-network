library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity tb_network is
end tb_network;

architecture sim of tb_network is
    constant WIDTH : positive := 16;
    constant CLK_PERIOD : time := 10 ns;

    signal clk, rst, enable : std_logic := '0';
    signal input_vec : std_logic_vector(4*WIDTH-1 downto 0);
    signal output_vec : std_logic_vector(2*WIDTH-1 downto 0);

    -- Load weights from hex file
    type rom_type is array(0 to 1023) of std_logic_vector(WIDTH-1 downto 0);
    impure function init_rom return rom_type is
        file f : text open read_mode is "../../weights/weights.hex";
        variable l : line;
        variable val : std_logic_vector(WIDTH-1 downto 0);
        variable rom : rom_type := (others => (others => '0'));
        variable idx : natural := 0;
    begin
        while not endfile(f) and idx < rom'length loop
            readline(f, l);
            hread(l, val);
            rom(idx) := val;
            idx := idx + 1;
        end loop;
        return rom;
    end function;

    signal weights_rom : rom_type := init_rom;

begin
    DUT: entity work.network
        generic map (WIDTH=>WIDTH, I_SIZE=>4, H1_SIZE=>8, H2_SIZE=>8, O_SIZE=>2)
        port map (clk=>clk, rst=>rst, enable=>enable,
                  input_vec=>input_vec, output_vec=>output_vec);

    clk <= not clk after CLK_PERIOD/2;

    process
    begin
        rst <= '1'; enable <= '0';
        wait for 20 ns;
        rst <= '0';

        -- Test vector [1.0, 0.5, 0.0, 0.0] in Q8.8
        input_vec <= x"0100" & x"0080" & x"0000" & x"0000";
        enable <= '1';
        wait for CLK_PERIOD;
        enable <= '0';
        wait for 100 ns;

        report "Output: " & integer'image(to_integer(signed(output_vec(31 downto 16)))) &
               ", " & integer'image(to_integer(signed(output_vec(15 downto 0))));
        wait;
    end process;
end sim;

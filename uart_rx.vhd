-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author(s): Martin Knotek (xknotem00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



-- Entity declaration (DO NOT ALTER THIS PART!)
entity UART_RX is
    port(
        CLK      : in std_logic;
        RST      : in std_logic;
        DIN      : in std_logic;
        DOUT     : out std_logic_vector(7 downto 0);
        DOUT_VLD : out std_logic
    );
end entity;



-- Architecture implementation (INSERT YOUR IMPLEMENTATION HERE)
architecture behavioral of UART_RX is

    -- DIN SYNC
    signal din_q1 : std_logic;
    signal din_sync : std_logic;
    -- Counter signals
    signal mid : std_logic;
    signal stop_bit : std_logic;
    -- Control signals
    -- Mealy
    signal save : std_logic;
    -- Moore
    signal cnt_ce : std_logic;
    signal d_cnt_res : std_logic;

    -- Inner signals
    signal clk_count : std_logic_vector(3 downto 0);
    signal data_count : std_logic_vector(2 downto 0);
    signal shift_register : std_logic_vector(7 downto 0);

begin
    -- Instance of RX FSM
    fsm: entity work.UART_RX_FSM
    port map (
        CLK => CLK,
        RST => RST,
        
        DIN => din_sync,
        MID => mid,
        STOP_BIT => stop_bit,
        
        -- Mealy
        SAVE => save,
        DOUT_VLD => DOUT_VLD,
        -- Moore
        CNT_CE => cnt_ce,
        D_CNT_RES => d_cnt_res
    );


    sync_flip_flops: process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                din_q1 <= '0';
                din_sync <= '0';
            else
                din_q1 <= DIN;
                din_sync <= din_q1;
            end if;
        end if;
    end process;


    clock_counter: process(CLK)
    begin
        if rising_edge(CLK) then
            if (RST = '1' or cnt_ce = '0') then
                clk_count <= "0000";
            elsif cnt_ce = '1' then
                clk_count <= clk_count + 1;
            end if;
        end if;
    end process;
        
    mid <= '1' when clk_count = "0111" else '0';


    data_counter: process(CLK)
    begin
        if rising_edge(CLK) then
            if d_cnt_res = '1' then
                data_count <= "000";
            elsif save = '1' then
                data_count <= data_count + 1;
            end if;
        end if;
    end process;

    stop_bit <= '1' when data_count = "111" else '0';


    shift_register_process: process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                shift_register <= "00000000";
            elsif save = '1' then
                shift_register <= din_sync & shift_register(7 downto 1);
            end if;
        end if;
    end process;

    DOUT <= shift_register;

end architecture;

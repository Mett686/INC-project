-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s): Name Surname (xlogin00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity UART_RX_FSM is
    port(
        CLK : in std_logic;
        RST : in std_logic;
        
        DIN : in std_logic;
        MID : in std_logic;
        STOP_BIT : in std_logic;
        
        -- Mealy
        SAVE : out std_logic;
        DOUT_VLD : out std_logic;
        -- Moore
        CNT_CE : out std_logic;
        D_CNT_RES : out std_logic
    );
end entity;

architecture behavioral of UART_RX_FSM is
    
    type state_type is (S_IDLE, S_START, S_READ, S_STOP);
    signal state, next_state : state_type;
begin

    -- Ovladani stavu
    state_reg: process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                state <= S_IDLE;
            else
                state <= next_state;
            end if;
        end if;
    end process;

    next_state_logic: process(state, DIN, MID, STOP_BIT)
    begin
        SAVE <= '0';
        DOUT_VLD <= '0';
        CNT_CE <= '0';
        D_CNT_RES <= '0';
        next_state <= state; 

        case state is
            when S_IDLE =>
                -- Moore 0 1
                D_CNT_RES <= '1';
                if DIN = '0' then
                    -- Mealy 0 0
                    next_state <= s_start;
                end if;
                
            when S_START =>
                -- Moore 1 1
                CNT_CE <= '1';
                D_CNT_RES <= '1';
                if mid = '1' then
                    if DIN = '1' then
                        -- Mealy 0 0
                        next_state <= s_idle;
                    else
                        -- Mealy 0 0
                        next_state <= s_read;
                    end if;
                end if;
                
            when S_READ =>
                -- Moore 1 0
                cnt_ce <= '1';
                if mid = '1' then
                    -- Mealy 1 0
                    save <= '1';
                    if stop_bit = '1' then
                        next_state <= s_stop;
                    end if;
                end if;
                
            when S_STOP =>
                -- Moore 1 1
                cnt_ce <= '1';
                d_cnt_res <= '1';
                if mid = '1' then
                    -- Mealy 0 0
                    next_state <= s_idle;
                    if DIN = '1' then
                        -- Mealy 0 1
                        dout_vld <= '1';
                    end if;
                end if;
                
        end case;
    end process;

end architecture;

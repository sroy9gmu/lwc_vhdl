----------------------------------------------------------------------------------
-- Company: George Mason University
-- Engineer: Sunanda Roy
-- 
-- Create Date: 12/05/2021 11:42:12 AM
-- Design Name: 
-- Module Name: EK_Control - Behavioral
-- Project Name: SAEAES LWC
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity EK_Control is
  Port (
        clk : in std_logic;
        rst : in std_logic;
        ad_start : in std_logic;
        ptct_start : in std_logic
        );
end EK_Control;

architecture Behavioral of EK_Control is
    type t_state is (S_RESET, S_HASH_START, S_HASH_PROCESS, S_ENC_DEC_START, S_ENC_DEC_PREPROCESS, S_ENC_DEC_PROCESS, S_ENC_DEC_DONE);
    signal state       : t_state;
    signal state_next  : t_state;
    
begin       
    pEK:process(state, clk, ad_start, ptct_start)        
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                state <= S_RESET;                
            else
                state <= state_next;
            end if;
        end if;
        
        case state is
            when S_RESET =>
                if ad_start = '1' then
                    state_next <= S_HASH_START; 
                end if;   

            when S_HASH_START =>
                if ad_start = '0' then
                    state_next <= S_HASH_PROCESS;
                end if;
                
            when S_HASH_PROCESS =>
                if ptct_start = '1' then
                    state_next <= S_ENC_DEC_START;
                end if;           
            
            when S_ENC_DEC_START => 
                if ptct_start = '0' then
                    state_next <= S_ENC_DEC_PREPROCESS;
                end if;
                
            when S_ENC_DEC_PREPROCESS => 
                if ptct_start = '1' then
                    state_next <= S_ENC_DEC_PROCESS;
                end if;   
                
            when S_ENC_DEC_PROCESS => 
                if ptct_start = '0' then
                    state_next <= S_ENC_DEC_DONE;
                end if;  
                
            when others =>

        end case;
    end process;    

end Behavioral;

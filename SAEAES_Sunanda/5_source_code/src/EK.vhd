----------------------------------------------------------------------------------
-- Company: George Mason University
-- Engineer: Sunanda Roy
-- 
-- Create Date: 11/27/2021 09:23:01 PM
-- Design Name: 
-- Module Name: EK - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

use work.EK_pkg.all;
use work.AES_pkg.all;

entity EK is
  Port (
        dinh : in std_logic_vector(EK_BUS_SIZE - 1 downto 0);
        dinl : in std_logic_vector(EK_BUS_SIZE - 1 downto 0);
        douth : out std_logic_vector(EK_BUS_SIZE - 1 downto 0);
        doutl : out std_logic_vector(EK_BUS_SIZE - 1 downto 0);
        is_lambda : in std_logic;
        
        --! For EK_Control;
        ad_start : in std_logic;
        ad_last : in std_logic;
        ptct_start : in std_logic;

        --! For AES_Enc
        clk         : in  std_logic;
        rst         : in  std_logic;
        key         : in  std_logic_vector(AES_BLOCK_SIZE-1 downto 0);
        init        : in  std_logic;
        start       : in std_logic;
        ready       : out std_logic;
        done        : out std_logic;
        done_init   : out std_logic   
        );
end EK;

architecture Behavioral of EK is
    signal di : std_logic_vector(AES_BLOCK_SIZE - 1 downto 0);    
    signal do : std_logic_vector(AES_BLOCK_SIZE - 1 downto 0);
    signal dih : std_logic_vector(EK_BUS_SIZE - 1 downto 0);   
    signal dil : std_logic_vector(EK_BUS_SIZE - 1 downto 0); 
    constant hpad : std_logic_vector := padEK_DATA(ONE, EK_BUS_SIZE); 

begin
    uut:
    entity work.AES_Enc
    port map (
        rst       => rst,
        clk       => clk,
        start     => start,
        ready     => ready,
        init      => init,
        done      => done,
        done_init => done_init,
        din       => di,
        dout      => do,
        key       => key
    );
    
    douth <= do(EK_BLOCK_SIZE - 1 downto EK_BUS_SIZE);
    doutl <= do(EK_BUS_SIZE - 1 downto 0); 
            
    p1:
    process(is_lambda, ad_start, ptct_start, ad_last)  
        variable ditmp : std_logic_vector(AES_BLOCK_SIZE - 1 downto 0); 
    begin
        if ad_start = '1' then
            if is_lambda = '1' then
                dih <= hpad;                              
                dil <= lpad2;
            else               
                dih <= dinh; 
                dil <= dinl;
            end if;
            ditmp := dih & dil;
        else
            if ptct_start = '1' then                         
                if is_lambda = '1' then                    
                    ditmp := (dinh xor hpad) & (dinl xor lpad2);                   
                end if;            
            else
                ditmp := dinh & dinl;                    
            end if;
        end if;
        di <= ditmp;                                          
    end process;    

end Behavioral;

----------------------------------------------------------------------------------
-- Company: George Mason University
-- Engineer: Sunanda Roy
-- 
-- Create Date: 11/27/2021 09:22:08 PM
-- Design Name: 
-- Module Name: EK_pkg - Behavioral
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

package EK_pkg is
	--! EK constants
	constant EK_BLOCK_SIZE				: integer := 128;	
	constant EK_BUS_SIZE				: integer :=  64;
	constant NONCE_SIZE				    : integer := 120;
	constant NONCE_H_SIZE				: integer :=  64;
	constant NONCE_L_SIZE				: integer :=  56;
	constant DIH_BLOCK_SIZE			    : integer := 64;
	constant DIH_MAX_SIZE                : integer := 256;
	    
    constant ZERO_BLOCK : std_logic_vector(EK_BLOCK_SIZE - 1 downto 0) := (others => '0');
    constant ZERO_BUS : std_logic_vector(EK_BUS_SIZE - 1 downto 0) := (others => '0');	    
    constant ZERO2 : std_logic_vector(EK_BUS_SIZE - 1 downto 2) := (others => '0');
    constant ONE : std_logic_vector(0 downto 0) := b"1";
    constant TWO : std_logic_vector(1 downto 0) := b"10";
    constant THREE : std_logic_vector(1 downto 0) := b"11";
    constant ZERO1 : std_logic_vector(EK_BUS_SIZE - 1 downto 1) := (others => '0');   
    constant clk_period : time := 20 ns; 
      
    constant lpad2 : std_logic_vector := ZERO2 & TWO;
    constant lpad1 : std_logic_vector := ZERO1 & ONE;
	
	function padEK_DATA(x: std_logic_vector; k: integer) return std_logic_vector;
	function getNumBlocks(x: std_logic_vector; k: integer) return integer;
end EK_pkg;

package body EK_pkg is
    --  https://stackoverflow.com/questions/29122734/padding-out-std-logic-vector-with-leading-zeros/29124917
    function padEK_DATA(x: std_logic_vector; k: integer) return std_logic_vector is 
        constant ZERO : std_logic_vector(k - 1 downto 0) := (others => '0');
    begin
        if x'length < k then
            -- Pad with trailing zeros
            return x & ZERO(k - 1 downto x'length);
        else
            return x(k - 1 downto 0);
        end if;
    end padEK_DATA;
    
    function getNumBlocks(x: std_logic_vector; k: integer) return integer is
        variable cnt : integer := 0;
        variable left : integer := x'length - 1;
        variable right : integer := left - k + 1;        
        constant ZERO : std_logic_vector(k - 1 downto 0) := (others => '0');
    begin
        while right >= 0 loop
            if x(left downto right) /= ZERO then
                cnt := cnt + 1;                
            end if;
            left := left - k;
            right := right - k;
        end loop;        
        return cnt;
    end getNumBlocks; 
        
end package body;

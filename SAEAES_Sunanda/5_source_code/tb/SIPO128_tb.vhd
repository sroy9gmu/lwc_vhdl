----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/18/2021 11:33:48 PM
-- Design Name: 
-- Module Name: SIPO128_tb - Behavioral
-- Project Name: 
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
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

use work.EK_pkg.all;

entity SIPO128_tb is
end;

architecture bench of SIPO128_tb is

  component SIPO128
    Port (
          Reset 	:	in 		std_logic;
          clk       :   in      std_logic;
          Start 	:	in 		std_logic;
          DataIn 	:	in 		std_logic_vector(BDI_BDO_SIZE - 1 downto 0);
          DataOut	:	out 	std_logic_vector(EK_BLOCK_SIZE -1 downto 0);
          Valid	    :	out 	std_logic 
          );
  end component;

  signal Reset: std_logic;
  signal clk: std_logic;
  signal Start: std_logic;
  signal DataIn: std_logic_vector(BDI_BDO_SIZE - 1 downto 0);
  signal DataOut: std_logic_vector(EK_BLOCK_SIZE -1 downto 0);
  signal Valid: std_logic ;

  constant clock_period: time := 10 ns;
  constant num_blks: integer := 4;
  signal stop_the_clock: boolean;
  
  type DinArray is array (0 to 3) of std_logic_vector(BDI_BDO_SIZE -1 downto 0);
  signal DinValues: DinArray := (x"00010203", x"04050607", x"08090A0B", x"0C0D0E0F");
  signal DoutValues: std_logic_vector(EK_BLOCK_SIZE -1 downto 0) := x"000102030405060708090A0B0C0D0E0F";

begin

  uut: SIPO128 port map ( Reset   => Reset,
                         clk     => clk,
                         Start   => Start,
                         DataIn  => DataIn,
                         DataOut => DataOut,
                         Valid   => Valid );

  stimulus: process
  begin
  
    -- Put initialisation code here
    Start <= '0';
    wait for clock_period;

    -- Put test bench stimulus code here
    for i in 0 to num_blks -1 loop
        DataIn <= DinValues(i);
        wait for clock_period;

        Start <= '1';
        wait for clock_period;
        Start <= '0';
        wait for clock_period;
    end loop;    

    if DataOut = DoutValues then
        report "32 to 128 bit SIPO passed";
    else
        report "32 to 128 bit SIPO failed" & to_hstring(DataOut);
    end if;

    stop_the_clock <= true;
    wait;
  end process;

  clocking: process
  begin
    while not stop_the_clock loop
      clk <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;

end;
  

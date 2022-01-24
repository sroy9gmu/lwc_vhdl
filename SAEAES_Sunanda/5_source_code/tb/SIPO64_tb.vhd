----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/18/2021 10:24:35 PM
-- Design Name: 
-- Module Name: SIPO64_tb - Behavioral
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

-- Testbench created online at:
--   https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

use work.EK_pkg.all;

entity SIPO64_tb is
end;

architecture bench of SIPO64_tb is

  component SIPO64
    Port (
          Reset 	:	in 		std_logic;
          clk       :   in      std_logic;
          Start 	:	in 		std_logic;
          DataIn 	:	in 		std_logic_vector(BDI_BDO_SIZE - 1 downto 0);
          DataOut	:	out 	std_logic_vector(EK_BUS_SIZE -1 downto 0);
          Valid	    :	out 	std_logic 
          );
  end component;

  signal Reset: std_logic;
  signal clk: std_logic;
  signal Start: std_logic;
  signal DataIn: std_logic_vector(BDI_BDO_SIZE - 1 downto 0);
  signal DataOut: std_logic_vector(EK_BUS_SIZE -1 downto 0);
  signal Valid: std_logic ;

  constant clock_period: time := 10 ns;
  constant num_blks: integer := 2;
  signal stop_the_clock: boolean;
  
  type DinArray is array (0 to 1) of std_logic_vector(BDI_BDO_SIZE -1 downto 0);
  signal DinValues: DinArray := (x"00010203", x"04050607");
  signal DoutValues: std_logic_vector(EK_BUS_SIZE -1 downto 0) := x"0001020304050607";

begin

  uut: SIPO64 port map ( Reset   => Reset,
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
        report "32 to 64 bit SIPO passed";
    else
        report "32 to 64 bit SIPO failed" & to_hstring(DataOut);
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
  

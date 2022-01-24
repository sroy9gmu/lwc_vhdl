----------------------------------------------------------------------------------
-- Company: George Mason University
-- Engineer: Sunanda Roy
-- 
-- Create Date: 12/18/2021 09:16:28 PM
-- Design Name: 
-- Module Name: SIPO64 - Behavioral
-- Project Name: SAEAES LWC
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:https://github.com/SonicFrog/ArchOrd/blob/master/sipo.vhdl
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.EK_pkg.all;

entity SIPO64 is
  Port (
        Reset 	:	in 		std_logic;
        clk     :   in      std_logic;
		Start 	:	in 		std_logic;
		DataIn 	:	in 		std_logic_vector(BDI_BDO_SIZE - 1 downto 0);
		DataOut	:	out 	std_logic_vector(EK_BUS_SIZE -1 downto 0);
		Valid	:	out 	std_logic 
        );
end SIPO64;

architecture Behavioral of SIPO64 is
    signal content 	:	std_logic_vector(EK_BUS_SIZE -1 downto 0) := ZERO_BUS;
	signal counter	:	integer := 0;
	signal counting :	std_logic;

begin

    DataOut <= content when counter = 2 else (others => '0');

    count : process(start)
	begin
		if start = '1' and counter < 2 then
			counter <= counter + 1;
			content <= content(EK_BUS_SIZE - BDI_BDO_SIZE - 1 downto 0) & DataIn;
		end if;
	end process;

end Behavioral;

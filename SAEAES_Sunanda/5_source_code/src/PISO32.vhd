----------------------------------------------------------------------------------
-- Company: George Mason University
-- Engineer: Sunanda Roy
-- 
-- Create Date: 12/18/2021 09:16:28 PM
-- Design Name: 
-- Module Name: PISO32 - Behavioral
-- Project Name: SAEAES LWC
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:https://github.com/SonicFrog/ArchOrd/blob/master/piso.vhdl
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
use work.EK_pkg.all;

entity PISO32 is
  Port (
		DataIn 		:	in 		std_logic_vector(EK_BLOCK_SIZE - 1 downto 0);
		Load		:	in 		std_logic;
		Reset		:	in 		std_logic;
		Clk 		:	in 		std_logic;
		Done	    :	out 	std_logic; 
		DataOut	    :	out 	std_logic_vector(BDI_BDO_SIZE -1 downto 0) 
        );
end PISO32;

architecture Behavioral of PISO32 is
	signal reg_data	:	std_logic_vector(EK_BLOCK_SIZE - 1 downto 0);	

begin

	load_data : process(Clk, Load, DataIn)
	begin
		if rising_edge(Clk) then
			if Reset = '1' then
				reg_data <= (others => '0');
			elsif Load = '1' then
				reg_data <= DataIn;
			end if;
		end if;
	end process;

	input_handle : process(Clk)
	begin
		if rising_edge(Clk) then
			DataOut <= reg_data(EK_BLOCK_SIZE - 1 downto BDI_BDO_SIZE);
			reg_data <= reg_data(EK_BLOCK_SIZE - BDI_BDO_SIZE downto 0) & ZERO_BUS(BDI_BDO_SIZE - 1 downto 0);
		end if;
	end process;

	Done <= '1' when reg_data = ZERO_BLOCK;

end Behavioral;

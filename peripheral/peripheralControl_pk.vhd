library IEEE;
use IEEE.std_logic_1164.all;

package peripheralControl_pk is
	-- Device Ids definitions
	constant UART_ID 		: std_logic_vector(5 downto 0) := "000000";
	constant GPIO_LEDS_ID 		: std_logic_vector(5 downto 0) := "000001";
	constant GPIO_SWITCHES_ID 	: std_logic_vector(5 downto 0) := "000010";
end package;

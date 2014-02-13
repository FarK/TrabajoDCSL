library IEEE;
use IEEE.std_logic_1164.all;

use WORK.peripheralControl_pk.all;

entity peripheralControl is
	port (
		-- CPU interface
		cpu_in    : out std_logic_vector (31 downto 0);
		cpu_out   : in std_logic_vector (31 downto 0);    
		cpu_rd    : in std_logic;
		cpu_wr    : in std_logic;
		cpu_ready : out std_logic;
		deviceID  : in std_logic_vector (5 downto 0);

		-- UART interface
		uart_out              : in std_logic_vector (7 downto 0);
		uart_in               : out std_logic_vector (7 downto 0);    
		uart_rd               : out std_logic;
		uart_wr               : out std_logic;
		uart_ready            : in std_logic;

		-- GPIO led
		gpio_leds_out         : in std_logic_vector (7 downto 0);
		gpio_leds_in          : out std_logic_vector (7 downto 0);    
		gpio_leds_rd          : out std_logic;
		gpio_leds_wr          : out std_logic;
		gpio_leds_ready       : in std_logic;

		-- GPIO switches
		gpio_switches_out     : in std_logic_vector (7 downto 0);
		gpio_switches_in      : out std_logic_vector (7 downto 0);    
		gpio_switches_rd      : out std_logic;
		gpio_switches_wr      : out std_logic;
		gpio_switches_ready   : in std_logic
	);
end entity;

architecture behavioral of peripheralControl is
begin
	process(
		-- CPU interface
		cpu_out,
		cpu_rd,
		cpu_wr,
		deviceID,
		-- UART interface
		uart_out,
		uart_ready,
		-- GPIO led
		gpio_leds_out,
		gpio_leds_ready,
		-- GPIO switches
		gpio_switches_out,
		gpio_switches_ready
	)
	begin
		-- Conecting cpu inputs directly
		cpu_in(7 downto 0) <= uart_out;
		cpu_in(7 downto 0) <= gpio_leds_out;
		cpu_in(7 downto 0) <= gpio_switches_out;

		-- Multiplexing outputs with deviceID
		case deviceID is
			when UART_ID =>
				uart_in			<= cpu_out(7 downto 0);
				uart_rd			<= cpu_rd;
				uart_wr			<= cpu_wr;
				cpu_ready		<= uart_ready;
			when GPIO_LEDS_ID =>
				gpio_leds_in		<= cpu_out(7 downto 0);
				gpio_leds_rd		<= cpu_rd;
				gpio_leds_wr		<= cpu_wr;
				cpu_ready		<= gpio_leds_ready;
			when GPIO_SWITCHES_ID =>
				gpio_switches_in	<= cpu_out(7 downto 0);
				gpio_switches_rd	<= cpu_rd;
				gpio_switches_wr	<= cpu_wr;
				cpu_ready		<= gpio_switches_ready;
			when others =>
				cpu_in <= (others => '0');
				cpu_ready <= '0';
		end case;
	end process;
end architecture;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use WORK.micro_pk.all;
use WORK.micro_comp_pk.all;

entity gpio is
	port (
		clk : in std_logic;
		rst : in std_logic;

		cpu_MBRin   : out std_logic_vector (31 downto 0);
		cpu_MBRout  : in std_logic_vector (31 downto 0);    
		cpu_rd      : in std_logic;
		cpu_wr      : in std_logic;
		cpu_ready   : out std_logic;                     -- operation done
		cpu_deviceID: in std_logic_vector (5 downto 0);

		-- IO Registers
		leds        : out std_logic_vector(7 downto 0);
		switches    : in std_logic_vector(3 downto 0)
	);
end entity;

architecture behavioral of gpio is
begin
	process (rst, clk)
	begin
		if rst='1' then
			leds <= (leds'range => '0');
			cpu_ready <= '0';
		elsif rising_edge(clk) then
			cpu_ready <= '0';
			case (to_integer(unsigned(cpu_deviceID))) is
				when GPIO_LEDS_ID =>
					leds <= cpu_MBRout(7 downto 0);
					cpu_ready <= '1';
				when GPIO_SWITCHES_ID =>
					cpu_MBRin(3 downto 0) <= switches;
					cpu_ready <= '1';
				when others =>
					cpu_ready <= '0';
			end case;
		end if;
	end process;
end architecture;

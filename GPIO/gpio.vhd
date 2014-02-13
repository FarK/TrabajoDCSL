library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use WORK.micro_pk.all;
use WORK.micro_comp_pk.all;

entity gpio is
	port (
		clk : in std_logic;
		rst : in std_logic;

		data_in     : in std_logic_vector(7 downto 0);
		data_out    : out std_logic_vector(7 downto 0);    
		rd          : in std_logic;
		wr          : in std_logic;
		ready       : out std_logic;                     -- operation done

		-- IO Registers
		peripheral_in      : in std_logic_vector(7 downto 0);
		peripheral_out     : out std_logic_vector(7 downto 0)
	);
end entity;

architecture behavioral of gpio is
begin
	process (rst, clk)
	begin
		ready <= '1';

		if rst='1' then
			peripheral_out <= (peripheral_out'range => '0');
		elsif rising_edge(clk) then
			if rd = '1' then
				data_out <= peripheral_in;
			end if;
			if wr = '1' then
				peripheral_out <= data_in;
			end if;
		end if;
	end process;
end architecture;

-----------------------------------------------------------------------------
-- Copyright (C) 2005 IMEC                                                  -
--                                                                          -
-- Redistribution and use in source and binary forms, with or without       -
-- modification, are permitted provided that the following conditions       -
-- are met:                                                                 -
--                                                                          -
-- 1. Redistributions of source code must retain the above copyright        -
--    notice, this list of conditions and the following disclaimer.         -
--                                                                          -
-- 2. Redistributions in binary form must reproduce the above               -
--    copyright notice, this list of conditions and the following           -
--    disclaimer in the documentation and/or other materials provided       -
--    with the distribution.                                                -
--                                                                          -
-- 3. Neither the name of the author nor the names of contributors          -
--    may be used to endorse or promote products derived from this          -
--    software without specific prior written permission.                   -
--                                                                          -
-- THIS CODE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS''           -
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED        -
-- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A          -
-- PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR       -
-- CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,             -
-- SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT         -
-- LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF         -
-- USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND      -
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,       -
-- OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT       -
-- OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF       -
-- SUCH DAMAGE.                                                             -
--                                                                          -
-- -----------------------------------------------------------------------------
-- Project     : Micro6 microprocessor
-- Author      : Geert Vanwijnsberghe
-- File        : tb_memory.vhd
-- Design      : testbench for memory
--------------------------------------------------------------------------------
-- Description : test of memory
-- -----------------------------------------------------------------------------
-- History :
--  13/12/06 : vwb : generation
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.micro_pk.all;
use work.micro_comp_pk.all;

entity tb_memory is
	end entity;

architecture test of tb_memory is
	signal clk          : std_logic;
	signal inbus,outbus : std_logic_vector (DATA_WIDTH - 1 downto 0);
	signal rd,wr        : std_logic;
	signal ready        : std_logic;
	signal addr         : std_logic_vector (ADDR_WIDTH - 1 downto 0);

	signal EndOfSim    : boolean := false;
	constant clkPeriod : time := 10 ns;
	constant dutyCycle : real := 0.5; 

	-- Note: every procedure starts and ends at falling edge of clk

	procedure read_mem(
	address  : natural;
	data_exp : std_logic_vector;
	signal addr : out std_logic_vector;
	signal outbus : in std_logic_vector;
	signal rd   : out std_logic;
	signal wr   : out std_logic) is
	begin
		addr <= std_logic_vector (to_unsigned (address, addr'length));
		wr <= '0';
		rd <= '1';
		wait until falling_edge (clk);
		assert (outbus = data_exp) 
		report "Error reading from memory location" & natural'image (address);
		wr <= '0';
		rd <= '0';
	end procedure;

	procedure write_mem (
	address  : natural;
	data     : natural;
	signal addr  : out std_logic_vector;
	signal inbus : out std_logic_vector;
	signal rd    : out std_logic;
	signal wr    : out std_logic) is
	begin
		addr <= std_logic_vector (to_unsigned (address, addr'length));
		inbus<= std_logic_vector (to_unsigned (data, inbus'length));
		wr <= '1';
		rd <= '0';
		wait until falling_edge (clk);
		wr <= '0';
		rd <= '0';
	end procedure;

	procedure idle( nr_of_clks : natural) is
	begin
		for i in 1 to nr_of_clks loop
			wait until falling_edge (clk);
		end loop; 
	end procedure;

begin
	uut: memory 
	port map (
			 clk     => clk    ,
			 inBus   => inBus  ,
			 addr    => addr   ,
			 rd      => rd     ,
			 wr      => wr     ,
			 outBus  => outBus ,
			 ready   => ready  );

	-- Clock Generation process
	clock: process
	begin
		clk <= '0';
		wait for (1.0 - dutyCycle) * clkPeriod;
		clk <= '1';
		wait for dutyCycle * clkPeriod;
		if EndOfSim then -- The simulation EndOfSims due to event starvation
			wait;
		end if;
	end process; 

	main: process
	begin
		-- Initial inputs
		wr <= '0';
		rd <= '0';   
		inbus <= (others => '0');

		wait until falling_edge (clk); -- allign inputs to falling_edge of clk

		report " Write into memory 3 extra cycles";
		for i in 0 to (2**5)-1 loop   -- 5 ==> 12
			write_mem(i,i+100,addr,inbus,rd,wr); 
			idle(3);   
		end loop;  
		report " Read from memory 2 extra cycles";
		for i in 0 to (2**5)-1 loop   -- 5 ==> 12
			read_mem(i,std_logic_vector(to_unsigned(i+100,32)),addr,outbus,rd,wr); 
			idle(2);   
		end loop; 

		report " Write into memory 1 extra cycles";
		wait until falling_edge (clk); -- allign inputs to falling_edge of clk
		for i in 0 to (2**5)-1 loop   -- 5 ==> 12
			write_mem(i,i+200,addr,inbus,rd,wr); 
			idle(1);   
		end loop;  
		report " Read from memory 1 extra cycles";
		for i in 0 to (2**5)-1 loop   -- 5 ==> 12
			read_mem(i,std_logic_vector(to_unsigned(i+200,32)),addr,outbus,rd,wr); 
			idle(1);   
		end loop;     

		report " Write into memory 0 extra cycles";
		wait until falling_edge (clk); -- allign inputs to falling_edge of clk
		for i in 0 to (2**5)-1 loop   -- 5 ==> 12
			write_mem(i,i+300,addr,inbus,rd,wr);    
		end loop;  
		report " Read from memory 0 extra cycles";
		for i in 0 to (2**5)-1 loop   -- 5 ==> 12
			read_mem(i,std_logic_vector(to_unsigned(i+300,32)),addr,outbus,rd,wr);   
		end loop;  

		EndOfSim <= true;
		report " Test done";
		wait;   
	end process;
end architecture;

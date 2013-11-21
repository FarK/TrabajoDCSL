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
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- File           : tb_stack.vhd
-----------------------------------------------------------------------------
-- Description    : Testbench for stack of the Micro6
-- --------------------------------------------------------------------------
-- Author         : Osman Allam
-- Date           : 07/02/2006
-- Version        : 1.0
-- Change history : 
-----------------------------------------------------------------------------  
-- This code was developed by Osman Allam during an internship at IMEC, 
-- in collaboration with Geert Vanwijnsberghe, Tom Tassignon en Steven 
-- Redant. The purpose of this code is to teach students good VHDL coding
-- style for writing complex behavioural models.
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_stack is
	end entity;

architecture test of tb_stack is
	signal clk  : std_logic;
	signal rst  : std_logic;
	signal en   : std_logic;
	signal d    : std_logic_vector (7 downto 0);
	signal push : std_logic;
	signal pop  : std_logic;
	signal q    : std_logic_vector (7 downto 0);

	component stack is
		port (
			clk  : in std_logic;
			rst  : in std_logic;
			en   : in std_logic;
			d    : in std_logic_vector;
			push : in std_logic;
			pop  : in std_logic;
			q    : out std_logic_vector);
	end component;

	signal EndOfSim : boolean := false;
	constant clkPeriod : time := 10 ns;
	constant dutyCycle : real := 0.5;  

	procedure t_push (
		data : in std_logic_vector;
		signal d : out std_logic_vector;
		signal en : out std_logic;
		signal push : out std_logic) is
	begin
		d <= data;
		en <= '1';
		push <= '1';
		wait until falling_edge (clk);
		en <= '0';
		push <= '0';
		wait until falling_edge (clk);
	end procedure;

	procedure t_pop (
		data_expected : in std_logic_vector;
		signal en : out std_logic;
		signal pop : out std_logic) is
	begin
		en <= '1';
		pop <= '1';
		wait until falling_edge (clk);
		en <= '0';
		pop <= '0';
		wait until falling_edge (clk);
		assert (q = data_expected) report "Popping doesn't work correctly";
	end procedure;

begin
	UUT: stack port map (clk, rst, en, d, push, pop, q);

	clock: process
	begin
		clk <= '0';
		wait for (1.0 - dutyCycle) * clkPeriod;
		clk <= '1';
		wait for dutyCycle * clkPeriod;
		if EndOfSim then
			wait;
		end if;
	end process;

	process 
	begin
		en <= '0';
		pop <= '0';
		push <= '0';

		-- Testing the reset signal
		wait for 23 ns;
		rst <= '1';
		wait for 1 ns;
		assert (q = (q'range => '0')) report "Reset doesn't reset the stack";
		wait for 50 ns;
		rst <= '0';
		wait until falling_edge (clk); -- allign rest of inputs with falling edge of clk

		-- Pushing 00001100 into the stack
		t_push ("00001100", d, en, push);
		-- Stack contents
		-- 00: 00001100   04: 00000000    08: 00000000    12: 00000000
		-- 01: 00000000   05: 00000000    09: 00000000    13: 00000000
		-- 02: 00000000   06: 00000000    10: 00000000    14: 00000000
		-- 03: 00000000   07: 00000000    11: 00000000    15: 00000000
		-- Stack pointer: 01

		-- Poping a word from the stack
		t_pop ("00001100", en, pop);
		-- Stack contents
		-- 00: 00001100   04: 00000000    08: 00000000    12: 00000000
		-- 01: 00000000   05: 00000000    09: 00000000    13: 00000000
		-- 02: 00000000   06: 00000000    10: 00000000    14: 00000000
		-- 03: 00000000   07: 00000000    11: 00000000    15: 00000000
		-- Stack pointer: 00

		-- Popping again from the empty stack returns the same value but doesn't 
		-- change the stack status (contents and pointer)
		t_pop ("00001100", en, pop);
		-- Stack contents
		-- 00: 00001100   04: 00000000    08: 00000000    12: 00000000
		-- 01: 00000000   05: 00000000    09: 00000000    13: 00000000
		-- 02: 00000000   06: 00000000    10: 00000000    14: 00000000
		-- 03: 00000000   07: 00000000    11: 00000000    15: 00000000
		-- Stack pointer: 00

		-- Pushing 11001100 into the stack
		t_push ("11001100", d, en, push);

		-- Pushing 00110011 into the stack
		t_push ("00110011", d, en, push);

		-- Pushing 10101010 into the stack
		t_push ("10101010", d, en, push);

		-- Pushing 01010101 into the stack
		t_push ("01010101", d, en, push);
		-- Stack contents
		-- 00: 11001100   04: 00000000    08: 00000000    12: 00000000
		-- 01: 00110011   05: 00000000    09: 00000000    13: 00000000
		-- 02: 10101010   06: 00000000    10: 00000000    14: 00000000
		-- 03: 01010101   07: 00000000    11: 00000000    15: 00000000
		-- Stack pointer: 04

		-- Poping a word from the stack
		t_pop ("01010101", en, pop);

		-- Poping a word from the stack
		t_pop ("10101010", en, pop);

		-- Poping a word from the stack
		t_pop ("00110011", en, pop);

		-- Poping a word from the stack
		t_pop ("11001100", en, pop);
		-- Stack contents
		-- 00: 11001100   04: 00000000    08: 00000000    12: 00000000
		-- 01: 00110011   05: 00000000    09: 00000000    13: 00000000
		-- 02: 10101010   06: 00000000    10: 00000000    14: 00000000
		-- 03: 01010101   07: 00000000    11: 00000000    15: 00000000
		-- Stack pointer: 00

		-- Filling up the stack with (pushing 16 values)
		t_push ("00000011", d, en, push);
		t_push ("00000111", d, en, push);
		t_push ("00001011", d, en, push);
		t_push ("00001111", d, en, push);
		t_push ("00010011", d, en, push);
		t_push ("00010111", d, en, push);
		t_push ("00011011", d, en, push);
		t_push ("00011111", d, en, push);
		t_push ("00100011", d, en, push);
		t_push ("00100111", d, en, push);
		t_push ("00101011", d, en, push);
		t_push ("00101111", d, en, push);
		t_push ("00110011", d, en, push);
		t_push ("00110111", d, en, push);
		t_push ("00111011", d, en, push);
		t_push ("00111111", d, en, push);
		-- Stack contents
		-- 00: 00000011   04: 00010011    08: 00100011    12: 00110011
		-- 01: 00000111   05: 00010111    09: 00100111    13: 00110111
		-- 02: 00001011   06: 00011011    10: 00101011    14: 00111011
		-- 03: 00001111   07: 00011111    11: 00101111    15: 00111111
		-- Stack pointer: 16

		-- Pushing additional data shouldn't change the stack status
		t_push ("01000011", d, en, push);
		t_push ("01000111", d, en, push);
		-- Stack contents << THE SAME >>
		-- 00: 00000011   04: 00010011    08: 00100011    12: 00110011
		-- 01: 00000111   05: 00010111    09: 00100111    13: 00110111
		-- 02: 00001011   06: 00011011    10: 00101011    14: 00111011
		-- 03: 00001111   07: 00011111    11: 00101111    15: 00111111
		-- Stack pointer: 16

		-- Popping the entire stack contents
		t_pop ("00111111", en, pop);
		t_pop ("00111011", en, pop);
		t_pop ("00110111", en, pop);
		t_pop ("00110011", en, pop);
		t_pop ("00101111", en, pop);
		t_pop ("00101011", en, pop);
		t_pop ("00100111", en, pop);
		t_pop ("00100011", en, pop);
		t_pop ("00011111", en, pop);
		t_pop ("00011011", en, pop);
		t_pop ("00010111", en, pop);
		t_pop ("00010011", en, pop);
		t_pop ("00001111", en, pop);
		t_pop ("00001011", en, pop);
		t_pop ("00000111", en, pop);
		t_pop ("00000011", en, pop);
		-- Stack contents
		-- 00: 00000011   04: 00010011    08: 00100011    12: 00110011
		-- 01: 00000111   05: 00010111    09: 00100111    13: 00110111
		-- 02: 00001011   06: 00011011    10: 00101011    14: 00111011
		-- 03: 00001111   07: 00011111    11: 00101111    15: 00111111
		-- Stack pointer: 00

		-- Additional pops shouldn't change the stack status
		t_pop ("00000011", en, pop);
		t_pop ("00000011", en, pop);
		-- Stack contents << THE SAME >>
		-- 00: 00000011   04: 00010011    08: 00100011    12: 00110011
		-- 01: 00000111   05: 00010111    09: 00100111    13: 00110111
		-- 02: 00001011   06: 00011011    10: 00101011    14: 00111011
		-- 03: 00001111   07: 00011111    11: 00101111    15: 00111111
		-- Stack pointer: 00

		report "Simulation completed";
		EndOfSim <= true;
		wait;
	end process;
end architecture;

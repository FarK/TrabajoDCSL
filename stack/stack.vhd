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
-- File           : stack.vhd
-----------------------------------------------------------------------------
-- Description    : Stack of the Micro6
-- --------------------------------------------------------------------------
-- Author         : Osman Allam
-- Date           : 07/02/2006
-- Version        : 1.0
-- Change history : 
----------------------------------------------------------------------------- 
-- This code was developed by Osman Allam during an internship at IMEC, 
-- in collaboration with Geert Vanwijnsberghe, Tom Tassignon and Steven 
-- Redant. The purpose of this code is to teach students good VHDL coding
-- style for writing complex behavioural models.
-----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use WORK.micro_pk.all;

entity stack is
	generic (depth : positive := 16);
	port (
		clk  : in std_logic;
		rst  : in std_logic;
		en   : in std_logic;
		d    : in std_logic_vector;
		push : in std_logic;
		pop  : in std_logic;
		q    : out std_logic_vector);
end entity;

architecture behavioral of stack is
	-- Declare the type 'stackData' as an array of words with the same width of 'd'
	type stackData is array(natural range<>) of std_logic_vector(d'range);
	-- Declare the signal 'st_data' of type 'stackData' and width of 16 (ascending range)
	signal st_data : stackData(0 to STACK_SIZE);
	-- Declare an unsigned signal for the stack pointer with appropriate width (depth of stack is 16)
	signal pointer : unsigned(4 downto 0);
	-- Declare a signal for the output register with appropriate type and width
	signal q_int : std_logic_vector(q'range);
	-- Declare a type for the states of the FSM. the states are: idle, wr, rd, inc, dec
	type state is (idle, wr, rd, inc, dec);
	-- Declare two signals for the currentState and nextState
	signal currentState : state;
	signal nextState : state;
	constant STACK_SLOT : natural := 1;
begin
	process (rst, clk)
	begin
		if (rst = '1') then
			currentState <= idle;
		elsif rising_edge (clk) then
			currentState <= nextState;
		end if;
	end process;

	process (en, d, push, pop)
	begin
		-- State transition process. Determine 'nextState' depending on 'currentState' (use the given transition table)
		case currentState is
			when idle =>
				if(push='1' and en='1' and pointer<STACK_SIZE-1) then
					nextState <=  wr;
				elsif(pop='1' and en='1' and pointer>0) then
					nextState <=  dec;
				else
					nextState <=  idle;
				end if;
			when inc =>
				if(push='1' and en='1' and pointer<STACK_SIZE) then
					nextState <=  wr;
				elsif(pop='1' and en='1' and pointer>0) then
					nextState <=  dec;
				else
					nextState <=  idle;
				end if;
			when rd =>
				if(push='1' and en='1' and pointer<STACK_SIZE) then
					nextState <=  wr;
				elsif(pop='1' and en='1' and pointer>0) then
					nextState <=  dec;
				else
					nextState <=  idle;
				end if;
			when wr =>
					nextState <=  inc;
			when dec =>
					nextState <=  rd;
		end case;
	end process;

	process (rst, clk)
	begin
		if (rst = '1') then
			pointer <= to_unsigned (0, pointer'length);
			q_int <= (q_int'range => '0');
		elsif rising_edge (clk) then
			if nextState = rd then
				q_int <= st_data (to_integer (pointer));
			elsif nextState = wr then
				st_data (to_integer (pointer)) <= d;
				q_int <= d;
			elsif nextState = inc then
				pointer <= pointer + STACK_SLOT;
			elsif nextState = dec then
				pointer <= pointer - STACK_SLOT;
			end if;
		end if;
	end process;  

	q <= q_int;
end architecture;

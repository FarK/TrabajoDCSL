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
-- File           : alu_tb.vhd
-----------------------------------------------------------------------------
-- Description    : Testbench for ALU
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
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use WORK.micro_pk.all;
use WORK.micro_comp_pk.all;

use STD.textio.all;
use IEEE.std_logic_textio.all;

entity alu_tb is
	end entity;

architecture test of alu_tb is
	-- declare signals to connect the ALU
	-- you may use the same names as the ALU formal ports
	-- add code here

	-- computation (propagation) delay time
	constant delay_time : time := 20 ns;
	-- time elapsed before applying the next test vector
	constant time_offset : time := 80 ns;

	-- Use this function to convert from STD_LOGIC_VECTOR to alu_op
	function slv_to_alu_op (arg : std_logic_vector (4 downto 0)) return alu_op is
	begin
		case arg is
			when "00000" => return ADD_op;
			when "00001" => return SUB_OP;
			when "00010" => return MULT_OP;
			when "00011" => return DIV_OP;
			when "00100" => return REM_OP;
			when "00101" => return AND_OP;
			when "00110" => return OR_OP;
			when "00111" => return XOR_OP;
			when "01000" => return INV_OP;
			when "01001" => return INC_OP;
			when "01010" => return DEC_OP;
			when "01011" => return ZRO_OP;
			when "01100" => return PASS_A;
			when "01101" => return PASS_B;
			when "01110" => return SHR_ARTH;
			when "01111" => return SHR_LGC;
			when "10000" => return SHL_ARTH;
			when "10001" => return SHL_LGC;
			when "10010" => return ROTR;
			when "10011" => return ROTL;
			when others => return PASS_A;
		end case;
	end function;

begin
	-- instantiate the ALU here
	-- add code here

	testbench_proc: process
	-- declare a pointer to the test vectors file
	-- add code here

	-- declare a line buffer
	-- add code here

	-- declare variables for the stimuli and expected values that you plan
	-- to read from the text file
	-- add code here       

	begin
		-- keep reading (loop) until you reach the end of the file
		-- the loop starts here
		-- add code here
		
		-- read a line into the line buffer
		-- add code here
		
		-- read test vector entries one by one from the line buffer
		-- add code here    
		
		-- applying stimuli
		-- add code here

		wait for delay_time;

		-- Comparing outputs against expected values
		-- add code here

		wait for time_offset;

		-- the loop ends here
		wait; -- wait forever after consuming all the test vectors
	end process;
end architecture;

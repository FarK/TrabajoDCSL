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
	-- Signals to connect the ALU
	signal a           : std_logic_vector (DATA_WIDTH - 1 downto 0); 
	signal b           : std_logic_vector (DATA_WIDTH - 1 downto 0);
	signal sel         : alu_op;
	signal shiftCnt    : std_logic_vector (4 downto 0); -- shift count
	signal shiftCntSrc : std_logic; -- shift count source
	signal result      : std_logic_vector (DATA_WIDTH - 1 downto 0);
	signal neg         : std_logic; -- negative
	signal ovf         : std_logic; -- overflow
	signal zro         : std_logic;  -- zero

	signal EndOfSim : boolean:=false;

	component alu
		port (
			a           : in std_logic_vector; 
			b           : in std_logic_vector;
			sel         : in alu_op;
			shiftCnt    : in std_logic_vector; -- shift count
			shiftCntSrc : in std_logic; -- shift count source
			result      : out std_logic_vector;
			neg         : out std_logic; -- negative
			ovf         : out std_logic; -- overflow
			zro         : out std_logic  -- zero
		     );
	end component;

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
	A1: alu port map(
		a => a,
		b => b,
		sel => sel,
		shiftCnt => shiftCnt,
		shiftCntSrc => shiftCntSrc,
		result => result,
		neg => neg,
		ovf => ovf,
		zro => zro
	);

	testbench_proc: process
	-- declare a pointer to the test vectors file
	--file testFile : text open read_mode is "../alu/alu_testvectors.txt";
	file testFile : text open read_mode is "../alu/alu_testvectors.csv";

	-- declare a line buffer
	variable lineBuff : line;

	-- declare variables for the stimuli and expected values that you plan
	-- to read from the text file
	variable index	: integer;
	variable inA	: integer;
	variable inB	: integer;
	variable inSel	: std_logic_vector(4 downto 0);
	variable inCNT	: std_logic_vector(4 downto 0);
	variable inS	: std_logic;
	variable outRes	: integer;
	variable outC	: std_logic;
	variable outNeg	: std_logic;
	variable outOvf	: std_logic;
	variable outZro	: std_logic;

	begin
		-- discart 4 first lines
		readline(testFile, lineBuff);
		readline(testFile, lineBuff);
		readline(testFile, lineBuff);
		readline(testFile, lineBuff);

		-- keep reading (loop) until you reach the end of the file
		while not endfile(testFile)
		loop
			-- read a line into the line buffer
			readline(testFile, lineBuff);
			
			-- read test vector entries one by one from the line buffer
			read(lineBuff, index);
			read(lineBuff, inA);
			read(lineBuff, inB);
			read(lineBuff, inSel);
			read(lineBuff, inCNT);
			read(lineBuff, inS);
			read(lineBuff, outRes);
			read(lineBuff, outC);
			read(lineBuff, outNeg);
			read(lineBuff, outOvf);
			read(lineBuff, outZro);
			
			-- applying stimuli
			a <= std_logic_vector(to_signed(inA, DATA_WIDTH));
			b <= std_logic_vector(to_signed(inB, DATA_WIDTH));
			sel <= slv_to_alu_op(inSel);
			shiftCnt <= inCNT;
			shiftCntSrc <= inS;

			wait for delay_time;

			-- Comparing outputs against expected values
			if outC = '1' then
				-- Result
				assert result = std_logic_vector(to_signed(outRes, DATA_WIDTH))
					report 	"Test No " & integer'image(index + 4) &
						" -- Result = " & integer'image(to_integer(signed(result))) &
						" , se esperaba Result = " & integer'image(outRes)
					severity ERROR;
			end if;
			-- Neg
			assert neg = outNeg
				report 	"Test No " & integer'image(index + 4) &
					" -- Neg = " & std_logic'image(neg) &
					" , se esperaba Neg = " & std_logic'image(outNeg)
				severity ERROR;

			-- Ovf
			assert ovf = outOvf
				report 	"Test No " & integer'image(index + 4) &
					" -- Ovf = " & std_logic'image(ovf) &
					" , se esperaba Ovf = " & std_logic'image(outOvf)
				severity ERROR;

			-- Zro
			assert zro = outZro
				report 	"Test No " & integer'image(index + 4) &
					" -- Zro = " & std_logic'image(zro) &
					" , se esperaba Zro = " & std_logic'image(outZro)
				severity ERROR;

			wait for time_offset;
		end loop;
		wait; -- wait forever after consuming all the test vectors
	end process;
end architecture;

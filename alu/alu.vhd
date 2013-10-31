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
-- Author      : Osman Allam
-- File        : alu.vhd
-- Design      : ALU
-- -----------------------------------------------------------------------------
-- Description : Arithmetic and logic unit
-- The ALU performs arithmetic and logic operations on two operands A and B. the
-- required operations is specified by the input port "sel". The output shows on 
-- the output port "result". The ALU updates the condition flags (neg, ovf, zro)
-- as a result of the computation.
-- -----------------------------------------------------------------------------
-- History :
--  1/12/06 : vwb : use functions +,- .... from numeric_std instead of micro_pk
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use WORK.micro_pk.all;

entity alu is
	port (
		     a           : in std_logic_vector (DATA_WIDTH - 1 downto 0); 
		     b           : in std_logic_vector (DATA_WIDTH - 1 downto 0);
		     sel         : in alu_op;
		     shiftCnt    : in std_logic_vector (4 downto 0); -- shift count
		     shiftCntSrc : in std_logic; -- shift count source (*)
		     result      : out std_logic_vector (DATA_WIDTH - 1 downto 0);
		     neg         : out std_logic; -- negative
		     ovf         : out std_logic; -- overflow
		     zro         : out std_logic  -- zero
	     );
-- (*) shiftCntSrc:
-- when 0, the shift count is the input shiftCnt, otherwise, it is the least 
-- significant slice of the input b.
end entity;

architecture behavioral of alu is

	signal cnt_i    : integer range 0 to 31;          -- actual shift count
	signal result_i : std_logic_vector(result'range); -- internal value of result
							  -- needed because port out cannot be read

	function is_neg (arg: signed) return boolean is   -- this function could also be put in the
	begin                                             -- micro_pk.vhd file
		return ( not is_pos(arg)); 
	end function;  

begin
	-- calculation of the actual shift value depends on  shiftCntSrc
	cnt_i <= to_integer(unsigned(b (4 downto 0)))  when (shiftCntSrc = '1')   else
		 to_integer(unsigned(shiftCnt));

	-- Perform the actual computations for ovf and result_i depending on the value of sel, a,b and cnt_i
	computation: process (a,b,sel,shiftCnt,shiftCntSrc)
		variable result_v : std_logic_vector(result'range);  -- assign the result first to a variable (= immediate assignment)
								     -- because the result will also be needed to calculate
								     -- the overflow flag.
	begin
		-- add default values for result_i and ovf
		result_i <= std_logic_vector(to_unsigned(0,DATA_WIDTH));
		ovf <= '0';

		case sel is
			when ADD_OP =>
				result_v := std_logic_vector(signed(a) + signed(b));

				-- Si sumo a un positivo un positivo y me sale negativo => overflow
				-- Si sumo a un negativo un negativo y me sale positivo => overflow
				if a(a'high) = b(b'high-1) and result_v(result_v'high) /= a(a'high) then
					ovf <= '1';
				end if;

			when SUB_OP => 
				result_v := std_logic_vector(signed(a) - signed(b));
				-- Si resto a un positivo un negativo y me sale negativo => overflow
				-- Si resto a un negativo un positivo y me sale positivo => overflow
				if a(a'high) /= b(b'high-1) and result_v(result_v'high) = b(b'high) then
					ovf <= '1';
				end if;

			when MULT_OP =>
				result_v := std_logic_vector(MultL(signed(a),signed(b)));

				-- Si alguno de los dos operandos ocupa más de DATA_WIDTH/2 hay overflow
				for i in DATA_WIDTH/2 to DATA_WIDTH loop
					if a(i) /= b(i) then
						ovf <= '1';
					end if;
				end loop;

			--  when DIV_OP => -- do not implement
			--  when REM_OP => -- do not implement

			when INC_OP => 
				result_v := std_logic_vector(signed(a) + 1);
				-- Si sumo a un positivo un positivo y me sale negativo => overflow
				-- b siempre es positivo
				if a(a'high) = '0' and result_v(result_v'high) = '1' then
					ovf <= '1';
				end if;

			when DEC_OP =>
				result_v := std_logic_vector(signed(a) - 1);
				-- Si resto a un negativo un positivo y me sale positivo => overflow
				-- b siempre es negativo
				if a(a'high) = '1' and result_v(result_v'high) = '0' then
					ovf <= '1';
				end if;

			when ZRO_OP =>
				result_v := (others => '0');
			when AND_OP =>
				result_v := std_logic_vector(unsigned(a) and unsigned(b));
			when OR_OP =>
				result_v := std_logic_vector(unsigned(a) or unsigned(b));
			when XOR_OP =>
				result_v := std_logic_vector(unsigned(a) xor unsigned(b));
			when INV_OP =>
				result_v := std_logic_vector(not unsigned(a));
			when PASS_A =>
				result_v := std_logic_vector(signed(a));
			when PASS_B =>
				result_v := std_logic_vector(signed(b));
			when SHR_ARTH =>
				result_v := std_logic_vector(shift_right(signed(a),cnt_i));
			when SHR_LGC =>
				result_v := std_logic_vector(shift_right(unsigned(a),cnt_i));
			when SHL_ARTH =>
				result_v := std_logic_vector(shift_left(signed(a),cnt_i));
				result_v(result_v'high) := a(a'high);
			when SHL_LGC =>
				result_v := std_logic_vector(shift_left(unsigned(a),cnt_i));
			when ROTR =>
				result_v := std_logic_vector(rotate_right(signed(a),cnt_i));
			when ROTL =>
				result_v := std_logic_vector(rotate_left(signed(a),cnt_i));
			when others => 
				result_v := a;
		end case;
		result_i <= result_v;
	end process computation;

	-- Calculate zro and neg
	zro <= '1' when signed(result_i) = 0 else
	       '0';
	neg <= '1' when result_i(result_i'high) = '1' else
	       '0';

	--proces(...) begin
	--if signed(result_i) = 0 then
	--	zro <= '0';
	--end if;
	--end process;

	result <= result_i;
end architecture;

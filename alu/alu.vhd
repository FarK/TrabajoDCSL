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
  -- add the sensitivity list    
	computation: process (........)
		variable result_v : std_logic_vector(result'range);  -- assign the result first to a variable (= immediate assignment)
								     -- because the result will also be needed to calculate
								     -- the overflow flag.
	begin
    -- add default values for result_i and ovf
    -- add code here

		case sel is
			when ADD_OP =>
      -- calculate result_v
      -- add code here


      -- calculate ovf
      -- add code here


			when SUB_OP => 
      -- add code here

			when MULT_OP =>
      -- add code here 

      --       when DIV_OP => -- do not implement
      --       when REM_OP => -- do not implement
			when INC_OP => 
      -- add code here

      -- add also code for the rest of the operations : DEC_OP,ZRO_OP,AND_OP,OR_OP,XOR_OP,
      --  INV_OP,PASS_A,PASS_B,SHR_ARTH,SHR_LGC,SHL_ARTH,SHL_LGC,ROTR,ROTL


			when others => 
				result_v := a;
		end case;
		result_i <= result_v;
	end process computation;

  -- Calculate zro and neg
  -- add code here




	result <= result_i;

end architecture;


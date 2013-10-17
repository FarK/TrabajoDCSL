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
-- File        : micro_pk.vhd
-- Design      : Micro6 main package
--------------------------------------------------------------------------------
-- Description : This package contains definitions of the types, subtypes, 
-- functions and procedures utilized by different entities.
-- -----------------------------------------------------------------------------
-- History :
--  1/12/06 : vwb : removed all overloaded functions from numeric_std
-- 30/11/06 : vwb : subtype alu_op replaced by enumerated type alu_op
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package micro_pk is
  constant DATA_WIDTH : integer := 32;

  constant ADDR_WIDTH : integer := 12;
  
  constant SHORT_DATA  : positive := 9;
  constant inxHighWord : std_logic_vector (ADDR_WIDTH - 1 downto SHORT_DATA)
    := (others => '0');
  constant Page_0      : std_logic_vector (ADDR_WIDTH - 1 downto SHORT_DATA)
    := (others => '0');
  constant stkHighWord : std_logic_vector (ADDR_WIDTH - 1 downto SHORT_DATA) 
    := (others => '1');
    
  constant DIR_RIGHT : std_logic := '1';
  constant DIR_LEFT  : std_logic := '0';

  subtype opcode_t is std_logic_vector(4 downto 0);
  
  constant ADD_i : opcode_t := "00000";
  constant SUB_i : opcode_t := "00001";
  constant MUL_i : opcode_t := "00010";
  constant DIV_i : opcode_t := "00011";
  constant REM_i : opcode_t := "00100";
  constant AND_i : opcode_t := "00101";
  constant OR_i  : opcode_t := "00110";
  constant XOR_i : opcode_t := "00111";
  constant INC_i : opcode_t := "01000";
  constant DEC_i : opcode_t := "01001";
  constant NOT_i : opcode_t := "01010";
  constant ZRO_i : opcode_t := "01011";
  constant CPR_i : opcode_t := "01100";
  constant SHA_i : opcode_t := "01101";
  constant SHL_i : opcode_t := "01110";
  constant ROT_i : opcode_t := "01111";
  constant CMP_i : opcode_t := "10000";
  constant LD_i  : opcode_t := "10001";
  constant LDX_i : opcode_t := "10010";
  constant LDM_i : opcode_t := "10011";
  constant ST_i  : opcode_t := "10100";
  constant STX_i : opcode_t := "10101";
  constant JYY_i : opcode_t := "10110";
  constant RTN_i : opcode_t := "10111";
  constant END_i : opcode_t := "11000";
  constant NLL_i : opcode_t := "11001";
  constant POP_i : opcode_t := "11010";
  constant PSH_i : opcode_t := "11011";
  constant IN_i  : opcode_t := "11110";
  constant OUT_i : opcode_t := "11111";
  

  type alu_op is (
       ADD_OP,
       SUB_OP,  
       MULT_OP,  
       DIV_OP,   
       REM_OP,   
       AND_OP,   
       OR_OP,    
       XOR_OP,   
       INV_OP,   
       INC_OP,   
       DEC_OP,   
       ZRO_OP,   
       PASS_A,   
       PASS_B,   
       SHR_ARTH, 
       SHR_LGC,  
       SHL_ARTH, 
       SHL_LGC,  
       ROTR,     
       ROTL);

  -- declare the type memContents_t (Memory contents) as an array of data words
  -- add code here
  --type memContents_t is array(4095 downto 0) of std_logic_vector(DATA_WIDTH - 1 downto 0);
  type memContents_t is array(natural range<>) of std_logic_vector(DATA_WIDTH - 1 downto 0);

  -- similarly, declare the type regArray_t (Register array) as an array of 
  -- data words 
  -- add code here      
  type regArray_t is array(natural range<>) of std_logic_vector(DATA_WIDTH -1 downto 0);

               
  function MultL (L, R : signed) return signed;

  function is_pos (N : signed) return boolean;
  
  function truncated (arg: signed; short: positive) return boolean;
   
  function log2 (arg : integer) return integer;


end package;

package body micro_pk is 
   
  function MultL (L, R : signed) return signed is
  begin
    return  (resize (L, L'length/2) * resize (R, R'length/2));
  end function;

  -- Write the body of the function is_pos
  -- add code here    
  function is_pos(N : signed) return boolean is
  begin
     return (N > 0);
  end function;

  
  function truncated (arg: signed; short: positive) return boolean is
    variable res : signed (arg'length - 1 downto 0);
  begin
    res := arg;
    for i in res'left - 1 downto short - 1 loop
      if res (i) /= res (res'left) then
        return TRUE;
      end if;
    end loop;
    return FALSE;
  end function; 
  
  function log2 (arg : integer) return integer is
    variable temp : integer;
  begin
    temp := 2;
    for i in 1 to 31 loop
      if (temp > arg) then
        return i;
      end if;
      temp := temp + temp;
    end loop;
    return 32;
  end function;


end package body;

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
 -- File           : tb_micro_pk.vhd
 -----------------------------------------------------------------------------
 -- Description : This package contains definitions of the types, subtypes, 
 -- functions and procedures utilized by different entities.
 -- --------------------------------------------------------------------------
 -- Author         : Geert Vanwijnsberghe
 -- Date           : 30/11/2006
 -- Version        : 1.1
 -- Change history : 
 ----------------------------------------------------------------------------- 
 -- This code was developed by Osman Allam during an internship at IMEC, 
 -- in collaboration with Geert Vanwijnsberghe, Tom Tassignon en Steven 
 -- Redant. The purpose of this code is to teach students good VHDL coding
 -- style for writing complex behavioural models.
 -----------------------------------------------------------------------------
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.micro_pk.all;


entity tb_micro_pk is
end entity;

architecture test of tb_micro_pk is
  signal DW : integer:=32;
  signal AW : integer:=12;
  constant mem1 : memContents_t (0 to 2) := (
         0 => "10110000000001000000000000000000",
         1 => "00000000000000000000001000000000",
         2 => "00000000000000000000000001000001");
  constant mem2 : memContents_t (0 to 1) := (
         0 => "11110000111001000000000000000000",
         1 => "11000000000000000000001000000000");
  constant mem3 : regArray_t (0 to 2) := (
         0 => "10110000000001000000000000000000",
         1 => "00000000000000000000001000000000",
         2 => "00000000000000000000000001000001");
  constant mem4 : regArray_t (0 to 1) := (
         0 => "11110000111001000000000000000000",
         1 => "11000000000000000000001000000000");
  constant vec1 : signed(3 downto 0):="1100";
  constant vec2 : signed(3 downto 0):="0101";       
  constant vec3 : signed(0 to 3):="1110"; 
  constant vec4 : signed(0 to 3):="0111";

begin             
  check:process
  begin
   report " -- Check start --"; 
   assert DW = DATA_WIDTH 
     report " DATA_WIDTH not correct"
     severity error;
   assert AW = ADDR_WIDTH
     report " ADDR_WIDTH not correct" 
     severity error;
   assert not is_pos(vec1) 
     report " is_pos returns true for vector 1100 "
     severity error;
   assert is_pos(vec2) 
     report " is_pos returns false for vector 0101 "
     severity error;
   assert not is_pos(vec3) 
     report " is_pos returns true for vector 1110 "
     severity error;
   assert is_pos(vec4) 
     report " is_pos returns false for vector 0111 "
     severity error;
   report " -- Check done --";   
   wait;    
end process check;

end test;

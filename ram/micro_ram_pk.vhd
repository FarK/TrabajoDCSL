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
-- Project     : Micro6
-- Author         : Osman Allam
-- File           : micro_ram_pk.vhd
-- Design : Initial memory contents
----------------------------------------------------------------------------- 
-- Description : This package defines the initial memory contents.
-- This package is used for behavioural simulation.
-- This file is generated by the VAS assembler.
----------------------------------------------------------------------------- 
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use WORK.micro_pk.all;

package micro_ram_pk is

	constant RAM_CONTENTS : memContents_t (0 to 2 ** ADDR_WIDTH - 1);

end package;
------------------------------------------------------------------------------
package body micro_ram_pk is

	constant RAM_CONTENTS : memContents_t (0 to 2 ** ADDR_WIDTH - 1) := (
	0 => "10110000000001000000000000000000",
	1 => "00000000000000000000001000000000",
	2 => "00000000000000000000000001000001",
	3 => "00000000000000000000001111101000",
	4 => "00000000000000000000000000000001",
	5 => "00000000000000000000000000010100",
	512 => "10011000000010000000000000000000",
	513 => "11111000000001000000000000000000",
	514 => "10011000000011000000000000000000",
	515 => "11111100111110000000000000000000",
	516 => "10011000000100000000000000000000",
	517 => "11111000111110000000000000000000",
	518 => "10011000000101000000000000000000",
	519 => "11111000111111000000000000000000",
	520 => "11110000000000001000000000000001",
	521 => "11111000000001000000000000100000",
	522 => "11111000000001000000000000100000",
	523 => "11111000000001000000000000100000",
	524 => "11000000000000000000000000000000",
	1000 => "00000000000000000000000000000101",
	1001 => "00000000000000000000000000000101",
	1002 => "00000000000000000000000000000001",
	1003 => "00000000000000000000000000000011",
	1004 => "00000000000000000000000000000110",
	1005 => "00000000000000000000000000000010",
	1006 => "00000000000000000000000000000101",
	1007 => "00000000000000000000000000000101",
	1008 => "00000000000000000000000000000001",
	1009 => "00000000000000000000000000000011",
	1010 => "00000000000000000000000000000110",
	1011 => "00000000000000000000000000000010",
	1012 => "00000000000000000000000000000101",
	1013 => "00000000000000000000000000000101",
	1014 => "00000000000000000000000000000001",
	1015 => "00000000000000000000000000000011",
	1016 => "00000000000000000000000000000110",
	1017 => "00000000000000000000000000000010",
	1018 => "00000000000000000000000000000101",
	1019 => "00000000000000000000000000000101",
	1020 => "00000000000000000000000000000001",
	others => (others => '0'));
end package body;

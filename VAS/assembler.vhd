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
-- File        : assembler.vhd
-- Design      : Assembler for Micro6
-- -----------------------------------------------------------------------------
-- Description : The assembler translates assembly programs and generates
-- program and data memory contetns
-- -----------------------------------------------------------------------------

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use STD.textio.all;
use IEEE.std_logic_textio.all;

use WORK.micro_pk.all;
use WORK.micro_control_pk.all;
use WORK.assembler_pk.all;

entity assembler is
	generic (useTestData : boolean := true);
end entity;

architecture simple of assembler is  
begin
	process 
		file programFile : text open read_mode is "prog.asm";
		file programFile2 : text open read_mode is "prog.asm";
		file testDataFile : text open read_mode is "data.asm";
		file programMem : text open write_mode is "micro_ram_pk.vhd";
		file ramPkTop : text open read_mode is "micro_ram_pk_top.vhd";
		file ramPkBottom : text open read_mode is "micro_ram_pk_bottom.vhd";
		file coeTop : text open read_mode is "ram_top.coe";
		file coe : text open write_mode is "ram.coe";

		variable cl	: line; -- current line (reading)
		variable cl2 : line;
		variable cl3 : line;
		variable wl : line; -- write line
		variable coeLine : line;
		variable err : error_t;
		variable lt : line_t;
		variable ln : natural := 0;
		variable id : identifier_t;
		variable data : std_logic_Vector (31 downto 0);
		variable c : character;
		variable id_table : identifier_table_t (0 to 63);
		variable page_0_addr : natural range 0 to 511;
		variable progMemAddr : natural;
		variable testDataAddr : natural;
		variable readLabelsComplete : boolean := false;

		-- type coeTable_t is array (natural range <>) of natural;
		variable coeTable : memContents_t (PAGE_0_OFFSET to 4096);
	begin
		page_0_addr := PAGE_0_OFFSET;
		progMemAddr := PROGRAM_MEMORY;

		for i in id_table'range loop
			id_table(i).free := true;
		end loop;


		coeTable := (others => std_logic_vector (to_unsigned (0, 32)));

		copyFile (ramPkTop, programMem);
		copyFile (coeTop, coe);
		wrBoot (programMem);
		wrBootCoe (coe);

		-- first pass
		while (not endfile (programFile)) loop
			ln := ln + 1;
			id.id := (others => nul);
			readline (programfile, cl2);
			if (cl2 /= null) then
				rdLineType (cl2, ln, lt, c, err);
				case lt is 
					when declaration | comment | blank_line =>
						next;
					when lbl => 
						rdIdentifier (cl2, ln, id.id, err);
						id.id_val := progMemAddr;
						data := std_logic_vector (to_signed (progMemAddr, data'length));
						wrMemWord (wl, page_0_addr, data);
						coeTable (page_0_addr) := data;
						writeline (programMem, wl);
						id.memLocation := page_0_addr;
						id.free := false;
						pushIdentifier (id, id_table);
						page_0_addr := page_0_addr + 1;
					when statement =>
						progMemAddr := progMemAddr + 1;
				end case;
			end if;
		end loop;

		ln := 0;
		progMemAddr := PROGRAM_MEMORY;
		readLabelsComplete := true;

		-- second pass
		while (readLabelsComplete and (not endfile (programFile2))) loop
			ln := ln + 1;
			id.id := (others => nul);
			readline (programFile2, cl);
			if (cl /= null) then
				rdLineType (cl, ln, lt, c, err);
				case lt is
					when declaration =>
						rdDeclaration (cl, ln, id, id_table, data);
						wrMemWord (wl, page_0_addr, data);
						coeTable (page_0_addr) := data;
						id.memLocation := page_0_addr;
						pushIdentifier (id, id_table);
						page_0_addr := page_0_addr + 1;
					when comment =>
						rdComment (cl, ln, err);
						next;
					when statement =>
						rdStatement (cl, ln, c, id_table, err, data);
						wrMemWord (wl, progMemAddr, data);
						coeTable (progMemAddr) := data;
						progMemAddr := progMemAddr + 1;
					when blank_line | lbl =>
						next;
				end case;
				writeline (programMem, wl);
			end if;
		end loop;

		-- test data
		while (not endfile (testDataFile) and useTestData) loop
			readline (TestDataFile, cl3);
			if (cl3 /= null) then
				rdTestData (cl3, testDataAddr, err, data);
				if (err /= none) then next; end if;
				wrMemWord (wl, testDataAddr, data);
				coeTable (testDataAddr) := data;
				writeline (programMem, wl);
			end if;
		end loop;

		copyFile (ramPkBottom, programMem);

		for i in coeTable'range loop
			write (coeLine, coeTable (i));
			if (i < coeTable'high - 1) then
				write (coeLine, comma);
				writeline (coe, coeLine);
			else
				write (coeLine, semi_colon);
				writeline (coe, coeLine);
				exit;
			end if;
		end loop;

		wait;
	end process;
end architecture;

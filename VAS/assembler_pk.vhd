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
-- File        : assembler_pk.vhd
-- Design      : Assembler package
-- -----------------------------------------------------------------------------
-- Description : Package containing declartions for the assembler
-- -----------------------------------------------------------------------------

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use STD.textio.all;
use IEEE.std_logic_textio.all;

use WORK.micro_pk.all;
use WORK.micro_control_pk.all;

package assembler_pk is
  constant MAX_IDNETIFIER : natural := 511;
  constant MAX_ID_LENGTH : natural := 12;
  constant PAGE_0_OFFSET : natural := 2;
  constant PROGRAM_MEMORY : natural := 512; -- starting address of the program
  constant assignment : string (1 to 4) := " => ";
  constant doubleQuote : character := '"';
  constant comma : character := ',';
  constant semi_colon : character := ';';
  constant indent : positive;
  constant BRA_instruction : std_logic_vector (31 downto 0) := 
      "10110000000001000000000000000000";
  
  constant MAX_PROGRAM_SIZE : natural := 8192;
  constant MAX_MEMORY_SIZE : natural := 65536;
  
  type identifier_t is record
    id : string (1 to MAX_ID_LENGTH);
    id_val : integer;
    free : boolean;
    memLocation : natural;
  end record;
  
  type identifier_table_t is array (natural range <>) of identifier_t;
  
  type line_t is (declaration, statement, comment, blank_line, lbl);
  
  type error_t is (none, syntax_error, invalid_identifier, invalid_integer,
    invalid_register, identifier_not_found, invalid_line, invalid_comment,
    invalid_device);
        
    
  procedure wrBoot (
    file f : text);
  ------------------------------------------------------------------------------
  procedure wrBootCoe (
    file f : text);
  ------------------------------------------------------------------------------
  procedure wrMemWord (
    wl : inout line;
    MemLocation : natural;
    data : std_logic_vector);
  ------------------------------------------------------------------------------
  procedure wrCoeWord (
    coeline : inout line;
    data : std_logic_vector);
  ------------------------------------------------------------------------------
  procedure rdIdentifier (
    L : inout line;
    ln : in natural;
    id : out string (1 to MAX_ID_LENGTH);
    err : inout error_t);
  ------------------------------------------------------------------------------
  procedure rdIdentifier (
    L : inout line;
    ln : in natural;
    c : inout character;
    id : out string (1 to MAX_ID_LENGTH);
    err : inout error_t);
  ------------------------------------------------------------------------------
  procedure rdLineType (
    L : inout line;
    ln : natural;
    lt : out line_t;
    c : inout character;
    err : inout error_t);
  ------------------------------------------------------------------------------
  procedure pushIdentifier (
    arg : in identifier_t;
    table : inout identifier_table_t);
  ------------------------------------------------------------------------------
  procedure rdComment (
    L : inout line;
    ln : in natural;
    err : inout error_t);
  ------------------------------------------------------------------------------
  procedure rdDeclaration (
    L : inout line;
    ln : in natural;
    id : inout identifier_t;
    id_table : inout identifier_table_t;
    instrWord : out std_logic_vector (31 downto 0));
  ------------------------------------------------------------------------------
  procedure rdStatement (
    L : inout line;
    ln : in natural;
    c : in character;
    id_table : in identifier_table_t;
    err : inout error_t;
    instrWord : out std_logic_vector (31 downto 0));
  ------------------------------------------------------------------------------
  procedure copyFile (
    file source : text;
    file destination : text);
  ------------------------------------------------------------------------------
  procedure rdTestData (
    L : inout line; 
    testDataAddr : out natural;
    err : inout error_t;
    data : out std_logic_vector (31 downto 0));
  ------------------------------------------------------------------------------
end package;
-- =============================================================================
package body assembler_pk is
  constant indent : positive := 8;
  ------------------------------------------------------------------------------
  procedure skip_blanks (
    L : inout line;
    c : inout character) is
    
    variable readok : boolean;
    
  begin
    loop
      read(L,c, readok);
      exit when ((readOk = FALSE) or ((c /= ' ') and (c /= CR) and (c /= HT)));
    end loop;
    if not readok then
      c := nul;
    end if;
  end procedure;
  ------------------------------------------------------------------------------
  procedure pushIdentifier (
    arg : in identifier_t;
    table : inout identifier_table_t) is
    
    begin
    for i in table'range loop
      if table(i).free then
        table (i) := arg;
        exit;
      end if;
    end loop;    
  end procedure;
  ------------------------------------------------------------------------------
  procedure matchIdentifier (
    arg : in identifier_t;
    table : in identifier_table_t;
    match : out boolean;
    memLocation : out integer) is
        
  begin
    match := false;
    for i in table'range loop
      if (table(i).id = arg.id) then
        match := true;
        memLocation := table(i).memLocation;
      end if;
      exit when (table(i).free);
    end loop;
  end procedure;
  ------------------------------------------------------------------------------
  procedure matchIdentifier2 (
    arg : in identifier_t;
    table : in identifier_table_t;
    match : out boolean;
    d : out integer) is
        
  begin
    match := false;
    for i in table'range loop
      if (table(i).id = arg.id) then
        match := true;
        d := table(i).id_val;
      end if;
      exit when (table(i).free);
    end loop;
  end procedure;
  ------------------------------------------------------------------------------
  procedure printError (
    ln : in natural;
    err : in error_t) is
  begin
    case err is
    when syntax_error =>
      report ("line " & integer'image (ln) & ": Syntax Error");
    when invalid_identifier =>
      report ("line " & integer'image (ln) & ": Invalid identifier");
    when invalid_integer =>
      report ("line " & integer'image (ln) & ": Invalid integer");
    when invalid_register =>
      report ("line " & integer'image (ln) & ": Invalid register");
    when identifier_not_found =>
      report ("line " & integer'image (ln) & ": Identifier not found");
    when invalid_line =>
      report ("line " & integer'image (ln) & ": Invalid line");
    when invalid_comment =>
      report ("line " & integer'image (ln) & ": Invalid comment");
    when invalid_device =>
      report ("line " & integer'image (ln) & ": Invalid device");
    when none =>
      null;
    end case;
  end procedure;
  ------------------------------------------------------------------------------
  procedure wrBoot (
    file f : text) is
    
    variable wl : line;
    constant BRA_instruction : std_logic_vector (31 downto 0) := 
      "10110000000001000000000000000000";
    variable progMem_0 : std_logic_vector (31 downto 0);
    
  begin
  
    progMem_0 := std_logic_vector (to_unsigned (
      PROGRAM_MEMORY, progMem_0'length));
      
    write (wl, integer'image (0), right, indent);
    write (wl, assignment);
    write (wl, doubleQuote);
    write (wl, BRA_instruction);
    write (wl, doubleQuote);
    write (wl, comma);
    writeline (f, wl);
    
    write (wl, integer'image (1), right, indent);
    write (wl, assignment);
    write (wl, doubleQuote);
    write (wl, progMem_0);
    write (wl, doubleQuote);
    write (wl, comma);
    writeline (f, wl);
    
  end procedure;
  ------------------------------------------------------------------------------
  procedure wrBootCoe (
    file f : text) is
    
    variable wl : line;
  begin
    write (wl, BRA_instruction, right, indent);
    write (wl, comma);
    writeline (f, wl);
    
    write (wl, std_logic_vector (to_unsigned (PROGRAM_MEMORY, 32)), 
      right, indent);
    write (wl, comma);
    writeline (f, wl);
  end procedure;
  ------------------------------------------------------------------------------    
  procedure copyFile (
    file source : text;
    file destination : text) is
  
    variable l : line;
    variable readok : boolean;
    
  begin
    while not endfile (source) loop
      readline (source, l);
      writeline (destination, l);
    end loop;
  end procedure;
  ------------------------------------------------------------------------------
  procedure wrMemWord (
    wl : inout line;
    MemLocation : natural;
    data : std_logic_vector) is
    
  begin 
    write (wl, integer'image (MemLocation), right, indent);
    write (wl, assignment);
    write (wl, doubleQuote);
    write (wl, data);
    write (wl, doubleQuote);
    write (wl, comma);
  end procedure;
  ------------------------------------------------------------------------------
  procedure wrCoeWord (
    coeline : inout line;
    data : std_logic_vector) is
    
  begin
    write (coeline, data, right, indent);
    write (coeline, comma);
  end procedure;
  ------------------------------------------------------------------------------
  procedure rdLineType (
    L : inout line;
    ln : natural;
    lt : out line_t;
    c : inout character;
    err : inout error_t) is
    
    variable readok : boolean;
    
  begin
    err := none;
    skip_blanks (L, c);
    case c is
    when '.' => 
      lt := declaration;
    when '-' =>
      lt := comment;
    when 'A' | 'B' | 'C' | 'D' | 'E' | 'I' |'J' | 'L' | 'N' | 
      'O' | 'P' | 'R' | 'S' | 'Z' | 'X' =>
      lt := statement;
    when nul =>
      lt := blank_line;
    when '$' =>
      lt := lbl;
    when others =>
      err := invalid_line;
    end case;
    printError (ln, err);
  end procedure;
  ------------------------------------------------------------------------------
  procedure rdComment (
    L : inout line;
    ln : in natural;
    err : inout error_t) is
    
    variable c : character;
    variable readok : boolean;
  
  begin
    err := none;
    read (L, c, readok);
    if readok then
      if (c /= '-') then
        err := invalid_comment;
      end if;
    else 
      err := syntax_error;
    end if;
    printError (ln, err);
  end procedure;
  ------------------------------------------------------------------------------
  procedure rdInteger (
    L : inout line;
    ln : natural;
    int : out integer;
    err : inout error_t) is
    
    variable c : character;
    variable readok : boolean;
    
  begin
    err := none;
    skip_blanks (L, c);
    if (c = '#') then
      read (L, int, readok);
      if not readok then
        err := invalid_integer;
      end if;
    else 
      err := syntax_error;
    end if;
    printError (ln, err);
  end procedure;        
  ------------------------------------------------------------------------------
  procedure rdInteger (
    L : inout line;
    ln : natural;
    c : inout character;
    int : out integer;
    err : inout error_t) is
    
    variable readok : boolean;
    
  begin
    err := none;
    if (c = '#') then
      read (L, int, readok);
      if not readok then
        err := invalid_integer;
      end if;
    else 
      err := syntax_error;
    end if;
    printError (ln, err);
  end procedure; 
  ------------------------------------------------------------------------------
  procedure rdIdentifier (
    L : inout line;
    ln : in natural;
    id : out string (1 to MAX_ID_LENGTH);
    err : inout error_t) is
  
    variable c : character;
    variable readok : boolean;
    
  begin
    err := none;
    skip_blanks (L, c);
    id (1) := c;
    for i in id'range loop 
      read (L, c, readok);
      exit when ((c = ' ') or (c = CR) or (c = HT) or (c = ';') or (c = ':'));
      id (i + 1) := c;
      next when (i < MAX_ID_LENGTH + 1);
      err := invalid_identifier; -- too long identitfier
    end loop;
    printError (ln, err);
  end procedure;
  ------------------------------------------------------------------------------
  procedure rdIdentifier (
    L : inout line;
    ln : natural;
    c : inout character;
    id : out string (1 to MAX_ID_LENGTH);
    err : inout error_t) is
    
    variable readok : boolean;
    
  begin
    err := none;
    id (1) := c;
    for i in id'range loop 
      read (L, c, readok);
      exit when ((c = ' ') or (c = CR) or (c = HT));
      id (i + 1) := c;
      next when (i < MAX_ID_LENGTH + 1);
      err := invalid_identifier; -- too long identitfier
    end loop;
    printError (ln, err);
  end procedure;
  ------------------------------------------------------------------------------ 
  procedure rdRegister (
    L      : inout line;
    ln : natural;
    xACC    : out std_logic;
    regSel : out std_logic_vector (4 downto 0);
    err : inout error_t) is
    
    variable c : character;
    variable c2 : string (1 to 2);
    variable int : integer;
    variable readok : boolean;
  begin
    err := none;
    skip_blanks (L, c);
    if (c = 'A') or (c = 'a') then
      read (L, c2, readok);
      if readok then
        case c2 is
        when "cc" | "cC" | "Cc" | "CC" =>
          xACC := '1';
          regSel := "00000";
        when others =>
          err := invalid_register;
        end case;
      else
        err := syntax_error;
      end if;
    elsif (c = 'R') or (c = 'r') then
      read (L, int, readok);
      if readok then
        xACC := '0';
        regSel := std_logic_vector (to_unsigned (int, regSel'length));
      else 
        err := syntax_error;
      end if;
      else
        err := invalid_register;
    end if;
    printError (ln, err);
  end procedure;
  ------------------------------------------------------------------------------
  procedure rdRegister (
    L      : inout line;
    ln : natural;
    regSel : out std_logic_vector (4 downto 0);
    err : inout error_t) is
    
    variable c : character;
    variable int : integer;
    variable readok : boolean;
  begin
    err := none;
    skip_blanks (L, c);
    if (c = 'R') or (c = 'r') then
      read (L, int, readok);
      if readok then
        regSel := std_logic_vector (to_unsigned (int, regSel'length));
      else 
        err := syntax_error;
      end if;
      else 
        err := invalid_register;
    end if;
    printError (ln, err);
  end procedure;
  ------------------------------------------------------------------------------
  procedure rdRegister (
    L      : inout line;
    ln : natural;
    c : inout character;
    regSel : out std_logic_vector (4 downto 0);
    err : inout error_t) is
    
    variable int : integer;
    variable readok : boolean;
  begin
    err := none;
    if (c = 'R') or (c = 'r') then
      read (L, int, readok);
      if readok then
        regSel := std_logic_vector (to_unsigned (int, regSel'length));
      else 
        err := syntax_error;
      end if;
      else 
        err := invalid_register;
    end if;
    printError (ln, err);
  end procedure;
  ------------------------------------------------------------------------------
  procedure rdInx (
    L : inout line;
    ln : natural;
    inx : out std_logic_vector (1 downto 0);
    err : inout error_t) is
    
    variable int : integer;
    variable c : character;
    variable readok : boolean;
    
  begin
    err := none;
    skip_blanks (L, c);
    case c is
    when 'i' | 'I' =>
      read (L, int, readok);
      if readok then
        inx := std_logic_vector (to_unsigned (int, inx'length));
      else 
        err := syntax_error;
      end if;
    when others =>
      err := syntax_error;
    end case;
    printError (ln, err);
  end procedure;
  ------------------------------------------------------------------------------
  procedure rdDevice (
    L      : inout line;
    ln : natural;
    c : inout character;
    device : out std_logic_vector (5 downto 0);
    err : inout error_t) is
    
    variable int : integer;
    variable readok : boolean;
  begin
    err := none;
    if (c = 'D') or (c = 'd') then
      read (L, int, readok);
      if readok then
        device := std_logic_vector (to_unsigned (int, device'length));
      else 
        err := syntax_error;
      end if;
      else 
        err := invalid_device;
    end if;
    printError (ln, err);
  end procedure;
  ------------------------------------------------------------------------------
  procedure rdEndOfStatement (
    L: inout line; 
    ln : natural;
    c : inout character;
    ret: out boolean) is
    
  begin
    skip_blanks (L, c);
    ret := (c = ';'); -- true when end of line
  end procedure;
  ------------------------------------------------------------------------------
  procedure rdDeclaration (
    L : inout line;
    ln : in natural;
    id : inout identifier_t;
    id_table : inout identifier_table_t;
    instrWord : out std_logic_vector (31 downto 0)) is
    
    variable c : character;
    variable readok : boolean;
    variable err : error_t;
    
  begin
    id.id_val := 0;
    rdIdentifier (L, ln, id.id, err);
    rdInteger (L, ln, id.id_val, err);
    id.free := false; 
    instrWord := std_logic_vector (to_signed (id.id_val, DATA_WIDTH));
    
  end procedure;
  ------------------------------------------------------------------------------
  procedure rdFormat1 (
    L : inout line;
    ln : natural;
    format : out std_logic_vector (26 downto 0)) is
    
    -- left operand is port A of the register file or the accumulator
    alias aAcc        : std_logic is format (17);
    -- right operand is port B of the register file or the accumulator
    alias bAcc        : std_logic is format (16);
    -- store the result
    alias storeC      : std_logic is format (15);
    alias Asel        : std_logic_vector (4 downto 0) is format (14 downto 10);
    alias Bsel        : std_logic_vector (4 downto 0) is format (9 downto 5);
    alias Csel        : std_logic_vector (4 downto 0) is format (4 downto 0);
    
    variable end_t : boolean;
    variable err : error_t;
    variable c : character;
  
  begin
    format (26 downto 18) := (others => '0'); -- not used
    
    rdRegister (L, ln, aAcc, Asel, err);
    rdRegister (L, ln, bAcc, Bsel, err);
    rdEndOfStatement (L, ln, c, end_t);
    if end_t then
      storeC := '0';
      Csel := "00000";
    else
      rdRegister (L, ln, c, Csel, err);
      storeC := '1';
    end if;
    
    rdEndOfStatement (L, ln, c, end_t);
    if not end_t then
      err := syntax_error;
    end if;
  end procedure;
  ------------------------------------------------------------------------------
  procedure rdFormat2 (
    L : inout line;
    ln : natural;
    format : out std_logic_vector (26 downto 0)) is
    
    -- left operand is port A of the register file or the accumulator
    alias aAcc        : std_logic is format (17);
    -- store the result
    alias Asel        : std_logic_vector (4 downto 0) is format (14 downto 10);
    alias Csel        : std_logic_vector (4 downto 0) is format (4 downto 0);
    
    variable end_t : boolean;
    variable err : error_t;
    variable c : character;
    variable Asel_temp : std_logic_vector (Asel'range);
  begin
    format (26 downto 18) := (others => '0'); -- not used
    format (16) := '0';
    format (9 downto 5) := (others => '0');
    format (15) := '0';
    
    rdRegister (L, ln, aAcc, Asel_temp, err);
    Asel := Asel_temp;
    rdEndOfStatement (L, ln, c, end_t);
    if end_t then
      Csel := Asel_temp;
    else
      rdRegister (L, ln, c, Csel, err);
    end if;
    
    rdEndOfStatement (L, ln, c, end_t);
    if not end_t then
      err := syntax_error;
    end if;
    
  end procedure;
  ------------------------------------------------------------------------------
  procedure rdFormat3 (
    L : inout line;
    ln : natural;
    shiftDirect : in std_logic;
    format : out std_logic_Vector (26 downto 0)) is
    
    -- left operand is port A of the register file or the accumulator
    alias aAcc        : std_logic is format (17);
    -- store the result
    alias storeC      : std_logic is format (15);
    alias Asel        : std_logic_vector (4 downto 0) is format (14 downto 10);
    alias Bsel        : std_logic_vector (4 downto 0) is format (9 downto 5);
    alias Csel        : std_logic_vector (4 downto 0) is format (4 downto 0);
    -- (*) shiftCntSrc:
    -- when 0, the shift count is the input shiftCnt, otherwise, it is the least 
    -- significant slice of the input b.
    alias shiftCntSrc : std_logic is format (24); 
    -- shift count
    alias shiftCnt    : std_logic_vector (4 downto 0) is format (22 downto 18);
    
    variable end_t : boolean;
    variable err : error_t;
    variable c : character;
    variable int : integer;
    
  begin
    format (23) := shiftDirect;
    format (26 downto 25) := (others => '0'); -- not used
    format (16) := '0'; -- not used either
    
    rdRegister (L, ln, aAcc, Asel, err);
    skip_blanks (L, c);
    case c is
    when 'R' | 'r' =>
      rdRegister (L, ln, c, Bsel, err);
      shiftCntSrc := '1';
      shiftCnt := (others => '0');
    when '#' =>
      rdInteger (L, ln, c, int, err);
      shiftCntSrc := '0';
      shiftCnt := std_logic_vector (to_unsigned (int, shiftCnt'length));
      Bsel := (others => '0');
    when others =>
      err := syntax_error;
    end case;
    rdEndOfStatement (L, ln, c, end_t);
    if end_t then
      storeC := '0';
      Csel := "00000";
    else
      rdRegister (L, ln, c, Csel, err);
      storeC := '1';
    end if;
    
    rdEndOfStatement (L, ln, c, end_t);
    if not end_t then
      err := syntax_error;
    end if;
  end procedure;       
  ------------------------------------------------------------------------------
  procedure rdFormat4 (
    L : inout line;
    ln : natural;
    format : out std_logic_vector (26 downto 0)) is
    
    alias Asel        : std_logic_vector (4 downto 0) is format (14 downto 10);
    alias Csel        : std_logic_vector (4 downto 0) is format (4 downto 0);
    alias storeC      : std_logic is format (15);
    
    variable end_t : boolean;
    variable err : error_t;
    variable c : character;
    
  begin
    format (26 downto 16) := (others => '0'); -- not used
    format (9 downto 0) := (others => '0'); -- not used either
    storeC := '1';
    
    rdRegister (L, ln, Asel, err);
    rdRegister (L, ln, Csel, err);
    
    rdEndOfStatement (L, ln, c, end_t);
    if not end_t then
      err := syntax_error;
    end if;
  end procedure;
  ------------------------------------------------------------------------------
  procedure rdFormat5 (
    L : inout line;
    ln : natural;
    format : out std_logic_vector (26 downto 0)) is
    
    alias Asel        : std_logic_vector (4 downto 0) is format (14 downto 10);
    alias Csel        : std_logic_vector (4 downto 0) is format (4 downto 0);
    -- indexing bits
    alias inx         : std_logic_vector (1 downto 0) is format (26 downto 25);
    
    variable end_t : boolean;
    variable err : error_t;
    variable c : character;
    
  begin
    format (24 downto 16) := (others => '0'); -- not used
    format (9 downto 5) := (others => '0'); -- not used either
    format (15) := '0';
    
    rdRegister (L, ln, Asel, err);
    rdInx (L, ln, inx, err);
    rdRegister (L, ln, Csel, err);
    
    rdEndOfStatement (L, ln, c, end_t);
    if not end_t then
      err := syntax_error;
    end if;
  end procedure;
  ------------------------------------------------------------------------------
  procedure rdFormat6 (
    L : inout line;
    ln : natural;
    format : inout std_logic_vector (26 downto 0);
    table : identifier_table_t) is
    
    alias Csel      : std_logic_vector (4 downto 0) is format (4 downto 0);
    alias shortAddr : std_logic_vector (SHORT_DATA - 1 downto 0) 
      is format (26 downto 18);
      
    variable end_t : boolean;
    variable err : error_t;
    variable c : character;
    variable id : identifier_t;   
    variable match : boolean;   
    variable memLocation : natural;
  begin
    format (17 downto 5) := (others => '0');
    
    rdIdentifier (L, ln, id.id, err);
    matchIdentifier (id, table, match, memLocation);
    if match then
      shortAddr := std_logic_vector 
        (to_unsigned (memLocation, shortAddr'length));
    else
      err := identifier_not_found;
    end if;
    rdRegister (L, ln, Csel, err);
    
    rdEndOfStatement (L, ln, c, end_t);
    if not end_t then
      err := syntax_error;
    end if;
  end procedure;
  ------------------------------------------------------------------------------
  procedure rdFormat7 (
    L : inout line;
    ln : natural;
    format : inout std_logic_vector (26 downto 0)) is
    
    -- left operand is port A of the register file or the accumulator
    alias aAcc        : std_logic is format (17);
    -- right operand is port B of the register file or the accumulator
    alias bAcc        : std_logic is format (16);
    
    alias Asel        : std_logic_vector (4 downto 0) is format (14 downto 10);
    alias Bsel        : std_logic_vector (4 downto 0) is format (9 downto 5);
    
    variable end_t : boolean;
    variable err : error_t;
    variable c : character;
    
  begin
    format (26 downto 18) := (others => '0'); -- not used
    format (15) := '0'; -- storeC
    format (4 downto 0) := (others => '0'); -- not used either
    
    rdRegister (L, ln, bAcc, Bsel, err);
    rdRegister (L, ln, aAcc, Asel, err);
    
    rdEndOfStatement (L, ln, c, end_t);
    if not end_t then
      err := syntax_error;
    end if;
  end procedure;
  ------------------------------------------------------------------------------
  procedure rdFormat8 (
    L : inout line;
    ln : natural;
    format : inout std_logic_vector (26 downto 0)) is
    
    alias Bsel        : std_logic_vector (4 downto 0) is format (9 downto 5);
    alias Asel        : std_logic_vector (4 downto 0) is format (14 downto 10);
    -- indexing bits
    alias inx         : std_logic_vector (1 downto 0) is format (26 downto 25);
    
    variable end_t : boolean;
    variable err : error_t;
    variable c : character;
    
  begin
    format (24 downto 16) := (others => '0'); -- not used
    format (4 downto 0) := (others => '0');
    format (15) := '0';
    
    rdRegister (L, ln, Bsel, err);
    rdInx (L, ln, inx, err);
    rdRegister (L, ln, Asel, err);
    
    rdEndOfStatement (L, ln, c, end_t);
    if not end_t then
      err := syntax_error;
    end if;
  end procedure;
  ------------------------------------------------------------------------------
  procedure rdFormat9 (
    L : inout line;
    ln : natural;
    format : inout std_logic_vector (26 downto 0)) is
    
    alias aAcc        : std_logic is format (17);
    alias Asel        : std_logic_vector (4 downto 0) is format (14 downto 10);
    alias Csel        : std_logic_vector (4 downto 0) is format (4 downto 0);
    
    variable end_t : boolean;
    variable err : error_t;
    variable c : character;
    
  begin
    format (26 downto 18) := (others => '0');
    format (16 downto 15) := "00";
    format (9 downto 5) := (others => '0');
    
    rdRegister (L, ln, aAcc, Asel, err);
    Csel := Asel;
        
    rdEndOfStatement (L, ln, c, end_t);
    if not end_t then
      err := syntax_error;
    end if;
  end procedure; 
  ------------------------------------------------------------------------------
  procedure rdFormat10 (
    L : inout line;
    ln : natural;
    format : inout std_logic_vector (26 downto 0)) is
  
    variable c : character;
    variable end_t : boolean;
    variable err : error_t;
    
  begin
    format := (others => '0');
    rdEndOfStatement (L, ln, c, end_t);
    if not end_t then
      err := syntax_error;
    end if;
  end procedure; 
  ------------------------------------------------------------------------------
  procedure rdFormat11 (
    L : inout line;
    ln : natural;
    format : inout std_logic_vector (26 downto 0);
    table : identifier_table_t) is
    
    alias shortAddr : std_logic_vector (SHORT_DATA - 1 downto 0) 
      is format (26 downto 18);
      
    variable end_t : boolean;
    variable err : error_t;
    variable c : character;
    variable id : identifier_t;   
    variable match : boolean;   
    variable memLocation : natural;
  begin
    format (17 downto 0) := (others => '0');
    
    rdIdentifier (L, ln, id.id, err);
    matchIdentifier (id, table, match, memLocation);
    if match then
      shortAddr := std_logic_vector 
        (to_unsigned (memLocation, shortAddr'length));
    else
      err := identifier_not_found;
    end if;
    
    rdEndOfStatement (L, ln, c, end_t);
    if not end_t then
      err := syntax_error;
    end if;
  end procedure;
  ------------------------------------------------------------------------------
  procedure rdFormat12 (
    L : inout line;
    ln : natural;
    format : out std_logic_vector (26 downto 0)) is
    
    alias deviceID    : std_logic_vector (5 downto 0) is format (23 downto 18);
    alias Csel        : std_logic_vector (4 downto 0) is format (4 downto 0);
    alias storeC      : std_logic is format (15);
    
    variable end_t : boolean;
    variable err : error_t;
    variable c : character;
    variable d : integer;
    
  begin
    format := (others => '0'); 
    storeC := '1';
    
    skip_blanks (L, c);
    rdDevice (L, ln, c, deviceID, err);
    rdRegister (L, ln, Csel, err);
    
    rdEndOfStatement (L, ln, c, end_t);
    if not end_t then
      err := syntax_error;
    end if;
  end procedure;
  ------------------------------------------------------------------------------
  procedure rdFormat13 (
    L : inout line;
    ln : natural;
    format : out std_logic_vector (26 downto 0)) is
    
    alias deviceID    : std_logic_vector (5 downto 0) is format (23 downto 18);
    alias bAcc        : std_logic is format (16);
    alias Bsel        : std_logic_vector (4 downto 0) is format (9 downto 5);
    alias storeC      : std_logic is format (15);
    
    
    variable end_t : boolean;
    variable err : error_t;
    variable c : character;
    
  begin
    format (26 downto 16) := (others => '0'); -- not used
    format (9 downto 0) := (others => '0'); -- not used either
    format (4 downto 0) := (others => '0');
    format (14 downto 10) := (others => '0');
    storeC := '0';
        
    skip_blanks (L, c);
    rdDevice (L, ln, c, deviceID, err);
    rdRegister (L, ln, bAcc, Bsel, err);
    
    rdEndOfStatement (L, ln, c, end_t);
    if not end_t then
      err := syntax_error;
    end if;
  end procedure;
  ------------------------------------------------------------------------------
  procedure rdStatement (
    L : inout line;
    ln : in natural;
    c : in character;
    id_table : in identifier_table_t;
    err : inout error_t;
    instrWord : out std_logic_vector (31 downto 0)) is
    
    variable readok : boolean;
    variable mnemonic : string (1 to 3);
    variable end_t : boolean;
    
    variable format : std_logic_Vector (26 downto 0);
    
    variable opcode      : opcode_t;
    alias shiftDirect : std_logic is format (23);
    -- shift direction
    -- Use stack: '1' for jump instruction. '0' for branch instruction
    alias STKen       : std_logic is format (0);
    -- condition mask
    alias cmask       : std_logic_Vector (5 downto 0) is format (6 downto 1);
    
  begin
    mnemonic (1) := c;
    read (L, mnemonic (2 to 3), readok);
    if readok then
      case mnemonic is
      when "ADD" =>
        opcode := ADD_i;
        rdFormat1 (L, ln, format);
      when "SUB" =>
        opcode := SUB_i;
        rdFormat1 (L, ln, format);
      when "INC" =>
        opcode := INC_i;
        rdFormat2 (L, ln, format);
      when "DEC" =>
        opcode := DEC_i;
        rdFormat2 (L, ln, format);
      when "ZRO" =>
        opcode := ZRO_i;
        rdFormat2 (L, ln, format);
      when "AND" =>
        opcode := AND_i;
        rdFormat1 (L, ln, format);
      when "OR " =>
        opcode := OR_i;
        rdFormat1 (L, ln, format);
      when "NOT" =>
        opcode := NOT_i;
        rdFormat2 (L, ln, format);
      when "XOR" =>
        opcode := XOR_i;
        rdFormat1 (L, ln, format);
        
      when "CPR" =>
        opcode := CPR_i;
        rdFormat2 (L, ln, format);
        
      when "SRA" =>
        opcode := SHA_i;
        shiftDirect  := DIR_RIGHT;
        rdFormat3 (L, ln, shiftDirect, format); 
      when "SRL" =>
        opcode := SHL_i;
        shiftDirect  := DIR_RIGHT;
        rdFormat3 (L, ln, shiftDirect, format); 
      when "SLA" =>
        opcode := SHA_i;
        shiftDirect  := DIR_LEFT;
        rdFormat3 (L, ln, shiftDirect, format); 
      when "SLL" =>
        opcode := SHL_i;
        shiftDirect  := DIR_LEFT;
        rdFormat3 (L, ln, shiftDirect, format); 
      when "RTR" =>
        opcode := ROT_i;
        shiftDirect  := DIR_RIGHT;
        rdFormat3 (L, ln, shiftDirect, format); 
      when "RTL" =>
        opcode := ROT_i;
        shiftDirect  := DIR_LEFT;
        rdFormat3 (L, ln, shiftDirect, format); 
        
      when "CMP" =>
        opcode := CMP_i;
        rdFormat1 (L, ln, format);
      when "LD " =>
        opcode := LD_i;
        rdFormat4 (L, ln, format);
      when "LDX" =>
        opcode := LDX_i;
        rdFormat5 (L, ln, format);
      when "LDM" =>
        opcode := LDM_i;
        rdFormat6 (L, ln, format, id_table);
      when "ST " =>
        opcode := ST_i;
        rdFormat7 (L, ln, format);
      when "STX" =>
        opcode := STX_i;
        rdFormat8 (L, ln, format);
      when "PSH" =>
        opcode := PSH_i;
        rdFormat9 (L, ln, format);
      when "POP" =>
        opcode := POP_i;
        rdFormat9 (L, ln, format);
        
      when "BRA" =>
        opcode    := JYY_i;
        rdFormat11 (L, ln, format, id_table);
        cmask := "000000";
        STKen    := '0';
      when "JSR" =>
        opcode    := JYY_i;
        rdFormat11 (L, ln, format, id_table);
        cmask := "000000";
        STKen    := '1';
      when "BGT" =>
        opcode    := JYY_i;
        rdFormat11 (L, ln, format, id_table);
        cmask := "000101";
        STKen    := '0';
      when "JGT" =>
        opcode    := JYY_i;
        rdFormat11 (L, ln, format, id_table);
        cmask := "000101";
        STKen    := '1';
      when "BLT" =>
        opcode    := JYY_i;
        rdFormat11 (L, ln, format, id_table);
        cmask := "100100";
        STKen    := '0';
      when "JLT" =>
        opcode    := JYY_i;
        rdFormat11 (L, ln, format, id_table);
        cmask := "100100";
        STKen    := '1';
      when "BEQ" =>
        opcode    := JYY_i;
        rdFormat11 (L, ln, format, id_table);
        cmask := "001001";
        STKen    := '0';
      when "JEQ" =>
        opcode    := JYY_i;
        rdFormat11 (L, ln, format, id_table);
        cmask := "001001";
        STKen    := '1';
      when "BNQ" =>
        opcode    := JYY_i;
        rdFormat11 (L, ln, format, id_table);
        cmask := "000001";
        STKen    := '0';
      when "JNQ" =>
        opcode    := JYY_i;
        rdFormat11 (L, ln, format, id_table);
        cmask := "000001";
        STKen    := '1';
      when "BGE" =>
        opcode    := JYY_i;
        rdFormat11 (L, ln, format, id_table);
        cmask := "000100";
        STKen    := '0';
      when "JGE" =>
        opcode    := JYY_i;
        rdFormat11 (L, ln, format, id_table);
        cmask := "000100";
        STKen    := '1';
      when "BV " =>
        opcode    := JYY_i;
        rdFormat11 (L, ln, format, id_table);
        cmask := "010010";
        STKen    := '0';
      when "JV " =>
        opcode    := JYY_i;
        rdFormat11 (L, ln, format, id_table);
        cmask := "010010";
        STKen    := '1';
      when "BNV" =>
        opcode    := JYY_i;
        rdFormat11 (L, ln, format, id_table);
        cmask := "000010";
        STKen    := '0';
      when "JNV" =>
        opcode    := JYY_i;
        rdFormat11 (L, ln, format, id_table);
        cmask := "000010";
        STKen    := '1';
        
      when "RTN" =>
        opcode := RTN_i;
        rdFormat10 (L, ln, format);
      when "END" =>
        opcode := END_i;
        rdFormat10 (L, ln, format);
      when "NLL" =>
        opcode := NLL_i;
        rdFormat10 (L, ln, format);
        
      -- IO instructions
      when "INB" => -- INput Byte
        opcode := IN_i;
        rdFormat12 (L, ln, format);
        format (26) := '0';
      when "INW" => -- INput Word
        opcode := IN_i;
        rdFormat12 (L, ln, format);
        format (26) := '1';
      when "OUB" => -- OUtput Byte
        opcode := OUT_i;
        rdFormat13 (L, ln, format);
        format (26) := '0';
      when "OUW" => -- OUtput Word
        opcode := OUT_i;
        rdFormat13 (L, ln, format);
        format (26) := '1';
        
        
      
        
      when others =>
        err := syntax_error;
      end case;
      instrWord := opcode & format;
    else
      report ("line " & integer'image (ln) & ": Invalid instruction");
    end if;
    
  end procedure;
  ------------------------------------------------------------------------------
  procedure rdTestData (
    L : inout line; 
    testDataAddr : out natural;
    err : inout error_t;
    data : out std_logic_vector (31 downto 0)) is
  
  variable c : character;
  variable ln : natural;
  variable int : integer;
  variable err2 : error_t;
  
  begin
    skip_blanks (L, c);
    rdInteger (L, ln, c, int, err);
    if (err /=none) then return; end if;
    testDataAddr := int;
    skip_blanks (L, c);
    skip_blanks (L, c);
    rdInteger (L, ln, c, int, err2);
    data := std_logic_vector (to_signed (int, data'length));
  end procedure;
end package body;

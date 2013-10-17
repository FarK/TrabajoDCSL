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
 -- File           : regfile.vhd
--------------------------------------------------------------------------------
-- Description : 
-- -----------------------------------------------------------------------------
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
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use WORK.micro_pk.all;
use WORK.micro_comp_pk.all;

entity regFile is
  port (
    rst    : in std_logic;
    clk    : in std_logic;
    busC   : in std_logic_vector (DATA_WIDTH - 1 downto 0);
    stkInc : in std_logic;
    stkDec : in std_logic;
    wr     : in std_logic;
    selA   : in std_logic_vector (4 downto 0);
    selB   : in std_logic_vector (4 downto 0);
    selC   : in std_logic_vector (4 downto 0);
    busA   : out std_logic_vector (DATA_WIDTH - 1 downto 0);
    busB   : out std_logic_vector (DATA_WIDTH - 1 downto 0));
end entity;

architecture struct of regFile is
  signal reg_int : regArray_t (0 to 31); -- internal bus
  -- regArray_t is an array of 
  -- std_logic_vector (DATA_WIDTH - 1 downto 0) and is declared in the 
  -- package micro_pk. Make sure it is compiled successfully in the 
  -- current working library before you compile this file. 
  
  -- individual clock enable signals for each register
  signal regEn   : std_logic_vector (2 ** selC'length - 1 downto 0);
  
begin
  -- This process decodes selC input and generates the individual 
  -- enable signals
  process (selC, wr)
  begin
    for i in regEn'range loop 
      if (i = to_integer (selC)) then
        regEn (i) <= '1' and wr;
      else 
        regEn (i) <= '0';
      end if;
    end loop;
  end process;
  
  -- 28 General purpose registers R0 to R27
  -- Hint: use a GENERATE statement to instantiate 28 registers
  --       reg_int(0) .. reg_int(27) must be driven here
  --       the input bus is busC
  --       the enable signals are regEn (0) .. regEn (27)
  -- add code here
    
  -- Index register IX0 
  -- Hint: use the following port associations for 'd' and 'q' ports
  --   d   => busC (SHORT_DATA - 1 downto 0)
  --   q   => reg_int (28)(SHORT_DATA - 1 downto 0)
  --   The enable is regEn (28)
  -- add code here

  
    
  -- Index register IX1
  -- Hint: use the following port associations for 'd' and 'q' ports
  --   d   => busC (SHORT_DATA - 1 downto 0)
  --   q   => reg_int (28)(SHORT_DATA - 1 downto 0)
  -- add code here

  
  
  -- Index register IX2
  -- Hint: use the following port associations for 'd' and 'q' ports
  --   d   => busC (SHORT_DATA - 1 downto 0)
  --   q   => reg_int (28)(SHORT_DATA - 1 downto 0)
  -- add code here

  
  
  -- Memory stack pointer (updown counter)
  -- Hint: use the following port associations for 'd' and 'q' ports
  --   d   => busC (SHORT_DATA - 1 downto 0)
  --   q   => reg_int (28)(SHORT_DATA - 1 downto 0)
  -- add code here

    
  reg_int (28)(DATA_WIDTH - 1 downto SHORT_DATA) <= (others => '0');
  reg_int (29)(DATA_WIDTH - 1 downto SHORT_DATA) <= (others => '0');
  reg_int (30)(DATA_WIDTH - 1 downto SHORT_DATA) <= (others => '0');
  reg_int (31)(DATA_WIDTH - 1 downto SHORT_DATA) <= (others => '1');
   
  -- Connect the internal bus (reg_int) to the two output buses (busA, busB)
  -- remember that the output register is selected by the selection lines
  -- (selA, selB) respectively. 
  busA <= reg_int (to_integer (selA));
  busB <= reg_int (to_integer (selB));
  
end architecture;
  
    

  
  
  
          
    

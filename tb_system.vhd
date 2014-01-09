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
-- Author      : Geert Vanwijnsberghe
-- File        : tb_system.vhd
-- Design      : testbench for system
--------------------------------------------------------------------------------
-- Description : test of memory
-- -----------------------------------------------------------------------------
-- History :
--  13/12/06 : vwb : generation
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity tb_system is
end entity;

architecture test of tb_system is
  signal clk          : std_logic;
  signal rst          : std_logic;
  
  signal EndOfSim    : boolean := false;
  constant clkPeriod : time := 10 ns;
  constant dutyCycle : real := 0.5; 

  component system 
  port (
    rst : std_logic;
    clk : std_logic);
  end component;
  
 
begin
  uut: system 
  port map (
    clk   => clk,
    rst   => rst
  );
    
  -- Clock Generation process
  clock: process
  begin
    clk <= '0';
    wait for (1.0 - dutyCycle) * clkPeriod;
    clk <= '1';
    wait for dutyCycle * clkPeriod;
    if EndOfSim then -- The simulation EndOfSims due to event starvation
      wait;
    end if;
  end process; 
  
  main: process
  begin
    -- Initial inputs
    rst <= '1';
    wait for 5* clkPeriod;
    rst <= '0';

    wait;   -- simulation is stopped by a breakpoint that is set when the last instruction "END;" is executed  
  end process;
  
  
end architecture;

  
  
    
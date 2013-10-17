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
-- File        : tb_regfile.vhd
-- Design      : Register file
--------------------------------------------------------------------------------
-- Description : test of Register file contains general purpose registers, index 
-- registers and a stack register.
-- -----------------------------------------------------------------------------
-- History :
--  4/12/06 : vwb : alligned all inputs to falling edge of clk
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.micro_pk.all;
use work.micro_comp_pk.all;

entity tb_regfile is
end entity;

architecture test of tb_regfile is
  signal rst, clk : std_logic;
  signal busC : std_logic_vector (DATA_WIDTH - 1 downto 0);
  signal stkInc, stkDec : std_logic;
  signal wr : std_logic;
  signal selA, selB, selC : std_logic_vector (4 downto 0);
  signal busA, busB : std_logic_vector (DATA_WIDTH - 1 downto 0);
  
  signal EndOfSim : boolean := false;
  constant clkPeriod : time := 10 ns;
  constant dutyCycle : real := 0.5; 
  
  -- Note: every procedure starts and ends at falling edge of clk
  
  procedure read_reg (
    regSel : natural;
    v_exp : std_logic_vector;
    signal selX : out std_logic_vector;
    signal busX : in std_logic_vector) is
  begin
    selX <= std_logic_vector (to_unsigned (regSel, selX'length));
    wait until falling_edge (clk);
    assert (busX = v_exp) 
      report "Error reading from register R" & natural'image (regSel);
  end procedure;
  
  procedure write_reg (
    regSel : natural;
    data : std_logic_vector;
    signal wr : out std_logic;
    signal sel : out std_logic_vector;
    signal busC : out std_logic_vector) is
  begin
    sel <= std_logic_vector (to_unsigned (regSel, sel'length));
    busC <= data;
    wait until falling_edge (clk);
    wr <= '1';
    wait until falling_edge (clk);
    wr <= '0';
  end procedure;
  
  procedure genPulse (
    signal stk : out std_logic) is
  begin
    wait until falling_edge (clk);
    stk <= '1';
    wait until falling_edge (clk);
    stk <= '0';
  end procedure;
  
  procedure test_reset (
    signal rst : out std_logic;
    signal selA, selB : out std_logic_vector
    ) is
  begin
    rst <= '1';
    wait until falling_edge (clk);
    rst <= '0';
    
    for i in 0 to 30 loop
      read_reg (i, x"00000000", selA, busA);
      read_reg (i, x"00000000", selB, busB);
    end loop;
    
    read_reg (31, x"FFFFFE00", selA, busA);
    read_reg (31, x"FFFFFE00", selB, busB);    
    
  end procedure;
  
  procedure test_stack (
    signal stkInc, stkDec : out std_logic;
    signal selA, selB : out std_logic_vector
    ) is
    variable sp : std_logic_vector (DATA_WIDTH - 1 downto 0);
  begin
    selA <= "11111"; -- select the stack pointer
    wait until falling_edge (clk);
    sp := busA;
    for i in 1 to 10 loop
      genPulse (stkInc);
      sp := std_logic_vector(unsigned(sp) + 1);
      read_reg (31, sp, selA, busA);
      read_reg (31, sp, selB, busB);
    end loop;
    
    for i in 1 to 10 loop
      genPulse (stkDec);
      sp := std_logic_vector(unsigned(sp) - 1);
      read_reg (31, sp, selA, busA);
      read_reg (31, sp, selB, busB);
    end loop;
  end procedure;
  
  procedure test_register (
    signal selA, selB : out std_logic_vector;
    signal wr : out std_logic;
    signal selC : out std_logic_vector;
    signal busC : out std_logic_Vector
    ) is
    subtype oneRegister is std_logic_vector (DATA_WIDTH - 1 downto 0);
    type regFileContenets_t is array (natural range <>) of oneRegister;
    constant regFileContents : regFileContenets_t := (
      x"A19552FD", -- R0
      x"9EF6FB55", -- R1
      x"4C04DEA1", -- R2
      x"DC08CF31", -- R3
      x"3F6060F6", -- R4
      x"3F6060F3", -- R5
      x"7972E965", -- R6
      x"4716F93F", -- R7
      x"79019686", -- R8
      x"148B4F8C", -- R9
      x"C18BDF16", -- R10
      x"25B59B39", -- R11
      x"790622EB", -- R12
      x"D9AF52D2", -- R13
      x"3931A277", -- R14
      x"26EF437B", -- R15
      x"A05DE48E", -- R16
      x"25B3D2B2", -- R17
      x"5CABFD99", -- R18
      x"2A2D534B", -- R19
      x"25DCAB42", -- R20
      x"A05DE0B1", -- R21
      x"0429E405", -- R22
      x"3F605D7B", -- R23
      x"4C04DC03", -- R24
      x"A0645AF6", -- R25
      x"15C4BCB0", -- R26
      x"79063AF9", -- R27
      x"26EF437B", -- R28 (I1)
      x"8558289B", -- R29 (I2)
      x"432389FE"); -- R30 (I3)
    variable indexRegister : oneRegister;
  begin
    -- Writing all registers expect the Stack Pointer (R31)
    for i in 0 to 30 loop
      write_reg (i, regFileContents (i), wr, selC, busC);
    end loop;
    
    -- Reading all General Purpose Registers (R0 to R27)
    for i in 0 to 27 loop
      read_reg (i, regFileContents (i), selA, busA);
      read_reg (i, regFileContents (i), selB, busB);
    end loop;
    
    -- Reading all Index Register (R28 to R30);
    for i in 28 to 30 loop
      indexRegister (DATA_WIDTH - 1 downto SHORT_DATA) := (others => '0');
      indexRegister (SHORT_DATA - 1 downto 0) := 
        regFileContents (i)(SHORT_DATA - 1 downto 0);
      read_reg (i, indexRegister, selA, busA);
      read_reg (i, indexRegister, selB, busB);
    end loop;
  end procedure;
  
begin
  uut: regFile port map (
    rst    => rst,
    clk    => clk,
    busC   => busC,
    stkInc => stkInc,
    stkDec => stkDec,
    wr     => wr,
    selA   => selA,
    selB   => selB,
    selC   => selC,
    busA   => busA,
    busB   => busB);
    
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
  
  process
  begin
    -- Initial inputs
    rst <= '0';
    wr <= '0';
    stkInc <= '0';
    stkDec <= '0';
    selA <= (others => '0');
    selB <= (others => '0');
    selC <= (others => '0');
    busC <= (others => '0');
    wait until falling_edge (clk); -- allign inputs to falling_edge of clk
    test_reset (rst, selA, selB); 
    test_register (selA, selB, wr, selC, busC);
    test_stack (stkInc, stkDec, selA, selB);  
    EndOfSim <= true;
    report " Test done";
    wait;
  end process;
end architecture;

  
  
    
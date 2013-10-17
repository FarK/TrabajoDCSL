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
 -- File           : tb_mux.vhd
 -----------------------------------------------------------------------------
 -- Description    : testbench for multiplexer
 -- --------------------------------------------------------------------------
 -- Author         : Geert Vanwijnsberghe
 -- Date           : 1/12/2006
 -- Version        : 1.1
 -- Change history : 
 ----------------------------------------------------------------------------- 
 -- This code was developed by Osman Allam during an internship at IMEC, 
 -- in collaboration with Geert Vanwijnsberghe, Tom Tassignon en Steven 
 -- Redant. The purpose of this code is to teach students good VHDL coding
 -- style for writing complex behavioural models.
 -----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity tb_mux is
end entity;

architecture test of tb_mux is

  component mux4xbus
    port (
      inport0 : in std_logic_vector;
      inport1 : in std_logic_vector;
      inport2 : in std_logic_vector;
      inport3 : in std_logic_vector;
      sel : in std_logic_vector (1 downto 0);
      outport : out std_logic_vector);
  end component;
  
  component mux2xbus
    port (
      inport0 : in std_logic_vector;
      inport1 : in std_logic_vector;
      sel     : in std_logic;
      outport : out std_logic_vector);
  end component;

  signal bus0 : std_logic_vector(3 downto 0);
  signal bus1 : std_logic_vector(3 downto 0);
  signal bus2 : std_logic_vector(3 downto 0);
  signal bus3 : std_logic_vector(3 downto 0);    
  signal bus4 : std_logic_vector(3 downto 0);
  signal busi : std_logic_vector(3 downto 0);
  signal busout : std_logic_vector(3 downto 0);  
  signal sel1 : std_logic;
  signal sel2 : std_logic_vector(1 downto 0);
    
    
begin
 
  U1 : mux2xbus
  port map(
    inport0 => busi,
    inport1 => bus4,
    sel     => sel1,
    outport => busout
  );
  
  U2 : mux4xbus
  port map(
    inport0 =>bus0,
    inport1 =>bus1,
    inport2 =>bus2,
    inport3 =>bus3,
    sel     =>sel2,
    outport =>busi
  );

  main: process
  begin
    bus0 <= "0000";
    bus1 <= "0001";
    bus2 <= "0010";
    bus3 <= "0100";
    bus4 <= "1000";
    sel1 <= '0';
    sel2 <= "00";
    wait for 10 ns;
    sel1 <= '1';
    wait for 10 ns;
    sel2 <= "00";
    wait for 10 ns;
    sel2 <= "01";
    wait for 10 ns;
    sel2 <= "10";
    wait for 10 ns;
    sel2 <= "11";    
    wait for 10 ns;
    sel1 <= '0';
    wait for 10 ns;
    sel2 <= "00";
    wait for 10 ns;
    sel2 <= "01";
    wait for 10 ns;
    sel2 <= "10";
    wait for 10 ns;
    sel2 <= "11"; 
    wait for 10 ns;
    bus3 <= "1111";
    wait for 10 ns;
    wait;
  end process main;   
   
end architecture;

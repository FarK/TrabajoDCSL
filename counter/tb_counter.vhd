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
 -- File           : tb_counter.vhd
 -----------------------------------------------------------------------------
 -- Description    : 
 -- --------------------------------------------------------------------------
 -- Author         : Geert Vanwijnsberghe
 -- Date           : 4/12/2006
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

entity tb_counter is
end entity;

architecture test of tb_counter is

   type vector_out_type  is array(0 to 13) of std_logic_vector(7 downto 0);
   constant vec_out : vector_out_type := (
    "UUUUUUUU",
    "UUUUUUUU",
    "00000000",
    "00000000",
    "00000000",
    "00110100",
    "00110100",
    "00110101",
    "00110101",
    "00110110",
    "00110111",
    "00110111",
    "00110100",
    "00110100");

   signal  rst : std_logic;         
   signal  clk : std_logic;         
   signal  d   : std_logic_vector(7 downto 0);  
   signal  ld  : std_logic;         
   signal  inc : std_logic;         
   signal  q   : std_logic_vector(7 downto 0);
   signal EndOfSim : boolean:=false;
   
  component counter
    port (
      rst : in std_logic;
      clk : in std_logic;
      d   : in std_logic_vector;
      ld  : in std_logic;
      inc : in std_logic;
      q   : out std_logic_vector
     );
  end component;

  procedure GenClock (signal   clk       : out std_logic;
                      constant startlevel: in std_logic; -- '0' | '1'
                      constant CLKPeriod : in time;
                      signal   EndOfSim  : in boolean
                      ) is
  begin
      loop
        exit when EndOfSim;
        clk <= startlevel;
        wait for CLKPeriod / 2;
        exit when EndOfSim;
        clk <= not startlevel;
        wait for CLKPeriod - (CLKPeriod / 2); 
      end loop;
      wait; 
  end procedure GenClock;
  
begin

U1 : counter
  port map(
    rst =>rst ,
    clk =>clk ,
    d   =>d   ,
    ld  =>ld  ,
    inc =>inc ,
    q   =>q  
  );



GenClock(clk,'1',10 ns,EndOfSim);

main: process
begin
  d <= std_logic_vector(to_unsigned(52,8));
  rst <= '0';
  ld <= '0';
  inc <= '0';
  wait for 25 ns;
  rst <='1';
  wait for 10 ns;
  rst <= '0';
  wait for 10 ns;
  ld <='1';
  wait for 10 ns;
  ld <='0';
  wait for 10 ns;
  inc <='1';
  wait for 10 ns;
  inc <='0';
  wait for 10 ns;
  inc <='1';
  wait for 20 ns;
  inc <='0';
  wait for 10 ns;
  inc <= '1';
  ld <= '1';
  wait for 10 ns;
  inc <= '0';
  ld <= '0'; 
  wait for 10 ns; 
  
  EndOfSim <= true;
  wait;
end process main;

verify: process
begin
  for i in 0 to 13 loop
    wait until falling_edge(clk);
    wait for 1 ns;
    assert q = vec_out(i)
      report "Wrong q"
      severity error;
  end loop; 
  wait;
end process verify;


end architecture;

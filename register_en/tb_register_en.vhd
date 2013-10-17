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
 -- File           : tb_register_en.vhd
 -----------------------------------------------------------------------------
 -- Description : This testbench verifies the register_en
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
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;




entity tb_register_en is
end entity;

architecture test of tb_register_en is
  signal clk : std_logic;
  signal rst : std_logic;
  signal en  : std_logic;
  signal d   : std_logic_vector(7 downto 0);
  signal q   : std_logic_vector(7 downto 0);

  component register_en 
  port (
    rst : in std_logic;
    clk : in std_logic;
    en  : in std_logic;
    d   : in std_logic_vector;
    q   : out std_logic_vector);
  end component;
  
begin 

  -- Instantiation of register_en
  U1 : register_en 
  port map (
    rst => rst,
    clk => clk,
    en  => en,
    d   => d,
    q   => q);

            
  check:process
  begin
   report " -- Check start --"; 
   clk <= '0';
   rst <= '0';
   en  <= '0';
   d   <= std_logic_vector(to_signed(50,8)); 
   wait for 1 ns; 
   assert q = (q'range =>'U') 
     report " wrong initial q"
     severity error;
   wait for 9 ns;
   clk <= '1';
   wait for 0 ns; 
   assert q = (q'range =>'U') 
     report " wrong initial q"
     severity error;
   wait for 5 ns;
   rst <='1';
   wait for 1 ns; 
   assert q = (q'range =>'0') 
     report " asynchronous reset does not work"
     severity error;     
   wait for 4 ns;
   clk <= '0';
   d   <= std_logic_vector(to_signed(25,8)); 
   wait for 0 ns;
   assert q = (q'range =>'0') 
     report " q not ok"
     severity error; 
   wait for 10 ns;
   clk <='1';
   wait for 0 ns;
   assert q = (q'range =>'0') 
     report " q not ok"
     severity error; 
   wait for 5 ns;
   rst <= '0';
   d   <= std_logic_vector(to_signed(40,8)); 
   wait for 0 ns;
   assert q = (q'range =>'0') 
     report " q not ok"
     severity error; 
   wait for 5 ns;
   clk <= '0'; 
   wait for 0 ns;
   assert q = (q'range =>'0') 
     report " q not ok"
     severity error;     
   wait for 10 ns;
   clk <= '1';
   wait for 0 ns;
   assert q = (q'range =>'0') 
     report " q not ok"
     severity error;   
   wait for 5 ns;
   en <= '1';
   wait for 0 ns;
   assert q = (q'range =>'0') 
     report " q not ok"
     severity error;   
   wait for 5 ns;
   clk <= '0';
   d   <= std_logic_vector(to_signed(10,8)); 
   wait for 0 ns;
   assert q = (q'range =>'0') 
     report " q not ok"
     severity error;   
   wait for 10 ns;
   clk <= '1';
   wait for 1 ns;
   assert q = d 
     report " q was not updated to the value of d"
     severity error;   
   wait for 4 ns;
   en <= '0';
   wait for 0 ns;
   assert q = d 
     report " q not ok"
     severity error;   
   wait for 5 ns;
   clk <= '0';
   wait for 0 ns;
   assert q = d 
     report " q not ok"
     severity error;    
   wait for 10 ns;
   report " -- Check done --";   
   wait;    
end process check;

end test;

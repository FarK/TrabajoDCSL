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
 -- Project     : Micro6 microprocessor
-- Author      : Osman Allam
-- File        : baud.vhd
-- Design      : Baud rate generator for the UART
--------------------------------------------------------------------------------
-- Description : Baud rate generator. Supports baud rate of 115Kbps for serial communications
-- -----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity baudRateGen is
  port (
    rst : in std_logic;
    clk : in std_logic;
    RxEna : out std_logic;
    TxEna : out std_logic);
end entity;

architecture behave of baudRateGen is
  signal clk1 : std_logic;
  signal clk2 : std_logic;
begin
  process (rst, clk)
    variable cnt1 : natural range 0 to 27;
    variable cnt2 : natural range 0 to 15;
  begin
    if (rst = '1') then
      clk1 <= '0';
      clk2 <= '0';
      cnt1 := 0;
      cnt2 := 0;
    elsif (rising_edge (clk)) then
      if (cnt1 = 27) then
        clk1 <= '1';
        cnt1 := 0;
      else
        clk1 <= '0';
        cnt1 := cnt1 + 1;
      end if;
      
      if (clk1 = '1') then
        if (cnt2 = 15) then
          clk2 <= '1';
          cnt2 := 0;
        else
          clk2 <= '0';
          cnt2 := cnt2 + 1;
        end if;
      else
        clk2 <= '0';
      end if;
    end if;
  end process;
  RxEna <= clk1;
  TxEna <= clk2;
end architecture;
        
   
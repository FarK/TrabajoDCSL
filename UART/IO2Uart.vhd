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
-- Author      : Geert Vanwijnsberghe
-- File        : IO2Uart.vhd
-- Design      : Simple I/O Unit to interface with MiniUart
-- -----------------------------------------------------------------------------
-- Description : I/O Unit 
-- --------------------------------------------------------------------------
-- Limitations :
--   only bytes supported
--   simple uart interface
--   error flags are not chekced
--   cpu_deviceID is not used

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.micro_pk.all;

entity IO2Uart is
  port (
    rst : in std_logic;
    clk : in std_logic;

    -- uart interface
    uart_cs_n    : out std_logic;
    uart_rd_n    : out std_logic;
    uart_wr_n    : out std_logic;
    uart_addr    : out  std_logic_vector (1 downto 0);
    uart_DataIn  : out  std_logic_vector (7 downto 0);
    uart_DataOut : in   std_logic_vector (7 downto 0);
    
    -- CPU interface
    cpu_MBRin   : out std_logic_vector (31 downto 0);
    cpu_MBRout  : in std_logic_vector (31 downto 0);    
    cpu_rd      : in std_logic;
    cpu_wr      : in std_logic;
    cpu_ready   : out std_logic;                     -- operation done
    cpu_deviceID: in std_logic_vector (5 downto 0)); -- device ID -- not used !!!
end entity;

-- miniUart 

-- uart_addr = "01" (read address)
--   bit 7 : x
--   bit 6 : x
--   bit 5 : x
--   bit 4 : x
--   bit 3 : Transmit buffer empty 
--   bit 2 : Receive Data ready
--   bit 1 : Receive Frame error
--   bit 0 : Receive Output error
-- uart_addr = "00" (read address)
--   received data


architecture behav of IO2Uart is
  type state_type is (idle,reading1,reading2,writing1);
  signal state: state_type;
begin

  process (rst, clk)
  begin
    if (rst = '1') then
      --
      state        <= idle;
      --
      uart_cs_n    <= '1';
      uart_rd_n    <= '1';
      uart_wr_n    <= '1';
      uart_addr    <= "01"; -- read status
      uart_DataIn  <= (others => '0');
      --
      cpu_MBRin    <= (others => '0');
      cpu_ready    <= '0';
    elsif (rising_edge (clk)) then
      case  state is
        when idle =>   
          uart_cs_n    <= '1';
          uart_rd_n    <= '1';
          uart_wr_n    <= '1';         
          uart_addr    <= "01";  -- read status  
          cpu_ready    <= '0';            
          if cpu_rd='1'  then    -- To read data from Uart : check data_available flag first
            if uart_DataOut(2) = '1' then
              state      <= reading1;
              uart_addr  <= "00";  -- read data
            end if;
          elsif cpu_wr='1'  then  -- to write data to Uart : check Transmit buffer empty first
            if uart_DataOut(3)= '1' then 
              uart_wr_n    <= '0';
              uart_cs_n    <= '0';
              uart_DataIn  <= cpu_MBRout(7 downto 0);
              state        <= writing1;
            end if;
          end if;
        when reading1 =>           -- Read data from Uart
            uart_rd_n    <= '0';
            uart_cs_n    <= '0';
            cpu_MBRin             <= (others =>'0');
            cpu_MBRin(7 downto 0) <= uart_DataOut;
            state <= reading2;
        when reading2 =>           -- Stop reading data from Uart and wait till cpu deasserts its read command
          uart_rd_n   <= '1';
          uart_cs_n   <= '1';
          cpu_ready   <= '1';
          if cpu_rd='0'  then
            state  <= idle; 
          end if;          
        when writing1 =>
          uart_wr_n    <= '1';
          uart_cs_n    <= '1';
          cpu_ready    <= '1';
          if cpu_wr='0'  then
            state   <= idle; 
          end if;
        when others =>
          state <= idle;       
      end case;
    end if;
  end process;
          
end architecture;
          
        
      
        
--===========================================================================--
--
--  S Y N T H E Z I A B L E    miniUART   C O R E
--
--  www.OpenCores.Org - January 2000
--  This core adheres to the GNU public license  
--
-- Design units   : miniUART core for the OCRP-1
--
-- File name      : miniuart.vhd
--
-- Purpose        : Implements an miniUART device for communication purposes 
--                  between the OR1K processor and the Host computer through
--                  an RS-232 communication protocol.
--                  
-- Library        : uart_lib.vhd
--
-- Dependencies   : IEEE.Std_Logic_1164
--
-- Simulator      : ModelSim PE/PLUS version 4.7b on a Windows95 PC
--===========================================================================--
-------------------------------------------------------------------------------
-- Revision list
-- Version   Author                 Date           Changes
--
-- 0.1      Ovidiu Lupas     15 January 2000       New model
-- 1.0      Ovidiu Lupas     January  2000         Synthesis optimizations
-- 2.0      Ovidiu Lupas     April    2000         Bugs removed - RSBusCtrl
--          the RSBusCtrl did not process all possible situations
--
--        olupas@opencores.org
-------------------------------------------------------------------------------
-- Description    : The memory consists of a dual-port memory addressed by
--                  two counters (RdCnt & WrCnt). The third counter (StatCnt)
--                  sets the status signals and keeps a track of the data flow.
-------------------------------------------------------------------------------
-- Entity for miniUART Unit -                                  --
-------------------------------------------------------------------------------
-- Code re-written by Osman Allam on 22 November 2005
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity miniUART is
  port (
    SysClk   : in  Std_Logic;  -- System Clock
    Reset    : in  Std_Logic;  -- Reset input
    CS_N     : in  Std_Logic; -- Chip Select (inverted)
    RD_N     : in  Std_Logic; -- ReaD (inverted)
    WR_N     : in  Std_Logic; -- WRite (inverted)
    RxD      : in  Std_Logic;
    TxD      : out Std_Logic;
    Addr     : in  Std_Logic_Vector(1 downto 0); 
    DataIn   : in  Std_Logic_Vector(7 downto 0); 
    DataOut  : out Std_Logic_Vector(7 downto 0));  
end entity; 

architecture uart of miniUART is
  signal RxData : Std_Logic_Vector(7 downto 0); -- 
  signal TxData : Std_Logic_Vector(7 downto 0); -- 
  signal CSReg  : Std_Logic_Vector(7 downto 0); -- Ctrl & status register
  --             CSReg detailed 
  -----------+--------+--------+--------+--------+--------+--------+--------+
  -- CSReg(7)|CSReg(6)|CSReg(5)|CSReg(4)|CSReg(3)|CSReg(2)|CSReg(1)|CSReg(0)|
  --   Res   |  Res   |  Res   |  Res   | UndRun | OvrRun |  FErr  |  OErr  |
  -----------+--------+--------+--------+--------+--------+--------+--------+
  signal EnabRx : Std_Logic;  -- Enable RX unit
  signal EnabTx : Std_Logic;  -- Enable TX unit
  signal DRdy   : Std_Logic;  -- Receive Data ready
  signal TRegE  : Std_Logic;  -- Transmit register empty
  signal TBufE  : Std_Logic;  -- Transmit buffer empty
  signal FErr   : Std_Logic;  -- Frame error
  signal OErr   : Std_Logic;  -- Output error
  signal Read   : Std_Logic;  -- Read receive buffer
  signal Load   : Std_Logic;  -- Load transmit buffer
  
  -- Baud rate Generator  
  component baudRateGen is
  port (
    rst : in std_logic;
    clk : in std_logic;
    RxEna : out std_logic;
    TxEna : out std_logic);
  end component;
  
  -- Receive Unit
  component RxUnit is
  port (
    Clk    : in  Std_Logic;  -- Clock signal
    Reset  : in  Std_Logic;  -- Reset input
    Enable : in  Std_Logic;  -- Enable input
    RxD    : in  Std_Logic;  -- RS-232 data input
    RD     : in  Std_Logic;  -- Read data signal
    FErr   : out Std_Logic;  -- Status signal
    OErr   : out Std_Logic;  -- Status signal
    DRdy   : out Std_Logic;  -- Status signal
    DataIn : out Std_Logic_Vector(7 downto 0));
  end component;
  
  -- Transmitter Unit
  component TxUnit is
  port (
    Clk    : in  Std_Logic;  -- Clock signal
    Reset  : in  Std_Logic;  -- Reset input
    Enable : in  Std_Logic;  -- Enable input
    Load   : in  Std_Logic;  -- Load transmit data
    TxD    : out Std_Logic;  -- RS-232 data output
    TRegE  : out Std_Logic;  -- Tx register empty
    TBufE  : out Std_Logic;  -- Tx buffer empty
    DataO  : in  Std_Logic_Vector(7 downto 0));
  end component;
begin

  -- Instantiation of internal components
  ClkDiv  : baudRateGen port map (Reset, SysClk, EnabRX,EnabTX);
  TxDev   : TxUnit port map (SysClk,Reset,EnabTX,Load,TxD,TRegE,TBufE,TxData);
  RxDev   : RxUnit port map (SysClk,Reset,EnabRX,RxD,Read,FErr,OErr,DRdy,RxData);
  
  -- Implements the controller for Rx&Tx units
  Status_reg: process (Reset, SysClk) 
  begin
    if (Reset = '1') then
      CSReg <= "11110000";
    elsif rising_edge (SysClk) then
      CSReg (0) <= OErr;
      CSReg (1) <= FErr;
      CSReg (2) <= DRdy;
      CSReg (3) <= TBufE;
    end if;
  end process; 
  
  -- Combinational section
  Read <= '1' when (CS_N = '0' and RD_N = '0') else '0';
  Load <= '1' when (CS_N = '0' and WR_N = '0') else '0';
  DataOut <= CSReg when (Addr = "01") else RxData;
  TxData <= DataIn;
  

 
   
end architecture;
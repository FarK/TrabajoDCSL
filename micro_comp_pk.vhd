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
-- File        : micro_comp_pk.vhd
-- Design      : Components package
--------------------------------------------------------------------------------
-- Description : This package declares all the components of the Micro6 project
-- -----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

use WORK.micro_pk.all;

--Library XilinxCoreLib;
--use XilinxCoreLib.all;

PACKAGE micro_comp_pk is


component cpu is
  port (
    rst      : in std_logic;
    clk      : in std_logic;
    -- Memory interface
    -- Data path
    rqDPT       : out std_logic;
    rdDPT       : out std_logic;
    wrDPT       : out std_logic;
    addrDPT     : out std_logic_vector (ADDR_WIDTH - 1 downto 0);
    inDPT       : in std_logic_vector (DATA_WIDTH - 1 downto 0);
    outDPT      : out std_logic_vector (DATA_WIDTH - 1 downto 0);
    memReadyDPT : in std_logic;
    -- Fetch unit
    rqFch       : out std_logic;
    rdFch       : out std_logic; 
    addrFch     : out std_logic_vector (ADDR_WIDTH - 1 downto 0);
    inFch       : in std_logic_vector (DATA_WIDTH - 1 downto 0);
    memReadyFch : in std_logic;
    -- IO Unit interface
    deviceID    : out std_logic_vector (5 downto 0);
    wordByte    : out std_logic;
    IORd        : out std_logic;
    IOWr        : out std_logic;
    IOReady     : in std_logic;
    IO_dataIn   : in std_logic_vector;
    IO_dataOut  : out std_logic_vector);
end component;

component regFile is
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
end component;

component fetch is
  port (
    rst       : in std_logic;
    clk       : in std_logic;
    memReady  : in std_logic;
    readInstr : in std_logic;
    memData   : in std_logic_vector (31 downto 0);
    vldInstr  : out std_logic;
    PCinc     : out std_logic;
    memRd     : out std_logic;
    IR        : out std_logic_vector (31 downto 0));
end component;

component control is
  port (
    rst         : in std_logic;
    clk         : in std_logic;
    instReg     : in std_logic_vector (DATA_WIDTH - 1 downto 0);
    cf          : in std_logic_vector (2 downto 0);
    memReady    : in std_logic;
    vldInstr    : in std_logic;
    readInstr   : out std_logic;
    -- Register file contrl lines
    RegFileWr   : out std_logic;
    selA        : out std_logic_Vector (4 downto 0);
    selB        : out std_logic_vector (4 downto 0);
    selC        : out std_logic_vector (4 downto 0);
    stkInc      : out std_logic;
    stkDec      : out std_logic;
    -- ALU control lines
    ALUsel      : out alu_op;
    shiftCnt    : out std_logic_vector (4 downto 0);
    shiftCntSrc : out std_logic;
    portAsel    : out std_logic;
    portBsel    : out std_logic;
    -- Data flow control lines
    ACCen       : out std_logic;
    CFen        : out std_logic;
    MARen       : out std_logic;
    MBRen       : out std_logic;
    PCen        : out std_logic;
    IRen        : out std_logic;
    DATAsel     : out std_logic_vector (1 downto 0);
    MBRsel      : out std_logic;
    -- Stack control lines
    STKen       : out std_logic;
    STKpop      : out std_logic;
    STKpush     : out std_logic;
    -- pag_0 address
    memAddr     : out std_logic_vector (ADDR_WIDTH - 1 downto 0);
    -- Memory control lines
    memRq       : out std_logic;
    memWr       : out std_logic; 
    memRd       : out std_logic;
    -- IO Unit interface
    IORd : out std_logic;
    IOWr : out std_logic;
    IOReady : in std_logic;
    IO2MBR : out std_logic
    );
end component;

component register_en is
  port (
    rst : in std_logic;
    clk : in std_logic;
    en  : in std_logic;
    d   : in std_logic_vector;
    q   : out std_logic_vector);
end component;

component mux2x1 is
  port (
    inport0 : in std_logic;
    inport1 : in std_logic;
    sel     : in std_logic;
    outport : out std_logic);
end component;

component mux2xbus is
  port (
    inport0 : in std_logic_vector;
    inport1 : in std_logic_vector;
    sel     : in std_logic;
    outport : out std_logic_vector);
end component;

component mux4x1 is
  port (
    inport0 : in std_logic;
    inport1 : in std_logic;
    inport2 : in std_logic;
    inport3 : in std_logic;
    sel     : in std_logic_vector (1 downto 0);
    outport : out std_logic);
end component;

component mux4xbus is
  port (
    inport0 : in std_logic_vector;
    inport1 : in std_logic_vector;
    inport2 : in std_logic_vector;
    inport3 : in std_logic_vector;
    sel : in std_logic_vector (1 downto 0);
    outport : out std_logic_vector);
end component;

component memCtrl is
  port (
    rst      : in std_logic;
    clk      : in std_logic;
    -- Data path
    rqDPT    : in std_logic;
    rdDPT    : in std_logic;
    wrDPT    : in std_logic;
    addrDPT  : in std_logic_vector;
    inDPT    : out std_logic_vector;
    outDPT   : in std_logic_vector;
    readyDPT : out std_logic;
    -- Fetch unit
    rqFch    : in std_logic;
    rdFch    : in std_logic; 
    addrFch  : in std_logic_vector;
    inFch    : out std_logic_vector;
    readyFch : out std_logic;
    -- I/O unit
    rqIO     : in std_logic;
    rdIO     : in std_logic;
    wrIO     : in std_logic;
    addrIO   : in std_logic_vector;
    inIO     : out std_logic_vector;
    outIO    : in std_logic_vector;
    readyIO  : out std_logic;
    -- control signals
    addr     : out std_logic_vector;
    dataIn   : out std_logic_vector;
    dataOut  : in std_logic_vector;
    memRd    : out std_logic;
    memWr    : out std_logic;
    memReady : in std_logic);
end component;

component stack is
  generic (depth : positive := 16);
  port (
    clk  : in std_logic;
    rst  : in std_logic;
    en   : in std_logic;
    d    : in std_logic_vector;
    push : in std_logic;
    pop  : in std_logic;
    q    : out std_logic_vector);
end component;

component counter is
  port (
    rst : in std_logic;
    clk : in std_logic;
    d   : in std_logic_vector;
    ld  : in std_logic;
    inc : in std_logic;
    q   : out std_logic_vector);
end component;

component counter_updown is
  port (
    rst : in std_logic;
    clk : in std_logic;
    d   : in std_logic_vector;
    ld  : in std_logic;
    inc : in std_logic;
    dec : in std_logic;
    q   : out std_logic_vector);
end component;

component alu is
  port (
  a           : in std_logic_vector (DATA_WIDTH - 1 downto 0); 
  b           : in std_logic_vector (DATA_WIDTH - 1 downto 0);
  sel         : in alu_op;
  shiftCnt    : in std_logic_vector (4 downto 0); -- shift count
  shiftCntSrc : in std_logic; -- shift count source (*)
  result      : out std_logic_vector (DATA_WIDTH - 1 downto 0);
  neg         : out std_logic; -- negative
  ovf         : out std_logic; -- overflow
  zro         : out std_logic  -- zero
  );
  -- (*) shiftCntSrc:
  -- when 0, the shift count is the input shiftCnt, otherwise, it is the least 
  -- significant slice of the input b.
end component;

component memory is
  port (
    clk     : in std_logic;
    inBus   : in std_logic_Vector (DATA_WIDTH - 1 downto 0);
    addr    : in std_logic_vector;
    rd      : in std_logic;
    wr      : in std_logic; 
    outBus  : out std_logic_Vector (DATA_WIDTH - 1 downto 0);
    ready   : out std_logic);
end component;

component micro6_ram IS
	port (
	addr: IN std_logic_VECTOR(11 downto 0);
	clk: IN std_logic;
	din: IN std_logic_VECTOR(31 downto 0);
	dout: OUT std_logic_VECTOR(31 downto 0);
	nd: IN std_logic;
	rfd: OUT std_logic;
	rdy: OUT std_logic;
	we: IN std_logic);
end component;

component main_mem IS
	port (
	addr: IN std_logic_VECTOR(11 downto 0);
	clk: IN std_logic;
	din: IN std_logic_VECTOR(31 downto 0);
	dout: OUT std_logic_VECTOR(31 downto 0);
	nd: IN std_logic;
	rfd: OUT std_logic;
	rdy: OUT std_logic;
	we: IN std_logic);
end component;

-- Memory Reader
component memReader is
  generic (memAddressWidth : natural := 12);
  port (
    rst : in std_logic;
    clk : in std_logic;
    -- CPU interface
    start : in std_logic;
    startAddress : in std_logic_vector (memAddressWidth - 1 downto 0);
    stopAddress : in std_logic_vector (memAddressWidth - 1 downto 0);
    -- Memory Interface
    memRd : out std_logic;
    memReady : in std_logic;
    memAddress : out std_logic_vector (memAddressWidth - 1 downto 0);
    -- ILA interface
    trigerILA : out std_logic);
end component;

-- ChipScope Pro components:
-- ICON
component icon1
  port
  (
    control0    :   out std_logic_vector(35 downto 0)
  );
end component;

-- ILA
component ila2
  port
  (
    control     : in    std_logic_vector(35 downto 0);
    clk         : in    std_logic;
    data        : in    std_logic_vector(43 downto 0);
    trig0       : in    std_logic_vector(0 downto 0)
  );
end component;

-- ROC: Reset On configuration 
-- component ROC
--   port (O : out std_logic);
-- end component;

-- DCM: Digital Clock Manager
component dcm_1
PORT(
	CLKIN_IN : IN std_logic;          
	CLKDV_OUT : OUT std_logic;
	CLKIN_IBUFG_OUT : OUT std_logic;
	CLK0_OUT : OUT std_logic
	);
end component;

component miniUART is
  port (
    SysClk   : in  Std_Logic;  -- System Clock
    Reset    : in  Std_Logic;  -- Reset input
    CS_N     : in  Std_Logic; -- Chip Select (inverted)
    RD_N     : in  Std_Logic; -- ReaD (inverted)
    WR_N     : in  Std_Logic; -- WRite (intevrted)
    RxD      : in  Std_Logic;
    TxD      : out Std_Logic;
    Addr     : in  Std_Logic_Vector(1 downto 0); -- 
    ready     : out std_logic;
    DataIn   : in  Std_Logic_Vector(7 downto 0); -- 
    DataOut  : out Std_Logic_Vector(7 downto 0)); -- 
end component; 

component io_unit is
  port (
    rst : in std_logic;
    clk : in std_logic;
    -- Memory interface
    memRd : out std_logic;
    memWr : out std_logic;
    memReady : in std_logic;
    memAddress: out std_logic_vector (ADDR_WIDTH - 1 downto 0);
    memDataIn : in std_logic_vector (DATA_WIDTH - 1 downto 0);
    memDataOut : out std_logic_vector (DATA_WIDTH - 1 downto 0);
    -- MBR interface
    MBRin : in std_logic_vector (DATA_WIDTH - 1 downto 0);
    MBRout : out std_logic_vector (DATA_WIDTH - 1 downto 0);
    -- External interface
    devID : out std_logic_vector (5 downto 0);
    extRd : out std_logic;
    extWr : out std_logic;
    extBusIn : in std_logic_vector (7 downto 0);
    extBusOut : out std_logic_Vector (7 downto 0);
    rdy_pre  : in std_logic;
    rdy_post : in std_logic;
    -- CPU interface
    rd : in std_logic;
    wr : in std_logic;
    ready : out std_logic; -- operation done
    wordByte : in std_logic; -- 0: byte, 1: word
    deviceID : in std_logic_vector (5 downto 0)); -- device ID
end component;

component memCtrl2 is
  port (
    rst : in std_logic;
    clk : in std_logic;
    rq1, rq2, rq3, rq4 : in std_logic;
    rd1, rd2, rd3, rd4 : in std_logic;
    wr1, wr2, wr3, wr4 : in std_logic;
    in1, in2, in3, in4 : out std_logic_vector;
    out1, out2, out3, out4 : in std_logic_vector;
    addr1, addr2, addr3, addr4 : in std_logic_vector;
    ready1, ready2, ready3, ready4 : out std_logic;
    -- Memory interface
    rd : out std_logic;
    wr : out std_logic;
    dataIn : out std_logic_vector;
    dataOut : in std_logic_vector;
    addr : out std_logic_vector;
    ready : in std_logic);
end component;

component dma is
  port (
    rst : in std_logic;
    clk : in std_logic;
    -- Memory interface
    memRd : out std_logic;
    memWr : out std_logic;
    memReady : in std_logic;
    memAddress: out std_logic_vector (ADDR_WIDTH - 1 downto 0);
    memDataIn : in std_logic_vector (DATA_WIDTH - 1 downto 0);
    memDataOut : out std_logic_vector (DATA_WIDTH - 1 downto 0);
    -- MBR interface
    MBRin : in std_logic_vector (DATA_WIDTH - 1 downto 0);
    MBRout : out std_logic_vector (DATA_WIDTH - 1 downto 0);
    -- External interface
    devID : out std_logic_vector (5 downto 0);
    extRd : out std_logic;
    extWr : out std_logic;
    extBusIn : in std_logic_vector (7 downto 0);
    extBusOut : out std_logic_Vector (7 downto 0);
    rdy_pre  : in std_logic;
    rdy_post : in std_logic;
    -- CPU interface
    rd : in std_logic;
    wr : in std_logic;
    ready : out std_logic; -- operation done
    wordByte : in std_logic; -- 0: byte, 1: word
    deviceID : in std_logic_vector (5 downto 0)); -- device ID
end component;


END package;



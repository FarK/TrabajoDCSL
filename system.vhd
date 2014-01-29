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
--------------------------------------------------------------------------------
-- Project     : Micro6
-- Author      : Osman Allam
-- File        : system.vhd
-- Design      : System top level
-- -----------------------------------------------------------------------------
-- Description : System top level contains the following units:
-- 0 - Digital Clock Management  [dcm_1.vhd]
-- 1 - CPU [cpu.vhd]
-- 2 - Memory controller [memCtrl.vhd]
-- 3 - Internal memory [memory.vhd]
-- 4 - Interface between cpu and uart [IO2Uart.vh]
-- 5 - uart [miniUART.vhd] 
--------------------------------------------------------------------------------
library IEEE;
library unisim;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

use unisim.VCOMPONENTS.all;

use WORK.micro_pk.all;
use WORK.micro_comp_pk.all;

entity system is
  port (
    rst : in std_logic;
    clk : in std_logic;
    RxD : in std_logic;
    TxD : out std_logic
    );  
end entity;

architecture struct of system is
  -- Address buses
  signal fch_addr_bus : std_logic_vector (ADDR_WIDTH - 1 downto 0);
  signal DPT_addr_bus : std_logic_vector (ADDR_WIDTH - 1 downto 0);

  
  -- Data buses
  signal fch_data_in  : std_logic_vector (DATA_WIDTH - 1 downto 0);
  signal DPT_data_in  : std_logic_vector (DATA_WIDTH - 1 downto 0);
  signal DPT_data_out : std_logic_vector (DATA_WIDTH - 1 downto 0);

  -- Memory buses
  signal mem_addr_bus : std_logic_vector (ADDR_WIDTH - 1 downto 0);
  signal mem_data_in  : std_logic_vector (DATA_WIDTH - 1 downto 0);
  signal mem_data_out : std_logic_vector (DATA_WIDTH - 1 downto 0);
    
  -- Memory control lines
  signal fch_memRq    : std_logic;
  signal fch_memRd    : std_logic;
  signal fch_memReady : std_logic;
  signal DPT_memRq    : std_logic;
  signal DPT_memRd    : std_logic;
  signal DPT_memWr    : std_logic;
  signal DPT_memReady : std_logic;
  signal memRd        : std_logic;
  signal memWr        : std_logic;
  signal memReady     : std_logic;
  signal nd : std_logic;
  signal rfd : std_logic;
  
  -- Clock lines    
  signal CLK0_OUT : std_logic;
  signal CLKIN_IBUFG_OUT : std_logic;
  signal clk_dcm : std_logic;
    
  -- Reset lines
  signal GSR : std_ulogic;
  signal reset : std_logic;
  
  -- IO signals and buses
  signal IO2CPU_data : std_logic_vector (DATA_WIDTH - 1 downto 0);
  signal CPU2IO_data : std_logic_vector (DATA_WIDTH - 1 downto 0);   
  signal deviceID  : std_logic_vector (5 downto 0); 
  signal IORd : std_logic;
  signal IOWr : std_logic;
  signal IOReady : std_logic;
  signal wordByte : std_logic;
  
  -- UART
  signal uart_cs_n : std_logic;
  signal uart_rd_n : std_logic;
  signal uart_wr_n : std_logic;
  signal uart_addr : std_logic_vector (1 downto 0);
  signal uart_dataOut : std_logic_vector (7 downto 0);
  signal uart_DataIn : std_logic_Vector (7 downto 0);
  
  signal unconnected_databus2 : std_logic_vector (DATA_WIDTH - 1 downto 0);
  constant fixed_zero_addr : std_logic_vector (ADDR_WIDTH - 1 downto 0):=(others =>'0');
  constant fixed_zero_data : std_logic_vector (DATA_WIDTH - 1 downto 0):=(others =>'0');        
begin
        
  nd <= memRd or memWr;
 
  -- ROC: Reset On Configuration
  ROC1: ROC 
  generic map (width => 100 ns)
  port map (GSR);
  
  reset <= (not rst) or GSR;
  
  -- DCM: Digital Clock Management
  Inst_dcm_1: dcm_1 PORT MAP(
    CLKIN_IN        => clk,
    CLKDV_OUT       => clk_dcm,
    CLKIN_IBUFG_OUT => CLKIN_IBUFG_OUT,
    CLK0_OUT        => CLK0_OUT
  );

  cpu1: cpu port map (
    rst      => reset,
    clk      => clk_dcm,
    -- Memory interface
    -- Data path
    rqDPT        => DPT_memRq,
    rdDPT        => DPT_memRd,
    wrDPT        => DPT_memWr,
    addrDPT      => DPT_addr_bus,
    inDPT        => DPT_data_in,
    outDPT       => DPT_data_out,
    memReadyDPT  => DPT_memReady,
    -- Fetch unit
    rqFch        => fch_memRq,
    rdFch        => fch_memRd, 
    addrFch      => fch_addr_bus,
    inFch        => fch_data_in,
    memReadyFch  => fch_memReady,
    -- IO Unit interface
    deviceID     => deviceID,
    wordByte     => wordByte,
    IORd         => IORd,
    IOWr         => IOWr,
    IOReady      => IOReady,
    IO_dataIn    => IO2CPU_data,
    IO_dataOut   => CPU2IO_data
    );
    
  memCtrl1: memCtrl port map (
    rst      => reset,
    clk      => clk_dcm,
    -- Control unit
    rqDPT    => DPT_memRq,
    rdDPT    => DPT_memRd,
    wrDPT    => DPT_memWr,
    addrDPT  => DPT_addr_bus,
    inDPT    => DPT_data_in,
    outDPT   => DPT_data_out,
    readyDPT => DPT_memReady,
    -- Fetch unit
    rqFch    => fch_memRq,
    rdFch    => fch_memRd, 
    addrFch  => fch_addr_bus,
    inFch    => fch_data_in,
    readyFch => fch_memReady,
    -- DMA unit                -- not connected : connect all inputs to '0'
                               --                 leave all outputs unconnected
    rqIO     => '0',                        -- input
    rdIO     => '0',                        -- input
    wrIO     => '0',                        -- input
    addrIO   => fixed_zero_addr,-- input
    inIO     => unconnected_databus2,       -- output
    outIO    => fixed_zero_data,-- input
    readyIO  => open,                       -- output
    -- memory
    addr     => mem_addr_bus,
    dataIn   => mem_data_in,
    dataOut  => mem_data_out,
    memRd    => memRd,
    memWr    => memWr,
    memReady => memReady);
    
  -- "main_mem" uses the BlockRAM generated by CoreGen
  mem1: main_mem port map (
    addr => mem_addr_bus (11 downto 0),
    clk  => clk_dcm,
    din  => mem_data_in,
    dout => mem_data_out,
    nd   => nd,
    rfd  => rfd,
    rdy  => memReady,
    we   => memWr);   

  -- interface between IO ports of CPU and miniuart  
  XIO2Uart :IO2Uart port map (
    rst          => reset,
    clk          => clk_dcm,
    -- uart interface
    uart_cs_n    => uart_cs_n,
    uart_rd_n    => uart_rd_n,
    uart_wr_n    => uart_wr_n,
    uart_addr    => uart_addr,
    uart_DataIn  => uart_DataIn, 
    uart_DataOut => uart_dataOut,       
    -- CPU interface
    cpu_MBRin    => IO2CPU_data,
    cpu_MBRout   => CPU2IO_data,  
    cpu_rd       => IORd,
    cpu_wr       => IOWr,
    cpu_ready    => IOReady,    -- operation done
    cpu_deviceID => deviceID ); -- device ID
    
  -- UART
  uart: miniUART port map (
    SysClk   => clk_dcm,
    Reset    => reset,
    CS_N     => uart_cs_n,
    RD_N     => uart_rd_n,
    WR_N     => uart_wr_n,
    RxD      => RxD,
    TxD      => TxD,
    Addr     => uart_addr, 
    DataIn   => uart_DataIn, 
    DataOut  => uart_dataOut);
        
end architecture;




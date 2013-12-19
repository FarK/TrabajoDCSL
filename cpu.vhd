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
-- Author      : Osman Allam
-- File        : cpu.vhd
-- Design      : CPU top level
-- -----------------------------------------------------------------------------
-- Description : CPU top level contains the following units:
-- 1 - control unit [control.vhd]
-- 2 - fetch unit [fetch.vhd]
-- 3 - register file [regfile.vhd]
-- 4 - stack [stack.vhd]
-- 5 - ALU [alu.vhd]
-- 6 - Data path registers [register_en.vhd]
-- 6.a - Accumulator (ACC)
-- 6.b - Instruction register (IR)
-- 6.c - Memory address register (MAR)
-- 6.d - Memory buffer register (MBR)
-- 6.e - Condition flags register (CF)
-- 7 - Program counter [counter.vhd]
-- 8 - 4 2port multiplexers [mux2xbus.vhd]
-- 9 - 1 4port  multiplexer [mux4xbus.vhd]
-- --------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

use WORK.micro_pk.all;
use WORK.micro_comp_pk.all;

entity cpu is
	port (
		rst         : in std_logic;
		clk         : in std_logic;
		-- Memory interface : Data
		rqDPT       : out std_logic;
		rdDPT       : out std_logic;
		wrDPT       : out std_logic;
		addrDPT     : out std_logic_vector (ADDR_WIDTH - 1 downto 0);
		inDPT       : in std_logic_vector (DATA_WIDTH - 1 downto 0);
		outDPT      : out std_logic_vector (DATA_WIDTH - 1 downto 0);
		memReadyDPT : in std_logic;
		-- Memory interface : Instructions
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
end entity;

architecture struct of cpu is
	-- shared buses
	signal data_bus       : std_logic_vector (DATA_WIDTH - 1 downto 0);
	signal mbr_bus        : std_logic_vector (DATA_WIDTH - 1 downto 0);
	signal alu_port_a     : std_logic_vector (DATA_WIDTH - 1 downto 0);
	signal alu_port_b     : std_logic_vector (DATA_WIDTH - 1 downto 0);

	-- data path
	signal regFile_port_a : std_logic_vector (DATA_WIDTH - 1 downto 0);
	signal regFile_port_b : std_logic_vector (DATA_WIDTH - 1 downto 0);
	signal alu_result     : std_logic_vector (DATA_WIDTH - 1 downto 0);
	signal ACCout         : std_logic_vector (DATA_WIDTH - 1 downto 0);
	signal MARout         : std_logic_vector (ADDR_WIDTH - 1 downto 0);
	signal PCout          : std_logic_vector (ADDR_WIDTH - 1 downto 0);
	signal MBRout         : std_logic_vector (DATA_WIDTH - 1 downto 0);
	signal STKout         : std_logic_vector (ADDR_WIDTH - 1 downto 0);
	signal memRdFch       : std_logic;
	signal PCinc          : std_logic;
	signal cf_in          : std_logic_Vector (2 downto 0);
	signal instRegOut     : std_logic_vector (DATA_WIDTH -1 downto 0);

	-- control unit signals
	-- =============================
	signal instReg     : std_logic_vector (DATA_WIDTH - 1 downto 0);
	signal cf          : std_logic_vector (2 downto 0);
	signal vldInstr    : std_logic;
	signal readInstr   : std_logic;
	-- Register file contrl lines
	signal RegFileWr   : std_logic;
	signal selA        : std_logic_Vector (4 downto 0);
	signal selB        : std_logic_vector (4 downto 0);
	signal selC        : std_logic_vector (4 downto 0);
	signal stkInc      : std_logic;
	signal stkDec      : std_logic;
	-- ALU control lines
	signal ALUsel      : alu_op;
	signal shiftCnt    : std_logic_vector (4 downto 0);
	signal shiftCntSrc : std_logic;
	signal portAsel    : std_logic;
	signal portBsel    : std_logic;
	-- Data flow control lines
	signal ACCen       : std_logic;
	signal CFen        : std_logic;
	signal MARen       : std_logic;
	signal MBRen       : std_logic;
	signal PCen        : std_logic;
	signal IRen        : std_logic;
	signal DATAsel     : std_logic_vector (1 downto 0);
	signal MBRsel      : std_logic;
	-- Stack control lines
	signal STKen       : std_logic;
	signal STKpop      : std_logic;
	signal STKpush     : std_logic;
	-- pag_0 address
	signal memAddr     : std_logic_vector (ADDR_WIDTH - 1 downto 0);
	----------------------------------

	-- the following 2 signals are required to connect 2 inputs of ADDR_WIDTH 
	-- width to the data bus
	signal data_bus_inport2 : std_logic_vector (DATA_WIDTH - 1 downto 0);
	signal data_bus_inport3 : std_logic_vector (DATA_WIDTH - 1 downto 0);
	signal mbr_bus_inport1 : std_logic_vector (DATA_WIDTH - 1 downto 0);

	signal IO2MBR : std_logic;

	signal rdDPT_int : std_logic;
	signal wrDPT_int : std_logic;
	signal IOWr_int : std_logic;
	signal IORd_int : std_logic;
begin
	-- Connect internal signals with the output ports
	addrDPT <= MARout;  
	addrFch <= PCout;  
	outDPT  <= MBRout;
	rqFch   <= memRdFch;
	rdFch   <= memRdFch;
	IO_dataOut <= MBRout;

	rdDPT <= rdDPT_int;
	wrDPT <= wrDPT_int;
	IOWr <= IOWr_int;
	IORd <= IORd_int;

	-- Extend the stack output with zero's at the MSB side
	data_bus_inport2 <= (DATA_WIDTH - 1 downto ADDR_WIDTH => '0') & STKout;

	-- Extend the data_bus control output with zero's at the MSB side
	data_bus_inport3 <= (DATA_WIDTH - 1 downto ADDR_WIDTH => '0') & memAddr;

	-- Connect the correct bits of the instruction register with deviceID and wordbyte
	-- these outputs are used by the external IOUnit
	deviceID <= instRegOut (23 downto 18);
	wordByte <= instRegOut (26);

	data_bus_1: mux4xbus port map(
		inport0 => ACCout,
		inport1 => MBRout,
		inport2 => data_bus_inport2,
		inport3 => data_bus_inport3,
		sel     => DATAsel, -- (00:ACC, 01:MBR , 10:extended stack  , 11:extended control)
		outport => data_bus
	);

	alu_port_a_mux: mux2xbus port map(
		inport0 => regFile_port_a,
		inport1 => ACCout,
		sel     => portAsel, -- (0:regfile A ,1:ACC)
		outport => alu_port_a
	);

	alu_port_b_mux: mux2xbus port map(
		inport0 => regFile_port_b,
		inport1 => ACCout,
		sel     => portBsel, -- (0:regfile B ,1:ACC)
		outport => alu_port_b
	);

	mbr_bus_1: mux2xbus port map(
		inport0 => inDPT, 
		inport1 => mbr_bus_inport1,
		sel     => MBRsel,
		outport => mbr_bus
	);

	mbr_bus_inport1_1 : mux2xbus port map(
		inport0 => data_bus, 
		inport1 => IO_dataIn,
		sel     => IO2MBR,
		outport => mbr_bus_inport1
	);


	regFile_1: regFile port map(
		rst    => rst,
		clk    => clk,
		busC   => data_bus,	--TODO: No estoy seguro. Comprobar.
		stkInc => stkInc,
		stkDec => stkDec,
		wr     => RegFileWr,
		selA   => selA,
		selB   => selB,
		selC   => selC,
		busA   => regFile_port_a,
		busB   => regFile_port_b
	);

	alu_1: alu port map(
		a           => alu_port_a,
		b           => alu_port_b,
		sel         => ALUsel,
		shiftCnt    => shiftCnt,
		shiftCntSrc => shiftCntSrc,
		result      => alu_result,
		neg         => cf_in (2),
		ovf         => cf_in (1),
		zro         => cf_in (0)
	);

	acc_1: register_en port map(
		rst => rst,
		clk => clk,
		en  => ACCen,
		d   => alu_result,
		q   => ACCout
	);

	stack_1: stack port map(
		rst  => rst,
		clk  => clk,
		en   => STKen,
		d    => PCout,
		push => STKpush,
		pop  => STKpop,
		q    => data_bus_inport2
	);

	pc_1: counter port map(
		rst => rst,
		clk => clk,
		d   => data_bus(ADDR_WIDTH downto 0),	-- add code here  (only 12 LSB's) TODO: ¿asi?
		ld  => PCen,
		inc => PCinc,
		q   => PCout
	);

	mar_1: register_en port map(
		rst => rst,
		clk => clk,
		en  => MARen,
		d   => data_bus(ADDR_WIDTH downto 0),	-- add code here  (only 12 LSB's) TODO: ¿asi?
		q   => MARout
	);

	mbr_1: register_en port map(
		rst => rst,
		clk => clk,
		en  => MBRen,
		d   => mbr_bus,
		q   => MBRout
	);

	instReg_1: register_en port map(
		rst => rst,
		clk => clk,
		en  => IRen,
		d   => instReg,
		q   => instRegOut
	);

	fetch_1: fetch port map(
		rst       => rst,
		clk       => clk,
		memReady  => memReadyFch,
		readInstr => readInstr,
		memData   => inFch,
		vldInstr  => vldInstr,
		PCinc     => PCinc,
		memRd     => memRdFch,
		IR        => instReg
	);

	control_1: control port map(
		rst         => rst,
		clk         => clk,
		instReg     => instRegOut,
		cf          => cf,
		memReady    => memReadyDPT,
		vldInstr    => vldInstr,
		readInstr   => readInstr,
		RegFileWr   => RegFileWr,
		selA        => selA,
		selB        => selB,
		selC        => selC,
		stkInc      => stkInc,
		stkDec      => stkDec,
		ALUsel      => ALUsel,
		shiftCnt    => shiftCnt,
		shiftCntSrc => shiftCntSrc,
		portAsel    => portAsel,
		portBsel    => portBsel,
		ACCen       => ACCen,
		CFen        => CFen,
		MARen       => MARen,
		MBRen       => MBRen,
		PCen        => PCen,
		IRen        => IRen,
		DATAsel     => DATAsel,
		MBRsel      => MBRsel,
		STKen       => STKen,
		STKpop      => STKpop,
		STKpush     => STKpush,
		memAddr     => memAddr,
		memRq       => rqDPT,
		memWr       => wrDPT_int, 
		memRd       => rdDPT_int,
		IORd        => IORd_int,
		IOWr        => IOWr_int,
		IOReady     => IOReady,
		IO2MBR      => IO2MBR
	);

	cf_1: register_en port map(
		rst => rst,
		clk => clk,
		en  => CFen,
		d   => cf_in,
		q   => cf
	);
end architecture;

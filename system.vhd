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
-- File           : system.vhd
-- -----------------------------------------------------------------------------
-- Description : System top level contains the following units:
-- 1 - CPU (cpu.vhd]
-- 2 - Memory controller [memCtrl.vhd]
-- 3 - Internal memory [memory.vhd]
--------------------------------------------------------------------------------
-- Author         : Osman Allam
-- Date           : 07/02/2006
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

use WORK.micro_pk.all;
use WORK.micro_comp_pk.all;

entity system is
	port (
		rst : std_logic;
		clk : std_logic
	);
end entity;

architecture struct of system is
	-- buses
	signal fch_addr_bus : std_logic_vector (ADDR_WIDTH - 1 downto 0);
	signal DPT_addr_bus : std_logic_vector (ADDR_WIDTH - 1 downto 0);
	signal fch_data_in  : std_logic_vector (DATA_WIDTH - 1 downto 0);
	signal DPT_data_in  : std_logic_vector (DATA_WIDTH - 1 downto 0);
	signal DPT_data_out : std_logic_vector (DATA_WIDTH - 1 downto 0);
	signal mem_addr_bus : std_logic_vector (ADDR_WIDTH - 1 downto 0);
	signal mem_data_in  : std_logic_vector (DATA_WIDTH - 1 downto 0);
	signal mem_data_out : std_logic_vector (DATA_WIDTH - 1 downto 0);
	--
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
	---
	signal IO_dataIn   : std_logic_vector (DATA_WIDTH - 1 downto 0);
	signal unconnected_databus1 : std_logic_vector (ADDR_WIDTH - 1 downto 0);
	signal unconnected_databus2 : std_logic_vector (DATA_WIDTH - 1 downto 0);
begin
	-- CPU
	cpu_1: cpu port map(
		rst => rst,
		clk => clk,
		-- Memory interface : Data
		rqDPT => DPT_memRq,
		rdDPT => DPT_memRd,
		wrDPT => DPT_memWr,
		addrDPT => DPT_addr_bus,
		inDPT => DPT_data_in,
		outDPT => DPT_data_out,
		memReadyDPT => DPT_memReady,
		-- Memory interface : Instructions
		rqFch => fch_memRq,
		rdFch => fch_memRd,
		addrFch => fch_addr_bus,
		inFch => fch_data_in,
		memReadyFch => fch_memReady,
		-- IO Unit interface
		deviceID => open,
		wordByte => open,
		IORd => open,
		IOWr => open,
		IOReady => '0',
		IO_dataIn => IO_dataIn,
		IO_dataOut => IO_dataIn		-- Los conectamos en bucle porque no los usamos
	);

	-- Memory Traffic Controller
	memoryTrafficControler: memCtrl port map(
		rst => rst,
		clk => clk,
		-- Data path
		rqDPT => DPT_memRq,
		rdDPT => DPT_memRd,
		wrDPT => DPT_memWr,
		addrDPT => DPT_addr_bus,
		inDPT => DPT_data_in,
		outDPT => DPT_data_out,
		readyDPT => DPT_memReady,
		-- Fetch unit
		rqFch => fch_memRq,
		rdFch => fch_memRd,
		addrFch => fch_addr_bus,
		inFch => fch_data_in,
		readyFch => fch_memReady,
		-- I/O unit
		rqIO => '0',
		rdIO => '0',
		wrIO => '0',
		addrIO => unconnected_databus1,
		inIO => unconnected_databus2,
		outIO => unconnected_databus2,	-- Los conectemos en blucle porque no los usamos
		readyIO => open,
		-- control signals
		addr => mem_addr_bus,
		dataIn => mem_data_in,
		dataOut => mem_data_out,
		memRd => memRd,
		memWr => memWr,
		memReady => memReady
	);

	-- Main Memory    
	mainMemory: memory port map(
		clk	=> clk,
		inBus	=> mem_data_in,
		addr	=> mem_addr_bus,
		rd	=> memRd,
		wr	=> memWr,
		outBus	=> mem_data_out,
		ready	=> memReady
	);
end architecture;

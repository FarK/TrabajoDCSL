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
-- File           : tb_control.vhd
-----------------------------------------------------------------------------
-- Description    : Testbench for the control entity of the Micro6
-- --------------------------------------------------------------------------
-- Author         : Geert Vanwijnsberghe
-- Date           : 2/1/07
-- Version        : 1.0
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

use work.micro_pk.all;
use work.micro_control_pk.all;

entity tb_control is
	end entity;

architecture test of tb_control is
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
			-- page address
			memAddr     : out std_logic_vector (ADDR_WIDTH - 1 downto 0);
			-- Memory control lines
			memRq       : out std_logic;
			memWr       : out std_logic; 
			memRd       : out std_logic;
			-- IO Unit interface
			IORd        : out std_logic;
			IOWr        : out std_logic;
			IOReady     : in std_logic;
			IO2MBR      : out std_logic -- if high then IO unit writes into MBR
		     );
	end component;

	signal rst, clk, memReady, vldInstr, readInstr : std_logic;
	signal instReg : std_logic_vector (DATA_WIDTH - 1 downto 0);
	signal cf : std_logic_vector (2 downto 0);

	signal RegFileWr, stkInc, stkDec : std_logic;
	signal selA, selB, selC : std_logic_vector (4 downto 0);

	signal ALUsel : alu_op;
	signal shiftCnt : std_logic_vector (4 downto 0);
	signal shiftCntSrc, portAsel, portBsel : std_logic;

	signal ACCen, CFen, MARen, MBRen, PCen, IRen, MBRsel : std_logic;
	signal DATAsel : std_logic_vector (1 downto 0);

	signal STKen, STKpop, STKpush : std_logic;

	signal memAddr : std_logic_vector (ADDR_WIDTH - 1 downto 0);

	signal memRq, memRd, memWr : std_logic;

	signal IORd,IOWr,IOReady,IO2MBR : std_logic;

	-- ===========================================================================
	-- Testbench declarations ----------------------------------------------------
	------------------------------------------------------------------------------
	signal EndOfSim : boolean := false;
	constant clkPeriod : time := 10 ns;
	constant dutyCycle : real := 0.5; 
	constant delay : time := 2 ns;

	type ctrl_signal_t is (  
	readInstr_s,
	RegFileWr_s,
	stkInc_s,
	stkDec_s,
	shiftCntSrc_s,
	ACCen_s,
	CFen_s,
	MARen_s,
	MBRen_s,
	PCen_s,
	IRen_s,
	STKen_s,
	STKpop_s,
	STKpush_s,
	memRq_s,
	memWr_s,
	memRd_s);

	type ctrl_signal_vector_t is array (ctrl_signal_t) of std_logic;
	type ctrl_signal_v2_t is array (positive range <>) of ctrl_signal_vector_t;
	signal actual_ctrl_signals : ctrl_signal_vector_t;
	------------------------------------------------------------------------------  
	constant reset_csv2 : ctrl_signal_v2_t := (
	1 => (others => '0'),
	2 => (ACCen_s => '1',others => '0'),
	3 => (RegFileWr_s => '1', PCen_s => '1', others => '0'),
	4 => (RegFileWr_s => '1', readInstr_s => '1', others => '0'),
	5 => (RegFileWr_s => '1', others => '0'),
	6 => (RegFileWr_s => '1', readInstr_s => '1', others => '0'));
	------------------------------------------------------------------------------     
	constant g1_csv2 : ctrl_signal_v2_t := (
	1 => (ACCen_s => '1', CFen_s => '1', 
	others => '0'));
	------------------------------------------------------------------------------  
	constant g2_csv2 : ctrl_signal_v2_t := (
	1 => (ACCen_s => '1', CFen_s => '1', others => '0'),
	2 => (RegFileWr_s => '1', others => '0'));
	------------------------------------------------------------------------------  
	constant g3_csv2 : ctrl_signal_v2_t := (
	1 => (CFen_s => '1', others => '0'));
	------------------------------------------------------------------------------  
	procedure check_reset(signal rst : out std_logic) is
	begin
		wait for 21 ns;
		rst <= '1';
		wait until rising_edge (clk);
		rst <= '0';
		for i in reset_csv2'range loop
			wait for delay;
			assert (actual_ctrl_signals = reset_csv2 (i))
			report "Error in executing RESET in machine cycle " & integer'image (i);
			wait until rising_edge (clk);
		end loop;
	end procedure;
	------------------------------------------------------------------------------
	procedure check_decode is
	begin
		assert ((readInstr = '1') and (IRen = '1'))
		report "Error in DECODING phase machine cycle 1";
		wait until rising_edge (clk);
	end procedure;
	------------------------------------------------------------------------------
	procedure check_g1(signal vldInstr : out std_logic) is
	begin
		vldInstr <= '1';
		wait until rising_edge (clk);
		vldInstr <= '0';
		wait for delay;
		check_decode;
		wait until rising_edge (clk);
		wait for delay;
		assert (actual_ctrl_signals = g1_csv2 (1))
		report "Error in executing G1 Instruction in machine cycle 1";
	end procedure;
	------------------------------------------------------------------------------
	procedure check_g2(signal vldInstr : out std_logic) is
	begin
		vldInstr <= '1';
		wait until rising_edge (clk);
		vldInstr <= '0';
		wait for delay;
		check_decode;
		for i in g2_csv2'range loop
			wait until rising_edge (clk);
			wait for delay;
			assert (actual_ctrl_signals = g2_csv2 (i))
			report "Error in executing G2 Instruction in machine cycle "
			& integer'image (i);
		end loop;
	end procedure;
	------------------------------------------------------------------------------
	procedure check_g3(signal vldInstr : out std_logic) is
	begin
		vldInstr <= '1';
		wait until rising_edge (clk);
		vldInstr <= '0';
		wait for delay;
		check_decode;
		wait until rising_edge (clk);
		wait for delay;
		assert (actual_ctrl_signals = g3_csv2 (1))
		report "Error in executing G3 Instruction in machine cycle 1";
	end procedure;
	------------------------------------------------------------------------------
	procedure check_add(
			    signal vldInstr : out std_logic;
			    signal instReg : out std_logic_vector (31 downto 0)) is
	begin
		wait until rising_edge (clk);
		instReg (31 downto 27) <= "00000";
		instReg (17 downto 0) <= (others => '0');
		check_g1 (vldInstr);
	end procedure;
	------------------------------------------------------------------------------
	procedure check_add2(
			     signal vldInstr : out std_logic;
			     signal instReg : out std_logic_vector (31 downto 0)) is
	begin
		wait until rising_edge (clk);
		instReg (31 downto 27) <= "00000";
		instReg (17 downto 0) <= (15 => '1', others => '0');
		check_g2 (vldInstr);
	end procedure;
	------------------------------------------------------------------------------
	procedure check_sub(
			    signal vldInstr : out std_logic;
			    signal instReg : out std_logic_vector (31 downto 0)) is
	begin
		wait until rising_edge (clk);
		instReg (31 downto 27) <= "00001";
		instReg (17 downto 0) <= (others => '0');
		check_g1 (vldInstr);
	end procedure;
	------------------------------------------------------------------------------
	procedure check_cmp(
			    signal vldInstr : out std_logic;
			    signal instReg : out std_logic_vector (31 downto 0)) is
	begin
		wait until rising_edge (clk);
		instReg (31 downto 27) <= "10000";
		instReg (17 downto 0) <= (others => '0');
		check_g3 (vldInstr);
	end procedure;
------------------------------------------------------------------------------

begin
	UUT: control port map (
		rst         => rst,
		clk         => clk,
		instReg     => instReg,
		cf          => cf,
		memReady    => memReady,
		vldInstr    => vldInstr,
		readInstr   => readInstr,
		-- Register file contrl lines
		RegFileWr   => RegFileWr,
		selA        => selA,
		selB        => selB,
		selC        => selC,
		stkInc      => stkInc,
		stkDec      => stkDec,
		-- ALU control lines
		ALUsel      => ALUsel,
		shiftCnt    => shiftCnt,
		shiftCntSrc => shiftCntSrc,
		portAsel    => portAsel,
		portBsel    => portBsel,
		-- Data flow control lines
		ACCen       => ACCen,
		CFen        => CFen,
		MARen       => MARen,
		MBRen       => MBRen,
		PCen        => PCen,
		IRen        => IRen,
		DATAsel     => DATAsel,
		MBRsel      => MBRsel,
		-- Stack control lines
		STKen       => STKen,
		STKpop      => STKpop,
		STKpush     => STKpush,
		-- page address
		memAddr     => memAddr,
		-- Memory control lines
		memRq       => memRq,
		memWr       => memWr, 
		memRd       => memRd,
		-- IO
		IORd        => IORd,   
		IOWr        => IOWr,   
		IOReady     => IOReady,
		IO2MBR      => IO2MBR
	);

	actual_ctrl_signals (readInstr_s) <= readInstr;
	actual_ctrl_signals (RegFileWr_s) <= RegFileWr;
	actual_ctrl_signals (stkInc_s) <= stkInc;
	actual_ctrl_signals (stkDec_s) <= stkDec;
	actual_ctrl_signals (shiftCntSrc_s) <= shiftCntSrc;
	actual_ctrl_signals (ACCen_s) <= ACCen;
	actual_ctrl_signals (CFen_s) <= CFen;
	actual_ctrl_signals (MARen_s) <= MARen;
	actual_ctrl_signals (MBRen_s) <= MBRen;
	actual_ctrl_signals (PCen_s) <= PCen;
	actual_ctrl_signals (IRen_s) <= IRen;
	actual_ctrl_signals (STKen_s) <= STKen;
	actual_ctrl_signals (STKpop_s) <= STKpop;
	actual_ctrl_signals (STKpush_s) <= STKpush;
	actual_ctrl_signals (memRq_s) <= memRq;
	actual_ctrl_signals (memWr_s) <= memWr;
	actual_ctrl_signals (memRd_s) <= memRd;

	-- Clock Generation process
	clock: process
	begin
		clk <= '0';
		wait for (1.0 - dutyCycle) * clkPeriod;
		clk <= '1';
		wait for dutyCycle * clkPeriod;
		if EndOfSim then -- The simulation stops due to even starvation
			wait;
		end if;
	end process;

	process 
	begin
		instReg <= (others => '0');
		check_reset (rst);
		check_add (vldInstr, instReg);
		check_add2 (vldInstr, instReg);
		check_cmp (vldInstr, instReg);

		wait for 50 ns;
		EndOfSim <= true;
		wait;
	end process;
end architecture;

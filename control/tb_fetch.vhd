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
-- File           : tb_fetch.vhd
-----------------------------------------------------------------------------
-- Description    : Testbench for the fetch entity of the Micro6
-- --------------------------------------------------------------------------
-- Author         : Geert Vanwijnsberghe
-- Date           : 4/1/07
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

use work.micro_pk.all;
use WORK.micro_comp_pk.all;

-- Testbench for the Fetch Unit
-- ============================
-- The normal operation of the Fetch Unit requires the existence of other units.
-- Namely, the Program Counter PC, the Memory, the IR register and the Control Unit. The 
-- system is simulated by a combination of concurrent processes and component instantiations 
-- as follows:
--   PC              => process : p_counter
--   Memory          => process : mem
--   Control Unit    => component
--   Fetch Unit      => component
--   IR              => component
--  
--   +-----------------------------------+
--   |                                   |
--   |         control                   |
--   |                                   |
--   +-----------------------------------+
--         |         /|\     /|\     |IRen
--         |          |       |IR2  \|/
--         |          |   +--------------+
--     read|       vld|   |  IR          |
--    Instr|     Instr|   +--------------+
--         |          |      /|\
--        \|/         |       |IR1
--   +-----------------------------+                     +---------------+
--   |                             |       PCinc         |               |
--   |       Fetch Unit            |-------------------->|      pc_1     |
--   |                             |                     |               |
--   +-----------------------------+                     +---------------+
--         |         /|\  /|\                                 |
--         |          |    |                                  |
--    memRd|       mem|    |memData                           |Address
--         |     ready|    |                                  |
--         |          |    |                                  |
--        \|/         |    |                                 \|/
--   +----------------------------------------------------------------+  
--   |                                                                |
--   |                              mem                               |
--   |                                                                |
--   +----------------------------------------------------------------+ 

entity tb_fetch is
end entity;

architecture test of tb_fetch is
	signal rst, clk, memReady, vldInstr, readInstr : std_logic;

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

	signal PCinc: std_logic;
	signal memData, IR1,IR2 : std_logic_vector (31 downto 0);

	signal PC : natural;  
	signal zero : std_logic:='0';
	signal one : std_logic:='1';

	-- ===========================================================================
	-- Testbench declarations ----------------------------------------------------
	------------------------------------------------------------------------------
	signal EndOfSim : boolean := false;
	constant clkPeriod : time := 10 ns;
	constant dutyCycle : real := 0.5; 
	constant delay : time := 2 ns;
begin
	Ufetch: fetch port map (
		rst => rst, 
		clk => clk, 
		memReady => memReady,
		readInstr => readInstr,
		memData => memData,
		vldInstr => vldInstr,
		PCinc => PCinc,
		memRd => memRd,
		IR => IR1
	);

	UIR: register_en port map (
		rst => rst,
		clk => clk,
		en  => IRen,
		d   => IR1,
		q   => IR2
	);

	Ucontrol: control port map(
		rst         => rst,
		clk         => clk,
		instReg     => IR2,
		cf          => cf,
		memReady    => one,
		vldInstr    => vldInstr,
		readInstr   => readInstr,
		-- Register file contrl lines
		RegFileWr   => open,
		selA        => open,
		selB        => open,
		selC        => open,
		stkInc      => open,
		stkDec      => open,
		-- ALU control lines
		ALUsel      => open,
		shiftCnt    => open,
		shiftCntSrc => open,
		portAsel    => open,
		portBsel    => open,
		-- Data flow control lines
		ACCen       => open,
		CFen        => open,
		MARen       => open,
		MBRen       => open,
		PCen        => open,
		IRen        => IRen,
		DATAsel     => open,
		MBRsel      => open,
		-- Stack control lines
		STKen       => open,
		STKpop      => open,
		STKpush     => open,
		-- page address
		memAddr     => open,
		-- Memory control lines
		memRq       => open,
		memWr       => open, 
		memRd       => open,
		-- IO
		IORd        => open,   
		IOWr        => open,   
		IOReady     => one,
		IO2MBR      => open
	);       

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

	main: process
	begin
		cf <= (others =>'0');
		rst <= '0';
		wait for 21 ns;
		rst <= '1';
		wait until falling_edge (clk);
		rst <= '0';
		wait for 200*clkPeriod;   
		EndOfSim <= true;
		wait;   
	end process;


	-- This process simulates the behaviour of reading from the memory
	mem: process
		-- a sample of the memory contents
		constant memContents : memContents_t := (
			x"00000001",  --ADD_i
			x"08000002",  --SUB_i
			x"10000003",  --MUL_i
			x"18000004",  --DIV_i
			x"20000005",  --REM_i
			x"28000006",  --AND_i
			x"30000007",  --OR_i 
			x"38000008",  --XOR_i
			x"40000009",  --INC_i
			x"4800000A",  --DEC_i
			x"5000000B",  --NOT_i
			x"5800000C",  --ZRO_i 
			x"6000000D",  --CPR_i
			x"6800000E",  --SHA_i
			x"7000000F",  --SHL_i
			x"78000010",  --ROT_i
			x"80000011",  --CMP_i
			x"88000012",  --LD_i 
			x"90000013",  --LDX_i
			x"98000014",  --LDM_i
			x"A0000015",  --ST_i 
			x"A8000016",  --STX_i
			x"B0000017",  --JYY_i
			x"B8000018",  --RTN_i 
			x"00000019",  -- only fetched not used in control
			x"C800001A",  --NLL_i
			x"D000001B",  --POP_i
			x"D800001C",  --PSH_i
			x"E000001D",  --unused1 
			x"E800001E",  --unused2
			x"F000001D",  --IN_i    
			x"F800001E",  --OUT_i   
			x"C000001F",  --END_i 
			x"00000020"   -- not fetched any more             
		);
	begin
		wait on memRd;
		wait until rising_edge (clk);
		if (memRd = '1') then
			memData <= memContents (PC);
			memReady <= '1';
		else
			memReady <= '0';
		end if;
	end process;

	-- This process simulates the behaviour of incrementing the program counter
	p_counter: process (rst, clk)
	begin
		if (rst = '1') then
			PC <= 0;
		elsif (rising_edge (clk)) then
			if (PCinc = '1') then
				PC <= PC + 1;
			end if;
		end if;
	end process;
end architecture;

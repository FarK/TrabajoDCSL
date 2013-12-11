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
-- File           : tb_control_cc.vhd
-----------------------------------------------------------------------------
-- Description    : Testbench for the condition_checking circuit of the 
--                  control entity of the Micro6
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

entity tb_control_cc is
	end entity;

architecture test of tb_control_cc is
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

	alias pn : std_logic is instReg (6); -- polarity of negative
	alias pv : std_logic is instReg (5); -- polarity of overflow
	alias pz : std_logic is instReg (4); -- polarity of zero
	alias cn : std_logic is instReg (3); -- check negative
	alias cv : std_logic is instReg (2); -- check overflow
	alias cz : std_logic is instReg (1); -- check zero

	alias neg : std_logic is cf (2); -- negative
	alias ovf : std_logic is cf (1); -- overflow
	alias zro : std_logic is cf (0); -- zero

	signal MBRsel_exp : std_logic;
	signal compare    : std_logic;

	signal EndOfSim : boolean := false;
	constant clkPeriod : time := 10 ns;
	constant dutyCycle : real := 0.5; 

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

	-- Clock Generation process
	clock: process
	begin
		clk <= '0';
		wait for (1.0 - dutyCycle) * clkPeriod;
		clk <= '1';
		wait for dutyCycle * clkPeriod;
		if EndOfSim then -- The simulation stops due to event starvation
			wait;
		end if;
	end process;        

	-- This process generates all possible combinations of the nine inputs of the
	-- Condition Checking Circuit. It also verifies the the output of the Control
	-- Unit
	main: process
		variable x : unsigned (8 downto 0);
	begin
		-- assign all inputs at time zero
		cf          <= (others =>'0');
		memReady    <= '0';
		vldInstr    <= '1';
		IOReady     <= '0';

		instReg (31 downto 27) <= "10110"; -- Jump opcode
		instReg (26 downto 0) <= (others => '0');

		-- reset 
		rst <= '1';
		compare <='0';
		wait for clkPeriod;
		rst <= '0';
		wait for clkPeriod;

		-- loop over all possible inputs for the condition check unit
		for i in 0 to 511 loop
			x := to_unsigned (i, x'length);
			instReg (6 downto 1) <= std_logic_vector (x (8 downto 3)); -- all values for pn,pv,pz,cn,cv,cz (from IR)
			cf <= std_logic_vector (x (2 downto 0));                   -- all values for cf (from alu)

			wait for 6*clkPeriod;
			compare <='1';
			-- extract from micro_contol_pk
			-- ==> MBRsel reflects the inverse value of cTrue
			-- ....
			-- constant SYSTEMBUS : std_logic := '0';
			-- constant DATABUS   : std_logic := '1';
			-- when JYY_i =>  -- Jump, branch or call subroutine
			--   ....
			--   if (cTrue = '1') then
			--     ret.ALUsel  := PASS_A;
			--     ret.Bsel    := Bsel;
			--     ret.DATAsel := ctrlUnit;
			--     ret.MBRsel  := SYSTEMBUS;
			--   else
			--     ret.ALUsel  := PASS_A;
			--     ret.Bsel    := Bsel;
			--     ret.DATAsel := ACC;
			--     ret.MBRsel  := DATABUS;
			--   end if; 

			assert (MBRsel = MBRsel_exp) 
			report "Error in the logic of the Condition Checking Circuit";

			-- reset 
			wait for clkPeriod;
			rst <= '1';
			compare <='0';
			wait for clkPeriod;
			rst <= '0';
			wait for clkPeriod;
		end loop;
		EndOfSim <= true;
		wait;
	end process;

	-- This process calculates the expected value of MBRSel (MBRSel_exp)  
	process (pn, pv, pz, cn, cv, cz, neg, ovf, zro)
		variable n, v, z : boolean;
	begin
		if (cn = '1') then
			n := (pn = neg);
		else
			n := true;
		end if;
		if (cv = '1') then  
			v := (pv = ovf);
		else
			v := true;
		end if;
		if (cz = '1') then
			z := (pz = zro);
		else
			z := true;
		end if;

		if (n and v and z) then
			MBRSel_exp <= '0'; -- MBRsel corresponds with the inverse value of cTrue
		else 
			MBRSel_exp <= '1';
		end if;
	end process;
end architecture;

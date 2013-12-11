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
-- File        : micro_control_pk.vhd
-- Design      : Control unit package
--------------------------------------------------------------------------------
-- Description : A package containing all declarations related to the control unit
-- and fetch unit.
-- -----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use WORK.micro_pk.all;

package micro_control_pk is
	-- Instruction groups combine several instructions of the same type: see further in the code
	type instrGroup_t is (G1, G2, G3, G4, G5, G6, G7, G8, G9,
	G10, G11, G12, G13, G14, G15, G16);

	-- Data bus selection lines
	constant ACC      : std_logic_vector (1 downto 0) := "00";
	constant MBR      : std_logic_vector (1 downto 0) := "01";
	constant STKout   : std_logic_vector (1 downto 0) := "10";
	constant ctrlUnit : std_logic_vector (1 downto 0) := "11";

	-- MBR bus selection lines 
	constant SYSTEMBUS : std_logic := '0';
	constant DATABUS   : std_logic := '1';

	-- Decode unit control lines (Decode Bundle)
	-- Declare a new type dec_t as a record for the decode bundle as shown in the lab manual (use the table)
	type dec_t is record
		instrGroup	: instrGroup_t;
		Asel		: std_logic_vector(4 downto 0);
		Bsel		: std_logic_vector(4 downto 0);
		Csel		: std_logic_vector(4 downto 0);
		ALUsel		: alu_op;
		shiftCnt	: std_logic_vector(4 downto 0);
		shiftCntSrc	: std_logic;
		portAsel	: std_logic;
		portBsel	: std_logic;
		CFen		: std_logic;
		STKen		: std_logic;
		DATAsel		: std_logic_vector(1 downto 0);
		MBRsel		: std_logic;
		memAddr		: std_logic_vector(11 downto 0);
	end record;

	-- Execute unit control lines (Execute Bundle)
	-- Declare a new type exe_t as a record for the execute bundle as shown in the lab manual  (use the table)
	type exe_t is record
		Asel		: std_logic_vector(4 downto 0);
		Bsel		: std_logic_vector(4 downto 0);
		Csel		: std_logic_vector(4 downto 0);
		ALUsel		: alu_op;
		CFen		: std_logic;
		DATAsel		: std_logic_vector(1 downto 0);
		RegFileWr	: std_logic;
		stkInc		: std_logic;
		stkDec		: std_logic;
		ACCen		: std_logic;
		MARen		: std_logic;
		MBRen		: std_logic;
		PCen		: std_logic;
		IRen		: std_logic;
		STKpop		: std_logic;
		STKpush		: std_logic;
		memRd		: std_logic;
		memWr		: std_logic;
	end record;

	-- Decode unit
	function decodeInstr (instReg : std_logic_vector (DATA_WIDTH - 1 downto 0);
	cTrue : std_logic)
	return dec_t;

	-- The states of the execute unit FSM
	type exeUnitState is (
		idle,
		reading,
		decoding,
		reset1,
		reset2,
		reset3,
		reset4,
		reset5,
		reset6,

		g1s1,
		g2s1, g2s2,
		g3s1,
		g4s1, g4s2, g4s3, g4s4, g4s5,
		g5s1, g5s2, g5s3, g5s4, g5s5,
		g6s1, g6s2, g6s3, g6s4,
		g7s1, g7s2, g7s3, g7s4, g7s5,
		g8s1, g8s2, g8s3, g8s4, g8s5,
		g9s1, g9s2, g9s3, g9s4, g9s5,

		g10s1, g10s2, g10s3, g10s4, g10s1e,
		g11s1,
		g12s1,
		g13s1, g13s2, g13s3, g13s4, g13s5,
		g14s1, g14s2, g14s3, g14s4, g14s5, g14s6,
		g15s1, g15s2, g15s3,
		g16s1, g16s2, g16s3, g16s4
	);

	type fchUnitState is (idle, f1, f2, f2waiting, f3);
end package;

package body micro_control_pk is
	function decodeInstr (instReg : std_logic_vector (DATA_WIDTH - 1 downto 0); cTrue : std_logic)
		return dec_t is variable ret : dec_t;

		-- Write aliases for the following fields (more information is provided in the lab manual):
		-- All format
		alias opcode		: opcode_t is instReg(31 downto 27);

		-- Format 1
		alias inx		: std_logic_vector(1 downto 0) is instReg(26 downto 25);
		alias shiftCntSrc	: std_logic is instReg(24);
		alias shiftDirect	: std_logic is instReg(23);
		alias shiftCnt		: std_logic_vector(4 downto 0) is instReg(22 downto 18);
		alias aAcc		: std_logic is instReg(17);
		alias bAcc		: std_logic is instReg(16);
		alias storeC		: std_logic is instReg(15);
		alias Asel		: std_logic_vector(4 downto 0) is instReg(14 downto 10);
		alias Bsel		: std_logic_vector(4 downto 0) is instReg(9 downto 5);
		alias Csel		: std_logic_vector(4 downto 0) is instReg(4 downto 0);

		-- Format 2 and 3
		alias shortAddr		: std_logic_vector(SHORT_DATA - 1 downto 0) is instReg(26 downto 18);

		-- Format 2
		alias STKen		: std_logic is instReg(0);
	begin
		-- default return values
		ret.Asel        := Asel;
		ret.Csel        := Csel;
		ret.shiftCnt    := shiftCnt;
		ret.shiftCntSrc := shiftCntSrc;
		ret.portAsel    := aAcc;
		ret.portBsel    := bACC;
		ret.CFen        := '0';
		ret.STKen       := STKen;
		ret.memAddr     := (others => '0');

		-- Decoding instruction group and CFen (condition flags enable)  
		-- Make the code of this case statement complete using the table below  

		-- (input are Opcode, StoreC and Ctrue, output is Group and CFen)   
		--     Opcode   StoreC  Ctrue Group CFen
		-- -------------------------------------
		--     ADD      0       x     G1    1
		--     SUB      0       x     G1    1
		--     MUL      0       x     G1    1
		--     DIV      0       x     G1    1
		--     REM      0       x     G1    1
		--     AND      0       x     G1    1
		--     OR       0       x     G1    1
		--     XOR      0       x     G1    1
		--     SHA      0       x     G1    1
		--     SHL      0       x     G1    1
		--     ROT      0       x     G1    1   
		--     ADD      1       x     G2    1
		--     SUB      1       x     G2    1
		--     MUL      1       x     G2    1
		--     DIV      1       x     G2    1
		--     REM      1       x     G2    1
		--     AND      1       x     G2    1
		--     OR       1       x     G2    1
		--     XOR      1       x     G2    1
		--     SHA      1       x     G2    1
		--     SHL      1       x     G2    1  
		--     ROT      1       x     G2    1   
		--     INC      x       x     G2    1 
		--     DEC      x       x     G2    1
		--     NOT      x       x     G2    1
		--     ZRO      x       x     G2    1
		--     CPR      x       x     G2    1  
		--     CMP      x       x     G3    1
		--     LD       x       x     G4    x 
		--     LDX      x       x     G5    x
		--     LDM      x       x     G6    x
		--     ST       x       x     G7    x
		--     STX      x       x     G8    x
		--     JYY      x       0     G12   x
		--     JYY      x       1     G9    x
		--     RTN      x       x     G10   x
		--     END      x       x     G11   x
		--     NLL      x       x     G12   x
		--     PSH      x       x     G13   x
		--     POP      x       x     G14   x
		--     IN_i     x       x     G15   x
		--     OUT_i    x       x     G16   x
		case_1: case opcode is
			when ADD_i | SUB_i | MUL_i | DIV_i | REM_i | AND_i | OR_i | XOR_i |
			SHA_i | SHL_i |ROT_i =>
				if (storeC = '0') then
					ret.instrGroup := G1;
					ret.CFen       := '1';
				else 
					ret.instrGroup := G2;
					ret.CFen       := '1';
				end if;

			when INC_i | DEC_i | NOT_i | ZRO_i | CPR_i =>
				ret.instrGroup := G2;
			when CMP_i =>
				ret.instrGroup := G3;
				ret.CFen       := '1';
			when LD_i =>
				ret.instrGroup := G4;
			when LDX_i =>
				ret.instrGroup := G5;
			when LDM_i =>
				ret.instrGroup := G6;
			when ST_i =>
				ret.instrGroup := G7;
			when STX_i =>
				ret.instrGroup := G8;
			when JYY_i =>
				if(Ctrue = '1') then
					ret.instrGroup := G9;
				else
					ret.instrGroup := G12;
				end if;
			when RTN_i =>
				ret.instrGroup := G10;
			when END_i =>
				ret.instrGroup := G11;
			when NLL_i =>
				ret.instrGroup := G12;
			when PSH_i =>
				ret.instrGroup := G13;
			when POP_i =>
				ret.instrGroup := G14;
			when IN_i =>
				ret.instrGroup := G15;
			when OUT_i =>
				ret.instrGroup := G16;
			when others =>
				ret.instrGroup := G12; -- Equivalent to NLL
		end case;

		-- decoding the rest of the control lines
		case_2: case opcode is
			when ADD_i =>  -- Addition
				ret.ALUsel  := ADD_OP;
				ret.Bsel    := Bsel;
				ret.DATAsel := ACC;
				ret.MBRsel  := DATABUS;
			when SUB_i =>  -- Subtraction
				ret.ALUsel  := SUB_OP;
				ret.Bsel    := Bsel;
				ret.DATAsel := ACC;
				ret.MBRsel  := DATABUS;
			when MUL_i =>  -- Multiplication
				ret.ALUsel  := MULT_OP;
				ret.Bsel    := Bsel;
				ret.DATAsel := ACC;
				ret.MBRsel  := DATABUS;
			when DIV_i =>  -- Division
				ret.ALUsel  := DIV_OP;
				ret.Bsel    := Bsel;
				ret.DATAsel := ACC;
				ret.MBRsel  := DATABUS;
			when REM_i =>  -- Remainder
				ret.ALUsel  := REM_OP;
				ret.Bsel    := Bsel;
				ret.DATAsel := ACC;
				ret.MBRsel  := DATABUS;
			when AND_i =>  -- AND
				ret.ALUsel  := AND_OP;
				ret.Bsel    := Bsel;
				ret.DATAsel := ACC;
				ret.MBRsel  := DATABUS;
			when OR_i =>   -- OR
				ret.ALUsel  := OR_OP;
				ret.Bsel    := Bsel;
				ret.DATAsel := ACC;
				ret.MBRsel  := DATABUS;
			when XOR_i =>  -- XOR
				ret.ALUsel  := XOR_OP;
				ret.Bsel    := Bsel;
				ret.DATAsel := ACC;
				ret.MBRsel  := DATABUS;

			when INC_i =>  -- Increment by 1
				ret.ALUsel  := INC_OP;
				ret.Bsel    := Bsel;
				ret.DATAsel := ACC;
				ret.MBRsel  := DATABUS;
			when DEC_i =>  -- Decrement by 1
				ret.ALUsel  := DEC_OP;
				ret.Bsel    := Bsel;
				ret.DATAsel := ACC;
				ret.MBRsel  := DATABUS;
			when NOT_i =>  -- Invert
				ret.ALUsel  := INV_OP;
				ret.Bsel    := Bsel;
				ret.DATAsel := ACC;
				ret.MBRsel  := DATABUS;
			when ZRO_i =>  -- Zero a register
				ret.ALUsel  := ZRO_OP;
				ret.Bsel    := Bsel;
				ret.DATAsel := ACC;
				ret.MBRsel  := DATABUS;
			when CPR_i =>  -- Copy register
				ret.ALUsel  := PASS_A;
				ret.Bsel    := Bsel;
				ret.DATAsel := ACC;
				ret.MBRsel  := DATABUS;

			when SHA_i =>  -- Arithmetic shift
				if shiftDirect = '1' THEN  -- LEFT
					ret.ALUsel := SHL_ARTH;
				else
					ret.ALUsel := SHR_ARTH;
				END if;
				ret.Bsel    := Bsel;
				ret.DATAsel := ACC;
				ret.MBRsel  := DATABUS;
			when SHL_i =>  -- Logic shift
				if shiftDirect = '1' THEN  -- LEFT
					ret.ALUsel := SHL_LGC;
				else
					ret.ALUsel := SHR_LGC;
				END if;
				ret.Bsel    := Bsel;
				ret.DATAsel := ACC;
				ret.MBRsel  := DATABUS;
			when ROT_i =>  -- Rotation
				if shiftDirect = '1' THEN  -- LEFT
					ret.ALUsel := ROTL;
				else
					ret.ALUsel := ROTR;
				END if;
				ret.Bsel    := Bsel;
				ret.DATAsel := ACC;
				ret.MBRsel  := DATABUS;

			when CMP_i =>  -- Compare
				ret.ALUsel  := SUB_OP;
				ret.Bsel    := Bsel;
				ret.DATAsel := ACC;
				ret.MBRsel  := DATABUS;
			when LD_i =>   -- Load register indirect
				ret.ALUsel  := PASS_A;
				ret.Bsel    := Bsel;
				ret.DATAsel := ACC;
				ret.MBRsel  := SYSTEMBUS;
			when LDX_i =>  -- Load register indexed
				ret.ALUsel  := ADD_OP;
				ret.Bsel    := "111" & inx;
				ret.DATAsel := ACC;
				ret.MBRsel  := SYSTEMBUS;
			when LDM_i =>  -- Load immediate
				ret.ALUsel  := PASS_A;
				ret.Bsel    := Bsel;
				ret.DATAsel := ctrlUnit;
				ret.MBRsel  := SYSTEMBUS;
				ret.memAddr := PAGE_0 & shortAddr;
			when ST_i =>   -- Store register indirect
				ret.ALUsel  := PASS_B;
				ret.Bsel    := Bsel;
				ret.DATAsel := ACC;
				ret.MBRsel  := DATABUS;
			when STX_i =>  -- Store register indexed
				ret.ALUsel  := PASS_B;
				ret.Bsel    := "111" & inx;
				ret.DATAsel := ACC;
				ret.MBRsel  := DATABUS;
			when JYY_i =>  -- Jump, branch or call subroutine
				ret.memAddr := PAGE_0 & shortAddr;
				if (cTrue = '1') then
					ret.ALUsel  := PASS_A;
					ret.Bsel    := Bsel;
					ret.DATAsel := ctrlUnit;
					ret.MBRsel  := SYSTEMBUS;
				else
					ret.ALUsel  := PASS_A;
					ret.Bsel    := Bsel;
					ret.DATAsel := ACC;
					ret.MBRsel  := DATABUS;
				end if;
			when RTN_i =>  -- Return from subroutine
				ret.ALUsel  := PASS_A;
				ret.Bsel    := Bsel;
				ret.DATAsel := STKout;
				ret.MBRsel  := DATABUS;
				ret.STKen   := '1';
			when END_i =>  -- End of program
				ret.ALUsel  := PASS_A;
				ret.Bsel    := Bsel;
				ret.DATAsel := ACC;
				ret.MBRsel  := DATABUS;
			when NLL_i =>  -- Null instruction
				ret.ALUsel  := PASS_A;
				ret.Bsel    := Bsel;
				ret.DATAsel := ACC;
				ret.MBRsel  := DATABUS;
			when PSH_i =>  -- Push in memory stack
				ret.ALUsel  := PASS_A;
				ret.Bsel    := "11111";
				ret.DATAsel := ACC;
				ret.MBRsel  := DATABUS;
				ret.memAddr := stkHighWord & (shortAddr'range => '0');
			when POP_i =>  -- Pop from memory stack
				ret.ALUsel  := PASS_B;
				ret.Bsel    := "11111";
				ret.DATAsel := ACC;
				ret.MBRsel  := SYSTEMBUS;
				ret.memAddr := stkHighWord & (shortAddr'range => '0');
			when IN_i =>   -- IO: IN
				ret.ALUsel  := PASS_A;
				ret.Bsel    := Bsel;
				ret.DATAsel := MBR;
				ret.MBRsel  := DATABUS;
			when OUT_i =>   -- IO: OUT
				ret.ALUsel  := PASS_B;
				ret.Bsel    := Bsel;
				ret.DATAsel := ACC;
				ret.MBRsel  := DATABUS;

			-- Arbitrary actions for invalid instructions
			when OTHERS =>
				ret.ALUsel  := PASS_B;
				ret.Bsel    := Bsel;
				ret.DATAsel := ACC;
				ret.MBRsel  := DATABUS;
		end case;

		return ret;
	end function;    
end package body;

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
-- File        : control.vhd
-- Design      : Control unit
-- Modification history : 2/1/07 : vwb : added G16 group
--------------------------------------------------------------------------------
-- Description : This unit controls the operation of the various components of 
-- the microprocessor to ensure performing the microprocessor functionality and
-- prevent data corruption
-- -----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use WORK.micro_pk.all;
use WORK.micro_control_pk.all;

entity control is
	port(
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
end entity;

architecture behavioral of control is
	signal dec : dec_t;
	signal exe : exe_t;

	signal n : std_logic; -- intermediate signal (= input 1 of and gate driveing cTrue)
	signal v : std_logic; -- intermediate signal (= input 2 of and gate driveing cTrue)
	signal z : std_logic; -- intermediate signal (= input 3 of and gate driveing cTrue)
	signal cTrue : std_logic;

	signal currentState : exeUnitState;
	signal nextState    : exeUnitState;

	-- Este alias para qué sirve? no está declarado ya?
	-- La cambiamos por dec.Bsel!! mirar a ver si no peta esto
	--alias Bsel : std_logic_vector (4 downto 0) is instReg (9 downto 5);
	-- condition mask
	alias cmask : std_logic_vector (5 downto 0) is instReg (6 downto 1); 
	alias pn : std_logic is instReg (6); -- polarity of negative
	alias pv : std_logic is instReg (5); -- polarity of overflow
	alias pz : std_logic is instReg (4); -- polarity of zero
	alias cn : std_logic is instReg (3); -- check negative
	alias cv : std_logic is instReg (2); -- check overflow
	alias cz : std_logic is instReg (1); -- check zero

	-- condition flags (from the ALU)
	alias neg : std_logic is cf (2); -- negative
	alias ovf : std_logic is cf (1); -- overflow
	alias zro : std_logic is cf (0); -- zero
begin
	-- ===========================================================================
	-- Checking condition
	------------------------------------------------------------------------------
	-- Describe the circuit to dricve cTrue as shown in the lab manual. 
	-- Use the alias above. 
	n <= ((not(neg xor pn)) and cn) or (not cn);
	v <= ((not(ovf xor pv)) and cv) or (not cv);
	z <= ((not(zro xor pz)) and cz) or (not cz);
	cTrue <= n and v and z;

	-- ===========================================================================
	-- Decode unit
	------------------------------------------------------------------------------
	-- Incorporate the decode unit here (using the decoding instruction 'decodeInstr')
	dec <= decodeInstr(instReg, cTrue);
	
	-- ===========================================================================
	-- Execute unit FSM
	------------------------------------------------------------------------------
	-- State register
	-- ---------------------------------------------------------------------------
	stateReg: process (rst, clk)
	begin
		if (rst = '1') then
			currentState <= reset1;
		elsif rising_edge (clk) then
			currentState <= nextState;
		end if;
	end process;

	------------------------------------------------------------------------------
	-- Next state decoding process
	-- ---------------------------------------------------------------------------
	nxtState: process (currentState, memReady, dec, vldInstr, IOReady)
		function selState (s1, s2 : exeUnitState; sel : std_logic) 
		return exeUnitState is
		begin
			if (sel = '1') then
				return s1;
			else
				return s2;
			end if;
		end function;
	begin
		case currentState is
			when reset1 =>
				nextState <= reset2;
			when reset2 =>
				nextState <= reset3;
			when reset3 =>
				nextState <= reset4;
			when reset4 =>
				nextState <= reset5;
			when reset5 =>
				nextState <= reset6;
			when reset6 =>
				nextState <= selState (reading, idle, vldInstr);

			when idle =>
				nextState <= selState (reading, idle, vldInstr);
			when reading =>
				nextState <= decoding;

			when decoding =>
				case dec.instrGroup is
					when G1 =>
						nextState <= g1s1;
					when G2 =>
						nextState <= g2s1;
					when G3 =>
						nextState <= g3s1;
					when G4 =>
						nextState <= g4s1;
					when G5 =>
						nextState <= g5s1;
					when G6 =>
						nextState <= g6s1;
					when G7 =>
						nextState <= g7s1;
					when G8 =>
						nextState <= g8s1;
					when G9 =>
						nextState <= g9s1;
					when G10 =>
						nextState <= g10s1;
					when G11 =>
						nextState <= g11s1;
					when G12 =>
						nextState <= g12s1;
					when G13 =>
						nextState <= g13s1;
					when G14 =>
						nextState <= g14s1;
					when G15 =>
						nextState <= g15s1;
					when G16 =>
						nextState <= g16s1;
					when OTHERS =>
						nextState <= idle;
				END case;

			-- ADD, SUB, MUL, DIV, REM, AND, OR, XOR, SHA, SHL, ROT
			-- without saving the result in the register file       
			when g1s1 =>
				nextState <= selState (reading, idle, vldInstr);    

			-- ADD, SUB, MUL, DIV, REM, AND, OR, XOR, SHA, SHL, ROT,
			-- INC, DEC, NOT, ZRO, CPR
			-- with saving the result in the register file  
			when g2s1 => 
				nextState <= g2s2;
			when g2s2 =>
				nextState <= selState (reading, idle, vldInstr);

			-- CMP
			when g3s1 =>
				nextState <= selState (reading, idle, vldInstr);

			-- LD          
			when g4s1 =>
				nextState <= g4s2;
			when g4s2 =>
				nextState <= g4s3;
			when g4s3 =>
				nextState <= selState (g4s4, g4s3, memReady); -- waiting for memory
			when g4s4 =>
				nextState <= g4s5;
			when g4s5 =>
				nextState <= selState (reading, idle, vldInstr);

			-- LDX
			when g5s1 =>
				nextState <= g5s2;
			when g5s2 =>
				nextState <= g5s3;
			when g5s3 =>
				nextState <= selState (g5s4, g5s3, memReady); -- waiting for memory;
			when g5s4 =>
				nextState <= g5s5;
			when g5s5 =>
				nextState <= selState (reading, idle, vldInstr);

			-- LDM
			when g6s1 =>
				nextState <= g6s2;
			when g6s2 =>
				nextState <= selState (g6s3, g6s2, memReady); -- waiting for memory;
			when g6s3 =>
				nextState <= g6s4;
			when g6s4 =>
				nextState <= selState (reading, idle, vldInstr);

			-- ST
			when g7s1 =>
				nextState <= g7s2;
			when g7s2 =>
				nextState <= g7s3;
			when g7s3 =>
				nextState <= g7s4;
			when g7s4 =>
				nextState <= selState (g7s5, g7s4, memReady); -- waiting for memory;
			when g7s5 =>
				nextState <= selState (reading, idle, vldInstr);

			-- STX 
			when g8s1 =>
				nextState <= g8s2;
			when g8s2 =>
				nextState <= g8s3;
			when g8s3 =>
				nextState <= g8s4;
			when g8s4 =>
				nextState <= selState (g8s5, g8s4, memReady); -- waiting for memory;
			when g8s5 =>
				nextState <= selState (reading, idle, vldInstr);

			-- JYY: successful branch/jump
			when g9s1 =>
				nextState <= g9s2;
			when g9s2 =>
				nextState <= selState (g9s3, g9s2, memReady); -- waiting for memory;
			when g9s3 =>
				nextState <= selState (g9s4, g9s3, vldInstr);
			when g9s4 =>
				nextState <= g9s5;
			when g9s5 =>
				nextState <= selState (reading, idle, vldInstr);

			-- RTN
			when g10s1 =>
				nextState <= selState (g10s1e, g10s1, vldInstr);
			when g10s1e => 
				nextState <= g10s2;
			when g10s2 =>
				nextState <= g10s3;
			when g10s3 =>
				nextState <= g10s4;
			when g10s4 =>
				nextState <= selState (reading, idle, vldInstr);

			-- END
			when g11s1 =>
				nextState <= g11s1;

			-- NLL or unsuccessful branch/jump
			when g12s1 =>
				nextState <= selState (reading, idle, vldInstr);

			-- PSH
			when g13s1 =>
				nextState <= g13s2;
			when g13s2 =>
				nextState <= g13s3;
			when g13s3 =>
				nextState <= g13s4;
			when g13s4 =>
				nextState <= selState (g13s5, g13s4, memReady); -- waiting for memory;
			when g13s5 =>
				nextState <= selState (reading, idle, vldInstr);

			-- POP
			when g14s1 =>
				nextState <= g14s2;
			when g14s2 =>
				nextState <= g14s3;
			when g14s3 =>
				nextState <= g14s4;
			when g14s4 =>
				nextState <= selState (g14s5, g14s4, memReady); -- waiting for memory;
			when g14s5 =>
				nextState <= g14s6;
			when g14s6 =>
				nextState <= selState (reading, idle, vldInstr);

			-- IN        
			when g15s1 =>
				nextState <= selState (g15s2, g15s1, IOReady); -- waiting for IO
			when g15s2 =>
				nextState <= g15s3;
			when g15s3 =>
				nextState <= selState (reading, idle, vldInstr);

			-- OUT
			when g16s1 =>
				nextState <= g16s2;
			when g16s2 =>
				nextState <= g16s3;
			when g16s3 =>
				nextState <= selState (g16s4, g16s3, IOReady); -- waiting for IO;
			when g16s4 =>
				nextState <= selState (reading, idle, vldInstr);

			when others =>
				nextState <= selState (reading, idle, vldInstr);
		end case;
	end process;

	------------------------------------------------------------------------------
	-- Output decoding process
	-- ---------------------------------------------------------------------------
	--   outp_decod: process (currentState, dec, instReg (9 downto 5))
	outp_decod: process (rst, clk)
	begin
		if (rst = '1') then
			readInstr     <= '0';    
			exe.RegFileWr <= '0';
			exe.Asel      <= "00000";
			exe.Bsel      <= "00000";
			exe.Csel      <= "00000";
			exe.stkInc    <= '0';
			exe.stkDec    <= '0';
			exe.ALUsel    <= PASS_A;
			exe.ACCen     <= '0';
			exe.CFen      <= '0';
			exe.MARen     <= '0';
			exe.MBRen     <= '0';
			exe.PCen      <= '0';
			exe.IRen      <= '0';
			exe.STKpop    <= '0';
			exe.STKpush   <= '0';
			exe.DATAsel   <= "00";
			exe.MBRsel    <= '0';
			exe.memRd     <= '0';
			exe.memWr     <= '0';
			IORd          <= '0';
			IOWr          <= '0';
			IO2MBR        <= '0';
		elsif rising_edge (clk) then
			-- defaults
			readInstr     <= '0';    
			exe.RegFileWr <= '0';
			exe.Asel      <= dec.Asel;
			exe.Bsel      <= dec.Bsel;
			exe.Csel      <= dec.Csel;
			exe.stkInc    <= '0';
			exe.stkDec    <= '0';
			exe.ALUsel    <= dec.ALUsel;
			exe.ACCen     <= '0';
			exe.CFen      <= '0';
			exe.MARen     <= '0';
			exe.MBRen     <= '0';
			exe.PCen      <= '0';
			exe.IRen      <= '0';
			exe.STKpop    <= '0';
			exe.STKpush   <= '0';
			exe.DATAsel   <= dec.DATAsel;
			exe.MBRsel    <= dec.MBRsel;
			exe.memRd     <= '0';
			exe.memWr     <= '0';
			IORd          <= '0';
			IOWr          <= '0';
			IO2MBR        <= '0';

			-- case currentState is

			case nextState is
				when reset1 =>
					exe.DATAsel   <= ACC;
					exe.MBRsel    <= SYSTEMBUS;
					exe.Csel      <= "11100";
					exe.ALUsel    <= ZRO_OP;
				when reset2 =>
					exe.DATAsel   <= ACC;
					exe.MBRsel    <= SYSTEMBUS;
					exe.Csel      <= "11100";
					exe.ALUsel    <= ZRO_OP;
					exe.ACCen     <= '1';
				when reset3 =>
					exe.DATAsel   <= ACC;
					exe.MBRsel    <= SYSTEMBUS;
					exe.Csel      <= "11100";
					exe.ALUsel    <= ZRO_OP;
					exe.RegFileWr <= '1';
					exe.PCen      <= '1';
				when reset4 =>
					exe.DATAsel   <= ACC;
					exe.MBRsel    <= SYSTEMBUS;
					exe.Csel      <= "11101";
					exe.ALUsel    <= ZRO_OP;
					exe.RegFileWr <= '1';
					readInstr     <= '1'; -- initialize the fetch unit
				when reset5 =>
					exe.DATAsel   <= ACC;
					exe.MBRsel    <= SYSTEMBUS;
					exe.Csel      <= "11110";
					exe.ALUsel    <= ZRO_OP;
					exe.RegFileWr <= '1';
				when reset6 =>
					exe.DATAsel   <= ACC;
					exe.MBRsel    <= SYSTEMBUS;
					exe.Csel      <= "11111";
					exe.ALUsel    <= ZRO_OP;
					exe.RegFileWr <= '1';
					readInstr     <= '1';

				when idle =>
					null;

				when reading =>
					readInstr     <= '1';
					exe.IRen      <= '1';

				when decoding =>
					null;

				-- ADD, SUB, MUL, DIV, REM, AND, OR, XOR, SHA, SHL, ROT
				-- without saving the result in the register file   
				when g1s1 =>
					exe.ACCen     <= '1';
					exe.CFen      <= '1'; 

				-- ADD, SUB, MUL, DIV, REM, AND, OR, XOR, SHA, SHL, ROT,
				-- INC, DEC, NOT, ZRO, CPR
				-- with saving the result in the register file  
				when g2s1 => 
					exe.ACCen     <= '1';
					exe.CFen      <= '1';
				when g2s2 =>
					exe.RegFileWr <= '1';

				-- CMP
				when g3s1 =>
					exe.CFen      <= '1';

				-- LD          
				when g4s1 =>
					exe.ACCen     <= '1';
				when g4s2 =>
					exe.MARen     <= '1';
				when g4s3 =>
					exe.memRd     <= '1';
					exe.DATAsel   <= MBR;
				when g4s4 =>
					exe.MBRen     <= '1';
					exe.DATAsel   <= MBR;
				when g4s5 =>
					exe.RegFileWr <= '1';
					exe.DATAsel   <= MBR;

				-- LDX
				when g5s1 =>
					exe.ACCen     <= '1';
				when g5s2 =>
					exe.MARen     <= '1';
				when g5s3 =>
					exe.memRd     <= '1';
					exe.DATAsel   <= MBR;
				when g5s4 =>
					exe.MBRen     <= '1';
					exe.DATAsel   <= MBR;
				when g5s5 =>
					exe.RegFileWr <= '1';
					exe.DATAsel   <= MBR;

				-- LDM
				when g6s1 =>
					exe.MARen     <= '1';
				when g6s2 => 
					exe.memRd     <= '1';
					exe.DATAsel   <= MBR;
				when g6s3 =>
					exe.MBRen     <= '1';
					exe.DATAsel   <= MBR;
				when g6s4 =>
					exe.RegFileWr <= '1';
					exe.DATAsel   <= MBR;

				-- ST
				when g7s1 =>
					exe.ACCen     <= '1';
				when g7s2 =>
					exe.ACCen     <= '1';
					exe.MBRen     <= '1';
					exe.ALUsel    <= PASS_A;
				when g7s3 =>
					exe.MARen     <= '1';
					exe.ALUsel    <= PASS_A;
				when g7s4 =>
					exe.memWr     <= '1';
					exe.ALUsel    <= PASS_A;
				when g7s5 =>
					exe.ALUsel    <= PASS_A;

				-- STX 
				when g8s1 =>
					exe.ACCen     <= '1';
					--exe.Bsel      <= Bsel;
					exe.Bsel      <= dec.Bsel;
				when g8s2 =>
					exe.ACCen     <= '1';
					exe.MBRen     <= '1';
					exe.ALUsel    <= ADD_OP;
					exe.Bsel      <= dec.Bsel;
				when g8s3 =>
					exe.MARen     <= '1';
					exe.ALUsel    <= ADD_OP;
					exe.Bsel      <= dec.Bsel;
				when g8s4 =>
					exe.memWr     <= '1';
					exe.ALUsel    <= ADD_OP;
					exe.Bsel      <= dec.Bsel;
				when g8s5 =>
					exe.ALUsel    <= ADD_OP;
					exe.Bsel      <= dec.Bsel;

				-- JYY: successful branch/jump
				when g9s1 =>
					exe.MARen     <= '1';
					exe.STKpush   <= '1';
				when g9s2 =>
					exe.memRd     <= '1';
					exe.DATAsel   <= MBR;
				when g9s3 =>
					exe.MBRen     <= '1';
					exe.DATAsel   <= MBR;
				when g9s4 =>
					exe.DATAsel   <= MBR;
					exe.PCen      <= '1';
					readInstr     <= '1';
				when g9s5 =>
					exe.DATAsel   <= MBR;

				-- RTN
				when g10s1 =>
					null;
				when g10s2 =>
					exe.STKpop    <= '1';
				when g10s3 =>
					exe.PCen      <= '1';
					readInstr     <= '1';
				when g10s4 =>
					null;

				-- END
				when g11s1 =>
					null;

				-- NLL or unsuccessful branch/jump
				when g12s1 =>
					null;

				-- PSH
				when g13s1 =>
					exe.ACCen     <= '1';
				when g13s2 =>
					exe.ACCen     <= '1';
					exe.MBRen     <= '1';
					exe.ALUsel    <= PASS_B;
				when g13s3 =>
					exe.stkInc    <= '1';
					exe.MARen     <= '1';
					exe.ALUsel    <= PASS_B;
				when g13s4 =>
					exe.memWr     <= '1';
					exe.ALUsel    <= PASS_B;
				when g13s5 =>
					exe.ALUsel    <= PASS_B;

				-- POP
				when g14s1 =>
					exe.stkDec    <= '1';
				when g14s2 =>
					exe.ACCen     <= '1';
				when g14s3 =>
					exe.MARen     <= '1';
				when g14s4 =>
					exe.memRd     <= '1';
					exe.DATAsel   <= MBR;
				when g14s5 =>
					exe.MBRen     <= '1';
					exe.DATAsel   <= MBR;
				when g14s6 =>
					exe.RegFileWr <= '1';
					exe.DATAsel   <= MBR;

				-- IN          
				when g15s1 =>
					IORd          <= '1';
					IO2MBR        <= '1';
				when g15s2 =>
					exe.MBRen     <= '1';
					IO2MBR        <= '1';
				when g15s3 =>
					exe.RegFileWr <= '1';
					IO2MBR        <= '1';

				-- OUT
				when g16s1 =>
					exe.ACCen     <= '1';
				when g16s2 =>
					exe.MBRen     <= '1';
				when g16s3 =>
					IOWr          <= '1';
				when g16s4 =>
					null;

				when others =>
					null;
			end case;
		end if;
	end process;

	-- ===========================================================================
	-- Control unit outputs
	-- ---------------------------------------------------------------------------
	-- RegFile control lines:
	RegFileWr   <= exe.RegFileWr;
	selA        <= exe.Asel;
	selB        <= exe.Bsel;
	selC        <= exe.Csel;
	stkInc      <= exe.stkInc;
	stkDec      <= exe.stkDec;
	-- ALU control lines
	ALUsel      <= exe.ALUsel;
	shiftCnt    <= dec.shiftCnt;
	shiftCntSrc <= dec.shiftCntSrc;
	portAsel    <= dec.portAsel;
	portBsel    <= dec.portBsel;
	-- Data flow control lines
	ACCen       <= exe.ACCen;
	CFen        <= dec.CFen and exe.CFen;
	MARen       <= exe.MARen;
	MBRen       <= exe.MBRen;
	PCen        <= exe.PCen;
	IRen        <= exe.IRen;
	DATAsel     <= exe.DATAsel;
	MBRsel      <= exe.MBRsel;
	-- Stack control lines
	STKen       <= dec.STKen;
	STKpop      <= exe.STKpop;
	STKpush     <= exe.STKpush;
	-- page_0 address
	memAddr     <= dec.memAddr;
	-- Memory control lines
	memRq       <= exe.memWr or exe.memRd;
	memWr       <= exe.memWr; 
	memRd       <= exe.memRd;
end architecture;

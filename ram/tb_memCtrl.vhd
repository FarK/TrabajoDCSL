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
-- File           : tb_memCtrl.vhd
-----------------------------------------------------------------------------
-- Description    : testbench for memory controller
-- --------------------------------------------------------------------------
-- Author         : Geert Vanwijnsberghe
-- Date           : 14/12/2006
-- Version        : 1.1
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
use work.micro_comp_pk.all;

--  +----------+                 +----------+
--  |          |<===DataToFch====|          |    
--  |          |                 |          |
--  |          |====addrFch=====>|          |
--  |  Fetch   |----rqFch------->|          |
--  |   Unit   |----rdFch------->|          |
--  |          |----wrFch------->|          |
--  |          |<--readyFch------|          |
--  +----------+                 |          |
--  +----------+                 |          |             +----------+
--  |          |<===DataToDPT====|          |<===dataOut==|          |
--  |          |==DataFromDPT===>|          |====dataIn==>|          |
--  |          |==addrDPT=======>|  Memory  |=====addr===>|          |
--  |   Data   |----rqDPT------->| Traffic  |             |   Main   |
--  |   Path   |----rdDPT------->| contoller|----memRd--->|  Memory  |
--  |          |----wrDPT------->|          |----memWr--->|          |  
--  |          |<--readyDPT------|          |<--memReady--|          |
--  +----------+                 |          |             +----------+
--  +----------+                 |          |
--  |          |<===DataToIO=====|          |    
--  |          |==DataFromIO====>|          |
--  |          |==addrIO========>|          |
--  |   I/O    |----rqIO-------->|          |
--  |   Unit   |----rdIO-------->|          |
--  |          |----wrIO-------->|          |
--  |          |<--readyIO-------|          |
--  +----------+                 +----------+


entity tb_memCtrl is
	end entity;

architecture test of tb_memCtrl is
	signal rst          : std_logic;
	signal clk          : std_logic;
	-- Data path        
	signal rqDPT        : std_logic;
	signal rdDPT        : std_logic;
	signal wrDPT        : std_logic;
	signal addrDPT      : std_logic_vector (ADDR_WIDTH - 1 downto 0);
	signal DataToDPT    : std_logic_vector (DATA_WIDTH - 1 downto 0);
	signal DataFromDPT  : std_logic_vector (DATA_WIDTH - 1 downto 0);
	signal readyDPT     : std_logic;
	-- Fetch unit       
	signal rqFch        : std_logic;
	signal rdFch        : std_logic; 
	signal addrFch      : std_logic_vector (ADDR_WIDTH - 1 downto 0);
	signal DataToFch    : std_logic_vector (DATA_WIDTH - 1 downto 0);
	signal readyFch     : std_logic;
	-- I/O unit         
	signal rqIO         : std_logic;
	signal rdIO         : std_logic;
	signal wrIO         : std_logic;
	signal addrIO       : std_logic_vector (ADDR_WIDTH - 1 downto 0);
	signal DataToIO     : std_logic_vector (DATA_WIDTH - 1 downto 0);
	signal DataFromIO   : std_logic_vector (DATA_WIDTH - 1 downto 0);
	signal readyIO      : std_logic;
	-- control signals
	signal addr         : std_logic_vector (ADDR_WIDTH - 1 downto 0);
	signal dataIn       : std_logic_vector (DATA_WIDTH - 1 downto 0);
	signal dataOut      : std_logic_vector (DATA_WIDTH - 1 downto 0);
	signal memRd        : std_logic;
	signal memWr        : std_logic;
	signal memReady     : std_logic;

	signal EndOfSim : boolean := false;
	constant clkPeriod : time := 10 ns;
	constant dutyCycle : real := 0.5; 
	constant delay : time := 1 ns;
begin
	U1: memCtrl 
	port map (
		rst => rst, 
		clk => clk,
		-- Data path
		rqDPT    => rqDPT,
		rdDPT    => rdDPT,
		wrDPT    => wrDPT,
		addrDPT  => addrDPT,
		inDPT    => DataToDPT,
		outDPT   => DataFromDPT,
		readyDPT => readyDPT,
		-- Fetch unit
		rqFch    => rqFch,
		rdFch    => rdFch, 
		addrFch  => addrFch,
		inFch    => DataToFch,
		readyFch => readyFch,
		-- I/O unit
		rqIO     => rqIO,
		rdIO     => rdIO,
		wrIO     => wrIO,
		addrIO   => addrIO,
		inIO     => DataToIO,
		outIO    => DataFromIO,
		readyIO  => readyIO,
		-- control signals
		addr     => addr,
		dataIn   => dataIn,
		dataOut  => dataOut,
		memRd    => memRd,
		memWr    => memWr,
		memReady => memReady
	);

	U2: memory 
	port map(
			clk     => clk,
			inBus   => dataIn,
			addr    => addr,
			rd      => memRd,
			wr      => memWr,
			outBus  => dataOut,
			ready   => memReady
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

	-- all input changes are alligned with the falling edge of clk
	main:process
	begin
		-- assign all inputs at time zero
		rqFch       <= '0';  
		rdFch       <= '0';  
		addrFch     <= (others => '0');   

		rqDPT       <= '0'; 
		rdDPT       <= '0';  
		wrDPT       <= '0';  
		addrDPT     <= (others => '0');    
		DataFromDPT <= (others => '0');

		rqIO        <= '0'; 
		rdIO        <= '0'; 
		wrIO        <= '0'; 
		addrIO      <= (others => '0');    
		DataFromIO  <= (others => '0'); 

		-- reset 
		rst <= '1';
		wait for clkPeriod;
		rst <= '0';
		wait for clkPeriod;

		-- Check readyXX after reset
		assert readyIO = '0'
		report " readyIO should be 0 "
		severity error;
		assert readyDPT = '0'
		report " readyDPT should be 0 "
		severity error;
		assert readyFch = '1'
		report " readyFch should be 1 "
		severity error;   

		-- write data in memory from DPT and IO (DPT has highest priority)
		rqDPT     <= '1'; 
		rdDPT     <= '0';  
		wrDPT     <= '1'; 
		rqIO      <= '1'; 
		rdIO      <= '0';  
		wrIO      <= '1';     
		for i in 0 to 20 loop 
			addrDPT     <= std_logic_vector(to_unsigned(i,12));    
			DataFromDPT <= std_logic_vector(to_unsigned(i+100,32));
			addrIO      <= std_logic_vector(to_unsigned(i,12));    
			DataFromIO  <= std_logic_vector(to_unsigned(i+50,32));
			wait for 2*clkPeriod;
			assert readyIO = '0'
			report " readyIO should be 0 "
			severity error;
			assert readyDPT = '1'
			report " readyDPT should be 1 "
			severity error;
			assert readyFch = '0'
			report " readyFch should be 0 "
			severity error;      
		end loop;

		-- write data in memory from  IO 
		rqDPT       <= '0'; 
		rdDPT       <= '0';  
		wrDPT       <= '0'; 
		rqIO        <= '1'; 
		rdIO        <= '0';  
		wrIO        <= '1'; 
		for i in 21 to 40 loop 
			addrDPT   <= std_logic_vector(to_unsigned(i,12));    
			DataFromDPT   <= std_logic_vector(to_unsigned(i+100,32));
			addrIO    <= std_logic_vector(to_unsigned(i,12));    
			DataFromIO    <= std_logic_vector(to_unsigned(i+50,32));
			wait for 2*clkPeriod;
			assert readyIO = '1'
			report " readyIO should be 1 "
			severity error;
			assert readyDPT = '0'
			report " readyDPT should be 0 "
			severity error;
			assert readyFch = '0'
			report " readyFch should be 0 "
			severity error;      
		end loop;  

		-- de-assert all control
		rqDPT       <= '0'; 
		rdDPT       <= '0';  
		wrDPT       <= '0'; 
		rqIO        <= '0'; 
		rdIO        <= '0';  
		wrIO        <= '0';     
		rqFch       <= '0';  
		rdFch       <= '0';  
		-- set address and data to some random value
		addrIO      <= (others => '1');    
		DataFromIO  <= (others => '1'); 
		addrDPT     <= (others => '1');    
		DataFromDPT <= (others => '1');
		addrFch     <= (others => '1');       
		wait for clkPeriod;

		-- Check readyXX 
		assert readyIO = '0'
		report " readyIO should be 0 "
		severity error;
		assert readyDPT = '0'
		report " readyDPT should be 0 "
		severity error;
		assert readyFch = '1'
		report " readyFch should be 1 "
		severity error;   
		wait for clkPeriod;


		-- read data from IO
		rqDPT     <= '0'; 
		rdDPT     <= '0';  
		wrDPT     <= '0'; 
		rqIO      <= '1'; 
		rdIO      <= '1';  
		wrIO      <= '0';     
		rqFch     <= '0';  
		rdFch     <= '0';  
		for i in 0 to 20 loop 
			addrIO    <= std_logic_vector(to_unsigned(i,12));    
			wait for 2*clkPeriod;
			assert readyIO = '1'
			report " readyIO should be 1 "
			severity error;
			assert readyDPT = '0'
			report " readyDPT should be 0 "
			severity error;
			assert readyFch = '0'
			report " readyFch should be 0 "
			severity error;
			assert DataToIO =  std_logic_vector(to_unsigned(i+100,32))
			report " wrong value for DataToIO "
			severity error;              
		end loop;  

		-- de-assert all control
		rqDPT       <= '0'; 
		rdDPT       <= '0';  
		wrDPT       <= '0'; 
		rqIO        <= '0'; 
		rdIO        <= '0';  
		wrIO        <= '0';     
		rqFch       <= '0';  
		rdFch       <= '0';  
		-- set address and data to some random value
		addrIO      <= (others => '1');    
		DataFromIO  <= (others => '1'); 
		addrDPT     <= (others => '1');    
		DataFromDPT <= (others => '1');
		addrFch     <= (others => '1');    
		wait for clkPeriod;

		-- Check readyXX 
		assert readyIO = '0'
		report " readyIO should be 0 "
		severity error;
		assert readyDPT = '0'
		report " readyDPT should be 0 "
		severity error;
		assert readyFch = '1'
		report " readyFch should be 1 "
		severity error;   
		wait for clkPeriod;

		-- read data from DPT (also from IO but DPT has highest priority)
		rqDPT     <= '1'; 
		rdDPT     <= '1';  
		wrDPT     <= '0'; 
		rqIO      <= '1'; 
		rdIO      <= '1';  
		wrIO      <= '0';     
		rqFch     <= '0';  
		rdFch     <= '0';  
		for i in 21 to 40 loop 
			addrDPT    <= std_logic_vector(to_unsigned(i,12));    
			wait for 2*clkPeriod;
			assert readyIO = '0'
			report " readyIO should be 0 "
			severity error;
			assert readyDPT = '1'
			report " readyDPT should be 1 "
			severity error;
			assert readyFch = '0'
			report " readyFch should be 0 "
			severity error;
			assert DataToDPT =  std_logic_vector(to_unsigned(i+50,32))
			report " wrong value for DataToDPT "
			severity error;              
		end loop;      

		-- de-assert all control
		rqDPT     <= '0'; 
		rdDPT     <= '0';  
		wrDPT     <= '0'; 
		rqIO      <= '0'; 
		rdIO      <= '0';  
		wrIO      <= '0';     
		rqFch     <= '0';  
		rdFch     <= '0';  
		-- set address and data to some random value
		addrIO      <= (others => '1');    
		DataFromIO  <= (others => '1'); 
		addrDPT     <= (others => '1');    
		DataFromDPT <= (others => '1');
		addrFch     <= (others => '1');    
		wait for clkPeriod;

		-- Check readyXX 
		assert readyIO = '0'
		report " readyIO should be 0 "
		severity error;
		assert readyDPT = '0'
		report " readyDPT should be 0 "
		severity error;
		assert readyFch = '1'
		report " readyFch should be 1 "
		severity error;   
		wait for clkPeriod;

		-- read data from Fetch (also from IO and DPT but fetch has highest priority)
		rqDPT     <= '1'; 
		rdDPT     <= '1';  
		wrDPT     <= '0'; 
		rqIO      <= '1'; 
		rdIO      <= '1';  
		wrIO      <= '0';     
		rqFch     <= '1';  
		rdFch     <= '1';  
		for i in 0 to 10 loop 
			addrFch    <= std_logic_vector(to_unsigned(i,12));    
			wait for 2*clkPeriod;
			assert readyIO = '0'
			report " readyIO should be 0 "
			severity error;
			assert readyDPT = '0'
			report " readyDPT should be 0 "
			severity error;
			assert readyFch = '1'
			report " readyFch should be 1 "
			severity error;
			assert DataToFch =  std_logic_vector(to_unsigned(i+100,32))
			report " wrong value for DataToDPT "
			severity error;              
		end loop;      

		report " This is not a complete test. Not all arrows of the FSM inside the memCtrl are tested";
		EndOfSim <= true;
		wait;
	end process;
end architecture;

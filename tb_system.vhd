library IEEE;
use IEEE.std_logic_1164.all;

entity TB_system is
end entity;

architecture TB of TB_system is

  component system 
    port (
      rst : in std_logic;
      clk : in std_logic;
      RxD : in std_logic;
      TxD : out std_logic
      );  
  end component;

  component uart_fake is
    generic( Baudrate : natural :=115200;
             IdleBits : natural :=3;   -- Delay between 2 characters expressed in bits
             TXstring : string  :="abc123");          
    port( 
         RX      : in std_logic;
         StartTX : in std_logic;
         TX      : out std_logic
        );
  end component;

  signal Rst : std_logic;
  signal Clk : std_logic;
  signal ToFPGA   : std_logic;
  signal FromFPGA : std_logic;
  signal StartTX  : std_logic;
  
  
begin

U1: system
port map(
  rst => Rst,
  clk => Clk,
  RxD => ToFPGA,
  TxD => FromFPGA
);


U2: uart_fake
generic map (
     Baudrate  => 115200,
     IdleBits  => 20,
     TXstring  => "Eindelijk 0"
     )
port map (
    RX      => FromFPGA,
    TX      => ToFPGA, 
    StartTX => StartTX);
    
process
begin
  Clk <='0';
  wait for 5 ns;
  Clk <='1';
  wait for 5 ns;
end process;
        
main: process
begin
  StartTX <= '0';
  Rst <= '1';
  wait for 1 ms ;


  StartTX <= '1';
  wait for 2 ms;
  wait;
end process main;


end TB;
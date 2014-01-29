library IEEE;
use IEEE.std_logic_1164.all;

entity TB_uart_fake is
end entity;

architecture behav of TB_uart_fake is

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

  signal RXTX        : std_logic;
  signal Zero        : std_logic:='0';
  signal StartTX	 : std_logic;
  signal EndOfSim    : boolean:=false;
  
begin    

transmitter: uart_fake
generic map (
     Baudrate  => 115200,
     IdleBits  => 3,
     TXstring  => "Bond 007"
     )
port map (
    RX      => Zero,
    TX      => RXTX, 
    StartTX => StartTX);

receiver: uart_fake
generic map (
     Baudrate  => 115200,
     IdleBits  => 0,
     TXstring  => " "
     )
port map (
    RX      => RXTX,
    TX      => open, 
    StartTX => Zero);
  
main:process
begin
  wait for 1 ms;
  StartTX <= '1';
  wait for 20 ms;
  EndOfSim <= true;
  wait;
end process;
 
end architecture;    
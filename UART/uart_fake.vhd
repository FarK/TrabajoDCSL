-- Fake model fo the uart
-- no parity

use std.textio.all;

library IEEE;
use ieee.std_logic_textio.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity uart_fake is
  generic( Baudrate : natural:=115200;                                             
           IdleBits : natural:=3;   -- Delay between 2 characters expressed in bits
           TXstring : string :="abc123");                                           
  port( 
       RX      : in std_logic;
       StartTX : in std_logic;
       TX      : out std_logic
      );
end uart_fake;


architecture sim_only of uart_fake is
  
  constant Bitperiod : time := (1000000000/baudrate) * 1 ns ;  
  
  function ASCII2string (A:std_logic_vector) return string is
	variable ASCIICODE : std_logic_vector(7 downto 0);
  begin
  ASCIICODE := A(7 downto 0);
  case ASCIICODE is
    when  x"20" => return " ";
    when  x"30" => return "0";
    when  x"31" => return "1";
    when  x"32" => return "2";
    when  x"33" => return "3";
    when  x"34" => return "4";
    when  x"35" => return "5";
    when  x"36" => return "6";
    when  x"37" => return "7";
    when  x"38" => return "8";
    when  x"39" => return "9";
    when  x"41" => return "A";
    when  x"42" => return "B";
    when  x"43" => return "C";
    when  x"44" => return "D";
    when  x"45" => return "E";
    when  x"46" => return "F";
    when  x"47" => return "G";
    when  x"48" => return "H";
    when  x"49" => return "I";
    when  x"4A" => return "J";
    when  x"4B" => return "K";
    when  x"4C" => return "L";
    when  x"4D" => return "M";
    when  x"4E" => return "N";
    when  x"4F" => return "O";
    when  x"50" => return "P";
    when  x"51" => return "Q";
    when  x"52" => return "R";
    when  x"53" => return "S";
    when  x"54" => return "T";
    when  x"55" => return "U";
    when  x"56" => return "V";
    when  x"57" => return "W";
    when  x"58" => return "X";
    when  x"59" => return "Y";
    when  x"5A" => return "Z";
    when  x"61" => return "a";
    when  x"62" => return "b";
    when  x"63" => return "c";
    when  x"64" => return "d";
    when  x"65" => return "e";
    when  x"66" => return "f";
    when  x"67" => return "g";
    when  x"68" => return "h";
    when  x"69" => return "i";
    when  x"6A" => return "j";
    when  x"6B" => return "k";
    when  x"6C" => return "l";
    when  x"6D" => return "m";
    when  x"6E" => return "n";
    when  x"6F" => return "o";
    when  x"70" => return "p";
    when  x"71" => return "q";
    when  x"72" => return "r";
    when  x"73" => return "s";
    when  x"74" => return "t";
    when  x"75" => return "u";
    when  x"76" => return "v";
    when  x"77" => return "w";
    when  x"78" => return "x";
    when  x"79" => return "y";
    when  x"7A" => return "z";
    when  others => return "not implemented ASCII";
  end case;
  end ASCII2string;

  function Char2ASCII (A:character) return bit_vector is   
  begin
  case A is
    when  ' ' => return x"20";
    when  '0' => return x"30";
    when  '1' => return x"31";
    when  '2' => return x"32";
    when  '3' => return x"33";
    when  '4' => return x"34";
    when  '5' => return x"35";
    when  '6' => return x"36";
    when  '7' => return x"37";
    when  '8' => return x"38";
    when  '9' => return x"39";
    when  'A' => return x"41";
    when  'B' => return x"42";
    when  'C' => return x"43";
    when  'D' => return x"44";
    when  'E' => return x"45";
    when  'F' => return x"46";
    when  'G' => return x"47";
    when  'H' => return x"48";
    when  'I' => return x"49";
    when  'J' => return x"4A";
    when  'K' => return x"4B";
    when  'L' => return x"4C";
    when  'M' => return x"4D";
    when  'N' => return x"4E";
    when  'O' => return x"4F";
    when  'P' => return x"50";
    when  'Q' => return x"51";
    when  'R' => return x"52";
    when  'S' => return x"53";
    when  'T' => return x"54";
    when  'U' => return x"55";
    when  'V' => return x"56";
    when  'W' => return x"57";
    when  'X' => return x"58";
    when  'Y' => return x"59";
    when  'Z' => return x"5A";
    when  'a' => return x"61";
    when  'b' => return x"62";
    when  'c' => return x"63";
    when  'd' => return x"64";
    when  'e' => return x"65";
    when  'f' => return x"66";
    when  'g' => return x"67";
    when  'h' => return x"68";
    when  'i' => return x"69";
    when  'j' => return x"6A";
    when  'k' => return x"6B";
    when  'l' => return x"6C";
    when  'm' => return x"6D";
    when  'n' => return x"6E";
    when  'o' => return x"6F";
    when  'p' => return x"70";
    when  'q' => return x"71";
    when  'r' => return x"72";
    when  's' => return x"73";
    when  't' => return x"74";
    when  'u' => return x"75";
    when  'v' => return x"76";
    when  'w' => return x"77";
    when  'x' => return x"78";
    when  'y' => return x"79";
    when  'z' => return x"7A";
    when  others  => return x"23";
  end case;
  end Char2ASCII;
  
begin
   -- receiving
   -- assume no parity bit !
   process
     variable L : line;
     variable word : std_logic_vector(7 downto 0);
   begin
     wait until rx='0';    -- wait for startbit
     wait for (0.5 * Bitperiod); -- Middle of the startbit
     assert rx ='0'
       report "Error in startbit" severity warning;
     wait for Bitperiod;
     for i in 0 to 7 loop        -- data bits
       word(i) := rx;
       wait for Bitperiod;
     end loop;
     --wait for Bitperiod;         -- stop bit
     assert rx = '1'
       report "Error in stopbit" severity warning;
     write (L, string'("Char received in hex = "));
     hwrite (L,word);
     write (L, string'(" -- "));
     write (L,ASCII2string(word));
     writeline (output,L);
   end process;

  -- sending
  -- no parity bit  
  process
     variable L : line;
     variable word : bit_vector(7 downto 0);
   begin
     TX <= '1';
     wait until StartTX='1';       -- wait for StartTX
     -- loop over the characters of the string
     for j in TXstring'range loop
       word := Char2ASCII(TXstring(j));
       TX <= '0';                    -- start bit
       wait for Bitperiod;
       for i in 0 to 7 loop          -- data bits
         TX <= std_logic(To_StdULogic(word(i))) ;
         wait for Bitperiod;
       end loop;
       TX <= '1';                    -- stop bit
       wait for Bitperiod; 
       wait for IdleBits*Bitperiod;  -- pause between characters
     end loop;    
     report " transmit of fake uart done" ;     
     wait;
   end process;   
      
end sim_only;





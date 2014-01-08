library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use WORK.micro_pk.all;

package micro_ram_pk is

  constant RAM_CONTENTS : memContents_t (0 to 2 ** ADDR_WIDTH - 1);
  
end package;
------------------------------------------------------------------------------
package body micro_ram_pk is

  constant RAM_CONTENTS : memContents_t (0 to 2 ** ADDR_WIDTH - 1) := (
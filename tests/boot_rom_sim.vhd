-- Simulation-only model, same bytes as the synthesized pROM INIT_RAM values.
-- This architecture is deliberately excluded from the Gowin project.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
architecture simulation of Gowin_Z1013_ROM is
 type bytes_t is array(0 to 8191) of std_logic_vector(7 downto 0);
 impure function load return bytes_t is
  type binary_file_t is file of character;
  file f:binary_file_t open read_mode is "z1013_boot_rom.bin";
  variable c:character;
  variable bytes:bytes_t;
 begin
  for i in bytes'range loop
   assert not endfile(f) report "Boot ROM shorter than 8192 bytes" severity failure;
   read(f,c);bytes(i):=std_logic_vector(to_unsigned(character'pos(c),8));
  end loop;
  assert endfile(f) report "Boot ROM longer than 8192 bytes" severity failure;
  return bytes;
 end;
 constant rom:bytes_t:=load;
begin
 process(clk)
 begin
  if rising_edge(clk) then
   if reset='1' then dout<=(others=>'0');
   elsif ce='1' and oce='1' then dout<=rom(to_integer(unsigned(ad)));end if;
  end if;
 end process;
end;

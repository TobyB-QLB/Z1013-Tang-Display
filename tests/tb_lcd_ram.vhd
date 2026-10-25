library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;
entity tb_lcd_ram is end;
architecture sim of tb_lcd_ram is
 signal cpu_clk,video_clk:std_logic:='0';
 signal cpu_addr,video_addr:std_logic_vector(12 downto 0):=(others=>'0');
 signal din,dout,vout:std_logic_vector(7 downto 0);
 signal we:std_logic:='0';
 function data(a:natural) return std_logic_vector is
 begin return std_logic_vector(to_unsigned((a*7+(a/2048)*37) mod 256,8));end;
begin
 cpu_clk<=not cpu_clk after 6734 ps;
 video_clk<=not video_clk after 55556 ps;
 dut:entity work.color_ram port map(cpu_clk,cpu_addr,din,dout,we,video_clk,video_addr,vout);
 process begin
  -- Check initialization across all four physical banks before writes.
  for bank in 0 to 3 loop
   video_addr<=std_logic_vector(to_unsigned(bank*2048+2047,13));
   wait until rising_edge(video_clk);wait for 1 ns;
   assert vout=x"0F" report "Color initialization or bank selection failed" severity failure;
  end loop;
  -- Write every address and check CPU write-through, including bank changes.
  for a in 0 to 8191 loop
   wait until falling_edge(cpu_clk);
   cpu_addr<=std_logic_vector(to_unsigned(a,13));din<=data(a);we<='1';
   wait until rising_edge(cpu_clk);wait for 1 ns;
   assert dout=data(a) report "CPU write-through failed" severity failure;
  end loop;
  wait until falling_edge(cpu_clk);we<='0';
  for a in 0 to 8191 loop
   cpu_addr<=std_logic_vector(to_unsigned(a,13));
   wait until rising_edge(cpu_clk);wait for 1 ns;
   assert dout=data(a) report "CPU read/bank selection failed" severity failure;
   wait until falling_edge(cpu_clk);
  end loop;
  for a in 0 to 8191 loop
   video_addr<=std_logic_vector(to_unsigned(a,13));
   wait until rising_edge(video_clk);wait for 1 ns;
   assert vout=data(a) report "LCD read/bank selection failed" severity failure;
  end loop;
  report "PASS: all 8192 RAM addresses, four DPB banks, color initialization, CPU write-through, independent LCD reads";
  stop;
 end process;
end;

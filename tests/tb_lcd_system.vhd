library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use std.env.all;
entity tb_lcd_system is end;
architecture sim of tb_lcd_system is
 signal clk : std_logic := '0';
 signal video_clk : std_logic := '0';
 signal rst_n : std_logic := '0';
 signal de,hs,vs : std_logic;
 signal r,g,b : std_logic_vector(7 downto 0);
 function sl(v:boolean) return std_logic is begin if v then return '1'; else return '0'; end if; end;
begin
 clk <= not clk after 15152 ps;
 video_clk <= not video_clk after 55556 ps;
 rst_n <= '1' after 1 us;
 dut: entity work.testpattern port map(
  I_pxl_clk=>clk,I_rst_n=>rst_n,I_video_clk=>video_clk,I_video_rst_n=>rst_n,
  I_usb_event=>x"00",I_usb_valid=>'0',I_ps2_clk=>'1',I_ps2_data=>'1',I_sd_miso=>'1',
  I_mode=>"000",I_single_r=>x"00",I_single_g=>x"00",I_single_b=>x"00",
  I_h_total=>x"208",I_h_sync=>x"004",I_h_bporch=>x"017",I_h_res=>x"1E0",
  I_v_total=>x"12C",I_v_sync=>x"004",I_v_bporch=>x"00F",I_v_res=>x"110",
  I_hs_pol=>'0',I_vs_pol=>'0',O_de=>de,O_hs=>hs,O_vs=>vs,O_data_r=>r,O_data_g=>g,O_data_b=>b,
  O_sd_clk=>open,O_sd_cs_n=>open,O_sd_mosi=>open,O_sd_activity=>open,
  O_ted_frequency_1=>open,O_ted_frequency_2=>open,O_ted_control=>open,O_ted_reload=>open,
  O_pcm_control=>open,O_cassette_bit=>open,O_cassette_active=>open);
 process
  variable h,v,prev_h,prev_v : integer := 0;
  variable prev_de,prev_hs,prev_vs : std_logic := '0';
  variable ready:boolean:=false;
  variable frames,active_pixels,lit_pixels,unknown_pixels : natural:=0;
  variable l:line;
  file picture:text open write_mode is "lcd_boot.ppm";
 begin
  write(l,string'("P3"));writeline(picture,l);
  write(l,string'("480 272"));writeline(picture,l);
  write(l,string'("255"));writeline(picture,l);
  wait until rst_n='1';
  loop
   wait until rising_edge(video_clk); wait for 1 ns;
   if ready then
    assert de=prev_de report "DE raster/pipeline mismatch" severity failure;
    assert hs=prev_hs and vs=prev_vs report "Sync raster/pipeline mismatch" severity failure;
    if frames=3 and prev_de='1' then
     active_pixels:=active_pixels+1;
     if is_x(r&g&b) then unknown_pixels:=unknown_pixels+1;
     elsif (r&g&b)/=x"000000" then
      lit_pixels:=lit_pixels+1;
      assert prev_h>=139 and prev_h<395 and prev_v>=27 and prev_v<283
       report "Lit pixel outside centered 256x256 Z1013 area" severity failure;
     end if;
     if not is_x(r&g&b) then
      write(l,to_integer(unsigned(r)));write(l,string'(" "));
      write(l,to_integer(unsigned(g)));write(l,string'(" "));
      write(l,to_integer(unsigned(b)));writeline(picture,l);
     else write(l,string'("255 0 255"));writeline(picture,l); end if;
    end if;
   end if;
   prev_h:=h;prev_v:=v;
   prev_de:=sl(h>=27 and h<507 and v>=19 and v<291);
   prev_hs:=sl(h>=4);prev_vs:=sl(v>=4);ready:=true;
   if h=519 then
    h:=0;
    if v=299 then
     v:=0;frames:=frames+1;
     if frames=4 then
      assert active_pixels=480*272 report "Active resolution mismatch" severity failure;
      assert unknown_pixels=0 report "Uninitialized visible VRAM after boot" severity failure;
      assert lit_pixels>100 report "No Z1013 boot text visible" severity failure;
      report "PASS: 4 LCD frames, 480x272, sync, pipeline, centered 256x256, CPU/ROM boot; lit pixels=" & integer'image(lit_pixels);
      stop;
     end if;
    else v:=v+1;end if;
   else h:=h+1;end if;
  end loop;
 end process;
end;

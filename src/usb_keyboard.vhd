library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- German USB keyboard front end.
-- USB HID events are mapped directly to the Z1013 keyboard matrix.
-- bit 7 = release, FF clears unplugged keys.
entity usb_keyboard is
 port(I_clk, I_rst_n: in std_logic;
      I_event: in std_logic_vector(7 downto 0); I_valid: in std_logic;
      O_matrix: out std_logic_vector(79 downto 0);
      O_reset_request: out std_logic;
      O_cpu_speed: out std_logic_vector(1 downto 0);
      O_speed_changed: out std_logic);
end;

architecture rtl of usb_keyboard is

 signal held : std_logic_vector(111 downto 0) := (others=>'0');
 attribute syn_ramstyle : string;
 attribute syn_ramstyle of held : signal is "registers";

 signal caps_lock     : std_logic := '0';
 signal reset_request : std_logic := '0';

 signal cpu_speed     : std_logic_vector(1 downto 0) := "11";
 signal speed_changed : std_logic := '0';

 -- F1/F2/F3 macro timing: 40 ms per phase at 33 MHz.
 constant MACRO_PHASE_LAST_C : unsigned(21 downto 0) :=
     to_unsigned(1319999, 22);

 signal macro_phase   : integer range 0 to 38 := 0;
 signal macro_counter : unsigned(21 downto 0) := (others=>'0');
 type macro_command_t is (MACRO_DD, MACRO_DL, MACRO_DOS);
 signal macro_command : macro_command_t := MACRO_DD;

begin

 O_reset_request <= reset_request;
 O_cpu_speed     <= cpu_speed;
 O_speed_changed <= speed_changed;

 ---------------------------------------------------------------------------
 -- USB HID state and local commands.
 --
 -- Companion protocol:
 --   bits 6..0 = HID usage
 --   bit 7     = release
 --   FF        = keyboard disconnected / clear state
 ---------------------------------------------------------------------------
 process(I_clk,I_rst_n)
  variable h       : integer;
  variable pressed : std_logic;
  variable ctrl    : boolean;
  variable alt     : boolean;
 begin
  if I_rst_n='0' then
   held          <= (others=>'0');
   caps_lock     <= '0';
   reset_request <= '0';
   cpu_speed     <= "11";
   speed_changed <= '0';
   macro_phase   <= 0;
   macro_counter <= (others=>'0');
   macro_command <= MACRO_DD;

  elsif rising_edge(I_clk) then
   reset_request <= '0';
   speed_changed <= '0';

   -- Advance an active F1/F2/F3 macro.
   if macro_phase /= 0 then
    if macro_counter = MACRO_PHASE_LAST_C then
     macro_counter <= (others=>'0');
     if (macro_phase = 10 and macro_command /= MACRO_DOS) or
        macro_phase = 38 then
      macro_phase <= 0;
     else
      macro_phase <= macro_phase + 1;
     end if;
    else
     macro_counter <= macro_counter + 1;
    end if;
   end if;

   if I_valid='1' then
    if I_event=x"FF" then
     held <= (others=>'0');

    else
     h := to_integer(unsigned(I_event(6 downto 0)));
     pressed := not I_event(7);

     if h < 112 then
      held(h) <= pressed;

      -- Caps Lock: USB HID usage 57.
      if h=57 and pressed='1' then
       caps_lock <= not caps_lock;
      end if;

      -- F1 -> @DD + Enter
      if h=58 and pressed='1' and macro_phase=0 then
       macro_command <= MACRO_DD;
       macro_phase   <= 1;
       macro_counter <= (others=>'0');
      end if;

      -- F2 -> @DL + Enter
      if h=59 and pressed='1' and macro_phase=0 then
       macro_command <= MACRO_DL;
       macro_phase   <= 1;
       macro_counter <= (others=>'0');
      end if;

      -- F3 -> @DL + Enter, wait 520 ms, then DOS.COM + Enter.
      if h=60 and pressed='1' and held(60)='0' and macro_phase=0 then
       macro_command <= MACRO_DOS;
       macro_phase   <= 1;
       macro_counter <= (others=>'0');
      end if;

      -- F9 .. F12 select CPU speed.
      if pressed='1' then
       case h is
        when 66 => cpu_speed <= "00"; speed_changed <= '1'; -- F9
        when 67 => cpu_speed <= "01"; speed_changed <= '1'; -- F10
        when 68 => cpu_speed <= "10"; speed_changed <= '1'; -- F11
        when 69 => cpu_speed <= "11"; speed_changed <= '1'; -- F12
        when others => null;
       end case;
      end if;

      -- Ctrl+Alt+Delete
      ctrl := held(104)='1' or held(108)='1';
      alt  := held(106)='1' or held(110)='1';

      if h=76 and pressed='1' and ctrl and alt then
       reset_request <= '1';
      end if;

     end if;
    end if;
   end if;
  end if;
 end process;


 ---------------------------------------------------------------------------
 -- Direct USB HID -> Z1013 matrix conversion.
 --
 -- No synthetic PS/2 scan-code path is used here. PS/2 remains an
 -- independent input in dual_keyboard.vhd.
 ---------------------------------------------------------------------------
 process(held,caps_lock,macro_phase,macro_command)
  variable m : std_logic_vector(79 downto 0);
  variable shift,altgr : boolean;
  variable symbol_active,symbol_shift : boolean;

  procedure symbol(constant key : integer;
                   constant shifted : boolean) is
  begin
   m(key) := '1';
   symbol_active := true;
   if shifted then
    symbol_shift := true;
   end if;
  end;

 begin
  m := (others=>'0');

  shift :=
      held(105)='1' or
      held(109)='1';

  altgr := held(110)='1';

  symbol_active := false;
  symbol_shift  := false;

  if macro_phase /= 0 then

   case macro_phase is
    when 1 =>
     m(2) := '1';
    when 2 =>
     m(2)  := '1';
     m(63) := '1';
    when 3 =>
     m(2) := '1';
    when 5 =>
     m(27) := '1';
    when 7 =>
     if macro_command /= MACRO_DD then
      m(21) := '1';
     else
      m(27) := '1';
     end if;
    when 9 =>
     m(18) := '1';
    -- F3 only: phases 10..22 release all keys for 520 ms.
    when 23 => m(27) := '1'; -- D
    when 25 => m(38) := '1'; -- O
    when 27 => m(28) := '1'; -- S
    when 29 => m(4)  := '1'; -- .
    when 31 => m(10) := '1'; -- C
    when 33 => m(38) := '1'; -- O
    when 35 => m(6)  := '1'; -- M
    when 37 => m(18) := '1'; -- Enter
    when others =>
     null;
   end case;

  else

   ------------------------------------------------------------------------
   -- Alphabetic keys.
   -- USB HID usages 4..29. Y/Z are swapped for German QWERTZ.
   ------------------------------------------------------------------------
   if held(4) ='1' then m(29):='1'; end if; -- A
   if held(5) ='1' then m(8) :='1'; end if; -- B
   if held(6) ='1' then m(10):='1'; end if; -- C
   if held(7) ='1' then m(27):='1'; end if; -- D
   if held(8) ='1' then m(44):='1'; end if; -- E
   if held(9) ='1' then m(26):='1'; end if; -- F
   if held(10)='1' then m(25):='1'; end if; -- G
   if held(11)='1' then m(24):='1'; end if; -- H
   if held(12)='1' then m(39):='1'; end if; -- I
   if held(13)='1' then m(23):='1'; end if; -- J
   if held(14)='1' then m(22):='1'; end if; -- K
   if held(15)='1' then m(21):='1'; end if; -- L
   if held(16)='1' then m(6) :='1'; end if; -- M
   if held(17)='1' then m(7) :='1'; end if; -- N
   if held(18)='1' then m(38):='1'; end if; -- O
   if held(19)='1' then m(37):='1'; end if; -- P
   if held(20)='1' then m(46):='1'; end if; -- Q
   if held(21)='1' then m(43):='1'; end if; -- R
   if held(22)='1' then m(28):='1'; end if; -- S
   if held(23)='1' then m(42):='1'; end if; -- T
   if held(24)='1' then m(40):='1'; end if; -- U
   if held(25)='1' then m(9) :='1'; end if; -- V
   if held(26)='1' then m(45):='1'; end if; -- W
   if held(27)='1' then m(11):='1'; end if; -- X
   if held(28)='1' then m(12):='1'; end if; -- German Z
   if held(29)='1' then m(41):='1'; end if; -- German Y

   ------------------------------------------------------------------------
   -- Editing / control keys.
   ------------------------------------------------------------------------
   if held(40)='1' then m(18):='1'; end if; -- Enter
   if held(41)='1' then m(65):='1'; end if; -- Escape
   if held(42)='1' then m(0) :='1'; end if; -- Backspace
   if held(43)='1' then m(66):='1'; end if; -- Tab
   if held(44)='1' then m(69):='1'; end if; -- Space

   if held(80)='1' then m(0) :='1'; end if; -- Left
   if held(79)='1' then m(66):='1'; end if; -- Right
   if held(81)='1' then m(67):='1'; end if; -- Down
   if held(82)='1' then m(16):='1'; end if; -- Up

   if held(76)='1' and not (
       (held(104)='1' or held(108)='1') and
       (held(106)='1' or held(110)='1')) then
    m(33):='1';
   end if;

   ------------------------------------------------------------------------
   -- Modifiers.
   ------------------------------------------------------------------------
   if held(105)='1' then m(2) :='1'; end if;
   if held(109)='1' then m(13):='1'; end if;

   if held(104)='1' or held(108)='1' then
    m(30):='1';
   end if;

   if caps_lock='1' then
    m(31):='1';
   end if;

   ------------------------------------------------------------------------
   -- German number row and punctuation.
   ------------------------------------------------------------------------
   if held(30)='1' then
    if altgr then null;
    elsif shift then symbol(64,true);
    else symbol(64,false); end if;
   end if;

   if held(31)='1' then
    if altgr then null;
    elsif shift then symbol(19,true);
    else symbol(63,false); end if;
   end if;

   if held(32)='1' then
    if altgr then null;
    elsif shift then null;
    else symbol(62,false); end if;
   end if;

   if held(33)='1' then
    if altgr then null;
    elsif shift then symbol(61,true);
    else symbol(61,false); end if;
   end if;

   if held(34)='1' then
    if altgr then null;
    elsif shift then symbol(60,true);
    else symbol(60,false); end if;
   end if;

   if held(35)='1' then
    if altgr then null;
    elsif shift then symbol(58,true);
    else symbol(59,false); end if;
   end if;

   if held(36)='1' then
    if altgr then symbol(36,true);
    elsif shift then symbol(3,false);
    else symbol(58,false); end if;
   end if;

   if held(37)='1' then
    if altgr then symbol(36,false);
    elsif shift then symbol(56,true);
    else symbol(57,false); end if;
   end if;

   if held(38)='1' then
    if altgr then symbol(35,false);
    elsif shift then symbol(55,true);
    else symbol(56,false); end if;
   end if;

   if held(39)='1' then
    if altgr then symbol(35,true);
    elsif shift then symbol(53,false);
    else symbol(55,false); end if;
   end if;

   if held(45)='1' then
    if altgr then symbol(51,false);
    elsif shift then symbol(3,true);
    else null; end if;
   end if;

   if held(46)='1' then
    if altgr then null;
    elsif shift then symbol(52,false);
    else null; end if;
   end if;

   if held(48)='1' then
    if altgr then symbol(52,true);
    elsif shift then symbol(57,true);
    else symbol(53,true); end if;
   end if;

   if held(49)='1' then
    if altgr then null;
    elsif shift then symbol(19,false);
    else symbol(62,true); end if;
   end if;

   if held(50)='1' then
    if altgr then null;
    elsif shift then symbol(19,false);
    else symbol(62,true); end if;
   end if;

   if held(53)='1' then
    if altgr then null;
    elsif shift then null;
    else symbol(59,true); end if;
   end if;

   if held(54)='1' then
    if altgr then null;
    elsif shift then symbol(20,false);
    else symbol(5,false); end if;
   end if;

   if held(55)='1' then
    if altgr then null;
    elsif shift then symbol(20,true);
    else symbol(4,false); end if;
   end if;

   if held(56)='1' then
    if altgr then null;
    elsif shift then symbol(54,true);
    else symbol(54,false); end if;
   end if;

   if held(100)='1' then
    if altgr then symbol(51,true);
    elsif shift then symbol(4,true);
    else symbol(5,true); end if;
   end if;

   -- AltGr+Q -> @
   if altgr and held(20)='1' then
    m(46):='0';
    symbol(63,true);
   end if;

   if symbol_active then
    m(2)  := '0';
    m(13) := '0';
    if symbol_shift then
     m(2) := '1';
    end if;
   end if;

  end if;

  O_matrix <= m;
 end process;

end architecture rtl;
#!/usr/bin/env python3
"""Run independent LCD boot, I2S framing and source consistency checks."""
from pathlib import Path
import hashlib, os, re, shutil, subprocess, xml.etree.ElementTree as ET
root=Path(__file__).resolve().parents[1]
build=root/'tests/build';build.mkdir(exist_ok=True)
ghdl=os.environ.get('GHDL') or shutil.which('ghdl')
iverilog=shutil.which('iverilog');vvp=shutil.which('vvp')
if not all([ghdl,iverilog,vvp]):raise SystemExit('GHDL, Icarus Verilog and vvp are required; GHDL may be set to an executable path.')
def run(args,cwd=build):subprocess.run([str(a) for a in args],cwd=cwd,check=True)
files=ET.parse(root/'z1013_display.gprj').findall('.//File')
for f in files:assert (root/f.get('path')).is_file(),f.get('path')
# Match hardware ROM contents against the simulation image.
p=root/'src/gowin_rom';s=(p/'gowin_z1013_rom.vhd').read_text();image=bytearray(8192)
for bank,body in re.findall(r'ROM_BANK_(\d+)\s*:\s*pROM(.*?)port map',s,re.S|re.I):
 for chunk,data in re.findall(r'INIT_RAM_([0-9A-F]{2})\s*=>\s*X"([0-9A-F]+)"',body):
  start=int(bank)*2048+int(chunk,16)*32
  image[start:start+32]=bytes.fromhex(data)[::-1]
assert bytes(image)==(p/'z1013_boot_rom.bin').read_bytes(),'ROM simulation image differs'
# Check there are no conflicting physical pin assignments.
cst=(root/'src/display.cst').read_text()
pins=re.findall(r'IO_LOC\s+"([^"]+)"\s+(\d+);',cst)
assert len({pin for _,pin in pins})==len(pins),'Conflicting FPGA pins'
# All retained CPU, ROM, keyboard and SD sources are byte-identical to baseline.
changed={'src/z1013_display_top.sv', 'src/display.sdc', 'src/sd_spi_block_reader.vhd', 'src/video_ram.vhd', 'src/usb_keyboard.vhd', 'src/hdmi_audio/ted_sound_core.sv', 'src/i2s_audio_tx.sv', 'src/ps2_keyboard.vhd', 'src/testpattern.vhd', 'src/color_ram.vhd', 'src/gowin_rpll/TMDS_rPLL.v'}
for line in (root/'docs/BASELINE_SHA256SUMS').read_text().splitlines():
 digest,name=line.split('  ',1);p=root/name
 if p.exists() and name not in changed:
  assert hashlib.sha256(p.read_bytes()).hexdigest()==digest,name+' differs from baseline'
print('PASS: ROM bytes, pin assignments, retained baseline sources',flush=True)
# Decode I2S as an external receiver would.
run([iverilog,'-g2012','-s','tb_i2s_audio_tx','-o',build/'i2s',root/'src/i2s_audio_tx.sv',root/'tests/tb_i2s_audio_tx.sv'])
run([vvp,build/'i2s'])
run([iverilog,'-g2012','-s','tb_master_volume','-o',build/'volume',root/'src/z1013_display_top.sv',root/'tests/tb_master_volume.sv'])
run([vvp,build/'volume'])
# Check top-level connections against declarations generated from the VHDL entity.
primitive_env=os.environ.get('GOWIN_PRIMITIVES')
primitive=Path(primitive_env) if primitive_env else None
if primitive and primitive.exists():
 entity=(root/'src/testpattern.vhd').read_text().split('entity testpattern is',1)[1].split('end entity',1)[0]
 ports=re.findall(r'(\w+)\s*:\s*(in|out)\s+std_logic(?:_vector\((\d+) downto (\d+)\))?',entity,re.I)
 stub='module testpattern('+','.join(x[0] for x in ports)+');\n'
 for name,direction,hi,lo in ports:
  stub+=('input' if direction.lower()=='in' else 'output')+' wire '+('['+hi+':'+lo+'] ' if hi else '')+name+';\n'
 stub+='endmodule\n'
 (build/'testpattern_interface.v').write_text(stub)
 verilog=[root/f.get('path') for f in files if f.get('type')=='file.verilog']
 run([iverilog,'-g2012','-I',root/'src','-s','z1013_display_top','-o',build/'top_check',build/'testpattern_interface.v',primitive]+verilog)
 print('PASS: SystemVerilog top-level elaboration with VHDL port declarations and Gowin primitive declarations',flush=True)
else: print('SKIP: top-level declaration check; set GOWIN_PRIMITIVES to prim_syn.v',flush=True)
# Also analyze production VHDL in the Gowin project's VHDL-1993 mode.
vhdl=[root/f.get('path') for f in files if f.get('type')=='file.vhdl']
v93=build/'vhdl93';v93.mkdir(exist_ok=True)
for f in vhdl:run([ghdl,'-a','--std=93','-C','-fsynopsys',f],v93)
# Run the complete T80/CPU/memory/renderer, with the actual 8-KiB ROM bytes.
sim=build/'vhdl';sim.mkdir(exist_ok=True)
shutil.copy2(root/'src/gowin_rom/z1013_boot_rom.bin',sim/'z1013_boot_rom.bin')
for f in [root/'tests/dpb_sim.vhd']+vhdl+[root/'tests/boot_rom_sim.vhd',root/'tests/tb_lcd_system.vhd']:
 run([ghdl,'-a','--std=08','-fsynopsys',f],sim)
run([ghdl,'-a','--std=08','-fsynopsys',root/'tests/tb_lcd_ram.vhd'],sim)
run([ghdl,'--elab-run','--std=08','-fsynopsys','tb_lcd_ram','--assert-level=error','--ieee-asserts=disable'],sim)
run([ghdl,'--elab-run','--std=08','-fsynopsys','tb_lcd_system','--assert-level=error','--ieee-asserts=disable'],sim)
print('PASS: independent checks complete. Gowin synthesis/place-and-route and hardware checks remain separate.')

# Prüffassung mit 33 MHz Systemtakt

Der vorherige 74,25-MHz-Aufbau hatte 8531 Setup-Verletzungen; ein CPU-Start war damit nicht zuverlässig zugesichert. Das zwischenzeitlich angezeigte READY und später weiße Z1013-Feld beweisen keine Beschädigung des BL616. Die genaue Ursache wird durch den SRAM-Vergleichstest eingegrenzt.

Die System-PLL erzeugt nun 165 MHz (27 MHz / 9 × 55) mit VCO 660 MHz; CLKDIV /5 liefert 33 MHz. Die separate 9-MHz-LCD-PLL bleibt unverändert. CPU-Phasenakkumulator: Schritte 4/8/16/33 modulo 132 liefern 1/2/4/8,25 MHz. Die physische FPGA-Logik erhält damit mehr Zeit pro Takt, ohne die gewählten Z80-Geschwindigkeiten zu senken.

Angepasst: 40-ms-Tastaturmakros, 100-ms-SD-Aktivitätsanzeige, 20-ms-Kassettennachlauf, 10-ms-SD-Anlaufpause sowie TED- und 48-kHz-I²S-Zeitbasis. Andere SD-Zeitlimits sind taktbasierte Obergrenzen und werden durch den kleineren Takt länger; die Grenzwerte werden dadurch nicht verkürzt.

Unabhängige Prüfungen bestanden: VHDL-1993, Verilog-Verbindungen, alle RAM-Adressen, I²S sowie vier LCD-Bilder mit realem T80/Boot-ROM und READY.

Gowin-GUI-Build vom 22.10.2026: 0 Setup-Verletzungen, 0 Hold-Verletzungen. sys_clk 33 MHz, erreichte Fmax 35,533 MHz; LCD 9 MHz, Fmax 46,012 MHz; USB-SPI 20 MHz, Fmax 34,548 MHz. Die bisherigen generischen Takt-Routingwarnungen ersetzen diese Timingprüfung nicht und bleiben als Hinweis bestehen.

Der Tang wurde als SIPEED USB Debugger und GW2A(R)-18(C) erkannt. Die neue Datei wurde mit openFPGALoader erfolgreich ausschließlich in SRAM geladen (ohne Flash-Schreiboption). FPGA-Konfigurationsflash und BL616 wurden dabei nicht geändert. Rückmeldung zum echten LCD steht aus.

Vorherige Quellen und Bitstream: `backups/before_33mhz_20261022_184625/`.

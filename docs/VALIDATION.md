# Prüfstand vom 22.10.2026

**Nachtrag vom 25.10.2026:** Der Z1013 startet inzwischen auf echter Hardware und zeigt das Monitorbild auf dem Sipeed-LCD. Foto und Video im Verzeichnis `stl/` dokumentieren den Aufbau. Die nachfolgende Liste „Noch offen“ beschreibt den früheren Stand vom 22.10.2026; spezielle Hörtests und die eindeutige Zuordnung der einzelnen Lautstärke-Bitstreams bleiben weiterhin separat zu prüfen.

## Bestanden

- Alle im Gowin-Projekt gelisteten Dateien sind vorhanden; keine mehrfach belegten FPGA-Pins.
- Retainierte CPU-, ROM-, Hauptspeicher-, SD-, Tastatur- und Soundquellen stimmen mit dem gewählten F3-Ausgangsstand überein. Renderer und Bild-/Farbspeicher sind gezielt für LCD geändert.
- Das Simulations-ROM stimmt byteweise mit allen vier pROM-Initialisierungen der Synthesequelle überein (8192 Byte).
- VHDL-Produktionsquellen mit GHDL 6.0.0 im VHDL-1993-Modus analysiert (UTF-8-Kommentare über `-C` zugelassen).
- SystemVerilog-Top inklusive USB-Module, PLL-Hüllen und Soundkern mit Icarus Verilog elaboriert. Die Schnittstelle zum VHDL-Renderer wurde aus dessen echter Entity erzeugt; für Gowin-Primitiven wurden Herstellerdeklarationen verwendet. Dies prüft die Verbindungen, ersetzt aber keine FPGA-Synthese.
- Vollständige T80-/Speicher-/ROM-/LCD-Simulation über vier LCD-Bilder mit unabhängigen 74,25-MHz- und 9-MHz-Takten. Die Schaltung startet das tatsächliche Boot-ROM, zeigt `READY` und den Monitorprompt. Die SD-Eingangsleitung ist dabei dauerhaft high; ein SD-Kartenmodell und USB-Host sind nicht enthalten.
- Je Bild 480 × 272 aktive Pixel, 520 × 300 Gesamtraster, HS/VS, zweistufige Bildpipeline und schwarze Ränder außerhalb des mittigen 256×256-Z1013-Felds geprüft. Im aufgenommenen vierten Bild keine unbekannten Pixel; 113 helle Pixel ergeben den Monitorstarttext. `lcd_boot_simulation.png` ist dieses Simulationsergebnis, kein Foto der Hardware.
- I²S als Empfänger dekodiert: 80 vollständige Frames, 48 kHz, 3,072-MHz-BCLK im Mittel, 32-Bit-Slots, I²S-Versatz um ein Bit, positive und negative 16-Bit-Werte, identische Kanäle, Nullauffüllung. Der BCLK wird aus 74,25 MHz mit einem Phasenakkumulator erzeugt und hat entsprechend geringe Periodenschwankungen.

## Noch offen

- Gowin-Synthese, Place & Route, Ressourcenverbrauch, Timingabschluss und Bitstream-Erzeugung: Lizenzprüfung blockiert vor Synthesestart. Die installierte Serverlizenz antwortet nicht, die gefundene lokale Lizenz passt laut Gowin nicht zur Hostkennung. Die installierte Konfiguration wurde nicht verändert.
- Die SDC-Ausgangsverzögerungen von 10 ns Setup/5 ns Hold sind konservative Arbeitswerte und noch gegen das genaue Paneldatenblatt und den Gowin-Timingbericht zu prüfen.
- LCD-Panelrevision, Orientierung/Kontaktseite des Flachbandkabels, Beleuchtung, Farbreihenfolge und Bildstabilität am Gerät.
- Boardrevision und dazu passende BL616-Firmware des neuen Tang; aktuelles FPGA-Interface ist der bisherige v3923-Stand.
- Echte USB-Tastatur, F3/DOS, SD-Lesen/-Schreiben und Lautsprecherausgabe auf dem neuen Aufbau. Vorhandene Funktionalität wurde übernommen, in dieser neuen Hardwarekombination aber noch nicht bestätigt.

Für den Ersttest zunächst SRAM statt Flash verwenden. Keine FPGA- oder Companion-Firmware wurde während der Vorbereitung auf ein Gerät geschrieben.

## Nachtrag: Dual-Port-RAM-Korrektur

Der vom Nutzer ausgeführte Gowin-Lauf analysiert die Quellen, scheitert aber mit IF0008 bei der Umsetzung eines 8-KiB-Speichers in 65.536 Flipflops. Bild- und Farbspeicher verwenden jetzt jeweils vier explizite DPB-Blöcke mit 2048×8 Bit statt automatischer Multi-Clock-Inferenz.

Erneut bestanden: VHDL-1993-Analyse, vollständiger Z1013-Start mit vier LCD-Bildern und unverändertem Monitorstarttext sowie I²S-Test. Zusätzlich wurde jeder der 8192 RAM-Adressen über CPU- und LCD-Port geprüft, einschließlich Bankwechseln, CPU-Write-through und 0Fh-Farbinitialisierung. Hierfür wird ausschließlich in der Simulation ein DPB-Modell verwendet, das die tatsächlich benutzten Primitiveinstellungen abbildet.

Die erneute Gowin-Prüfung dieser Korrektur blieb vor Synthesestart an der nicht antwortenden Lizenzprüfung hängen. Die Korrektur muss daher noch in der nutzbaren Gowin-Instanz des Nutzers synthetisiert und platziert werden.

### RAM-Dateieinbindung vereinfacht

Die DPB-Instanzen sind jetzt direkt in den bereits von Gowin geladenen Dateien `video_ram.vhd` und `color_ram.vhd` enthalten. Die zusätzliche Quelldatei wird nicht mehr benötigt oder in der Projektdateiliste aufgeführt. Diese Fassung wird erneut mit VHDL-1993-Analyse, RAM-Adressprüfung und vollständigem CPU-/LCD-Start geprüft. Die Gowin-Bestätigung bleibt separat erforderlich.

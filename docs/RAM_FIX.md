# Korrektur für Gowin IF0008

Der gemeldete Fehler `65536 DFF ... exceeds ... 15750` entsteht bei der automatischen Umsetzung des 8-KiB-Dual-Port-Speichers mit verschiedenen Porttakten. Die erste LCD-Fassung vertraute hier auf Gowins RAM-Inferenz; die unabhängige Simulation konnte diese Hardwarezuordnung nicht prüfen.

`src/lcd_dual_port_ram.vhd` instanziert jetzt vier physische Gowin-DPB-Blöcke zu je 2048×8 Bit. `video_ram.vhd` und `color_ram.vhd` verwenden diesen Baustein mit Anfangswert 00h beziehungsweise 0Fh. Es gibt weiterhin je einen CPU- und LCD-Port mit getrennten Takten und einem Takt Leseverzögerung. Die oberen beiden Adressbits wählen einen der vier Blöcke; die Auswahl wird zusammen mit dem synchronen Leseergebnis registriert. CPU-Schreiben verwendet Write-through.

Das Projekt bindet den gemeinsamen RAM-Baustein vor den beiden RAM-Hüllen ein. Die Simulation verwendet `tests/dpb_sim.vhd`; diese Datei ist ausdrücklich nicht Bestandteil des Gowin-Projekts. `tests/tb_lcd_ram.vhd` prüft alle Adressen, Bankwechsel und Initialwerte. Die vollständige CPU-/LCD-Simulation zeigt weiterhin READY und den Monitorprompt.

Bitte `z1013_display.gprj` gegebenenfalls neu laden und Synthesize sowie Place & Route erneut starten. Die USB-Initialisierungs-, Audio-Breiten- und unbenutzten-Tastenmeldungen des übermittelten Logs sind Warnungen und nicht der gemeldete Abbruchgrund.

Die lokale Kommandozeilenprüfung blieb an der nicht antwortenden Gowin-Lizenzprüfung hängen. Ressourcen- und Timingberichte der korrigierten Fassung sind daher noch offen.

## Korrektur der Dateieinbindung

Da die geöffnete Gowin-Instanz die zusätzliche Datei weiterhin nicht analysierte, sind die DPB-Instanzen jetzt direkt in `video_ram.vhd` und `color_ram.vhd` enthalten. Diese beiden Dateien wurden laut Log bereits geladen. Der gemeinsame Baustein ist nicht mehr Bestandteil der Projektdateiliste. Die Hardwarefunktion bleibt gleich.

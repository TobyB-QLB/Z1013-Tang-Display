# LCD-Prüffassung

Foto und Video unter `../stl/` bestätigen inzwischen den Z1013-Start und die LCD-Ausgabe auf dem aufgebauten Gerät. Da die Medien den verwendeten Bitstream nicht eindeutig einer der drei Dateien zuordnen, bleiben die folgenden Statusangaben pro Datei bewusst erhalten.

`z1013_display_33mhz_sramtest.fs` ist die in Gowin gebaute 33-MHz-Prüffassung ohne gemeldete Setup-/Hold-Verletzungen. Erfolgreich ins SRAM übertragen; LCD-Rückmeldung steht aus. Noch keine neue dauerhafte Flash-Programmierung durchgeführt. Siehe `../docs/CLOCK_33MHZ.md`.

## Lautstärkefassung

`z1013_display_33mhz_volume_f4_f5.fs`: neue F4/F5-Masterlautstärke, geprüft mit Simulation und Gowin-Timing (0 Setup/Hold-Verletzungen). Noch nicht auf Hardware übertragen. `z1013_display_33mhz_sramtest.fs` bleibt der zuvor am Gerät bestätigte Stand ohne F4/F5.

`z1013_display_33mhz_volume_plus10.fs`: weitere F5-Stufe mit +10,16 Prozent Signalamplitude und Sättigung statt Zahlenüberlauf. Gebaut, Simulation und Timing bestanden; noch nicht übertragen.

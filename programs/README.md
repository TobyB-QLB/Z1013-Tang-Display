# Programme für den Z1013

Zusätzlich zu den drei unten beschriebenen Spielen gibt es [DEMO.COM](DEMO/README.md), das Concept-Demo mit bereits enthaltenem 9-Byte-Dateikopf. Seine Musikherkunft und sein Prüfstand sind separat dokumentiert.

[TBDOS](TBDOS/README.md) ist meine weiterentwickelte Z1013-Dateiverwaltung mit klassischer Zwei-Fenster-Bedienung. Das Projekt geht auf meine erste Z80-Fassung von vor etwa 26 Jahren zurück. Für die Installation kommt `DOS.COM` in das Wurzelverzeichnis der SD-Karte; die Dateien `.BIN` und `.OVL` gehören in das Verzeichnis `/DOS/`.

[TERTRIS.COM](TERTRIS/README.md) ist die veröffentlichte Version 2 eines Fallsteinspiels für den Z1013. Die Datei hieß in meiner SD-Karten-Sammlung ursprünglich `TETRISV2.COM` und wird hier unter dem Namen `TERTRIS.COM` bereitgestellt.

Copyright © Tobias Bremer.

Ich habe die Programme PACMAN, KIKSTART und PUNIVERS vollständig für den Z1013 entwickelt und neu umgesetzt. Dies gilt für sämtliche enthaltenen Bestandteile:

- Programmcode und Programmlogik
- Darstellung und Grafik
- Sound und Musikdaten
- Level- und Spieldaten
- technische Ausführung auf dem Z1013

Die Programme sind in ihrer Spielidee und teilweise in ihrer Bezeichnung lediglich an historische Programme angelehnt. Programmcode, Grafiken, Sounddaten und andere Dateien der historischen Vorbilder wurden nicht übernommen. Dieses Projekt ist nicht mit deren ursprünglichen Rechteinhabern verbunden und wird von ihnen nicht unterstützt.

Der Lizenzstatus dieser Programme richtet sich nach der Datei `../LICENSE.md`. Derzeit wird keine pauschale Lizenz zur Veränderung oder Weiterverbreitung eingeräumt.

## Verwendung auf der FAT32-Karte

Die mitgelieferten Dateien `PACMAN.COM`, `KIKSTART.COM`, `PUNIVERS.COM` und `TERTRIS.COM` besitzen bereits den benötigten 9-Byte-Z1013-Kopf. Sie können unverändert in das Wurzelverzeichnis der FAT32-Karte kopiert werden. Das Werkzeug `@DS` ist nur für rohe Programmdateien ohne Kopf vorgesehen.

---

# Programs for the Z1013

In addition to the three games described below, [DEMO.COM](DEMO/README.md) provides the Concept demo with its 9-byte header already included. Music credits and verification status are documented separately.

[TBDOS](TBDOS/README.md) is my continued Z1013 file-manager project with a classic dual-panel interface. It goes back to my first Z80 version written about 26 years ago. To install it, place `DOS.COM` in the SD-card root and the `.BIN` and `.OVL` files in `/DOS/`.

[TERTRIS.COM](TERTRIS/README.md) is the published version 2 of a falling-block game for the Z1013. The file was originally named `TETRISV2.COM` in my SD-card collection and is provided here as `TERTRIS.COM`.

Copyright © Tobias Bremer.

I developed and newly implemented PACMAN, KIKSTART, and PUNIVERS entirely for the Z1013. This includes all supplied components:

- program code and logic
- presentation and graphics
- sound and music data
- level and game data
- technical implementation on the Z1013

The games are inspired by historical game ideas and, in some cases, their names. No program code, graphics, sound data, or other files from the historical originals were used. This project is neither affiliated with nor endorsed by their original rights holders.

The license status of these programs is defined in `../LICENSE.md`. No general permission to modify or redistribute them is currently granted.

## Using the FAT32 card

The supplied `PACMAN.COM`, `KIKSTART.COM`, `PUNIVERS.COM`, and `TERTRIS.COM` files already contain the required 9-byte Z1013 header. Copy them unchanged to the root directory of the FAT32 card. The `@DS` tool is intended only for raw program files that do not yet have a header.

# TBDOS für den Z1013 / TBDOS for the Z1013

[Deutsch](#deutsch) · [English](#english)

## Deutsch

TBDOS ist eine Dateiverwaltung für den Z1013 mit einer an klassische Zwei-Fenster-Dateimanager wie den Norton Commander angelehnten Bedienung. Das Programm zeigt zwei Verzeichnispanele und bietet Funktionen zum Anzeigen und Starten von Dateien sowie weitere Werkzeuge über Menüs und Erweiterungsmodule.

Die Geschichte von TBDOS begann für mich vor etwa 26 Jahren. Damals entwickelte ich eine erste Fassung für den Z80. Für dieses FPGA-Z1013-Projekt habe ich die frühere Idee wieder aufgenommen, technisch weitergeführt und an die heutige FAT32-Umgebung des Z1013 angepasst. Die hier veröffentlichte Fassung ist damit die Fortsetzung meines langjährigen Z80-Projekts.

TBDOS ist mein eigenständiger Nachbau. Bei der Bedienidee habe ich mich von historischen Zwei-Fenster-Dateimanagern inspirieren lassen. Der enthaltene Programmcode und die konkrete Umsetzung stammen von mir.

## Installation auf der SD-Karte

Die Verzeichnisstruktur muss genau so angelegt werden:

```text
SD-Karte/
├── DOS.COM
└── DOS/
    ├── DOSKRNL.BIN
    ├── HEX.OVL
    ├── RST20.BIN
    └── VIEW.OVL
```

1. `DOS.COM` aus diesem Verzeichnis in das Wurzelverzeichnis der FAT32-SD-Karte kopieren.
2. Auf der SD-Karte das Verzeichnis `/DOS/` anlegen.
3. `DOSKRNL.BIN`, `HEX.OVL`, `RST20.BIN` und `VIEW.OVL` in `/DOS/` kopieren.

`DOS.COM` enthält bereits den erforderlichen 9-Byte-Z1013-Kopf `@DD` und darf nicht nochmals mit `@DS` bearbeitet werden. Die Dateien im Verzeichnis `/DOS/` sind Laufzeitbestandteile und müssen unverändert dort liegen.

## Start

Am Z1013 `@DL` eingeben, Enter drücken, anschließend `DOS.COM` eingeben und erneut Enter drücken. Bei der aktuellen Tastaturbelegung kann F3 diese Eingabefolge vorbereiten. TBDOS lädt danach seinen Kern und die Erweiterungsmodule aus `/DOS/`.

Copyright © 2026 Tobias Bremer. Der Lizenzstatus richtet sich nach [`../../LICENSE.md`](../../LICENSE.md).

---

## English

TBDOS is a file manager for the Z1013 with an interface inspired by classic dual-panel file managers such as Norton Commander. It displays two directory panels and provides functions for viewing and starting files, together with additional menu tools and extension modules.

The history of TBDOS began for me about 26 years ago, when I developed its first version for the Z80. For this FPGA Z1013 project, I returned to that earlier idea, continued its development, and adapted it to the Z1013 FAT32 environment used today. This release therefore continues my long-running Z80 project.

TBDOS is my independent reimplementation. Its operating concept is inspired by historical dual-panel file managers. I created the included program code and its concrete implementation.

## Installing it on the SD card

Use exactly this directory structure:

```text
SD card/
├── DOS.COM
└── DOS/
    ├── DOSKRNL.BIN
    ├── HEX.OVL
    ├── RST20.BIN
    └── VIEW.OVL
```

1. Copy `DOS.COM` from this directory to the root of the FAT32 SD card.
2. Create a `/DOS/` directory on the SD card.
3. Copy `DOSKRNL.BIN`, `HEX.OVL`, `RST20.BIN`, and `VIEW.OVL` into `/DOS/`.

`DOS.COM` already contains the required 9-byte Z1013 `@DD` header and must not be processed with `@DS` again. The files in `/DOS/` are runtime components and must remain there unchanged.

## Starting TBDOS

On the Z1013, enter `@DL`, press Enter, then enter `DOS.COM` and press Enter again. With the current keyboard mapping, F3 can prepare this input sequence. TBDOS then loads its kernel and extension modules from `/DOS/`.

Copyright © 2026 Tobias Bremer. See [`../../LICENSE.md`](../../LICENSE.md) for the license status.

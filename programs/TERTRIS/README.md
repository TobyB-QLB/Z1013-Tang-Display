# TERTRIS für den Z1013 / TERTRIS for the Z1013

[Deutsch](#deutsch) · [English](#english)

## Deutsch

TERTRIS ist ein Fallsteinspiel für den Z1013. Ich veröffentliche hier die Version 2 aus meiner SD-Karten-Sammlung. Die ursprüngliche Datei `TETRISV2.COM` trägt im Repository und auf der SD-Karte den Namen `TERTRIS.COM`.

Die Datei besitzt bereits den erforderlichen 9-Byte-Z1013-Kopf `@DD`:

- Ladeadresse: `0100h`
- Endadresse: `43CEh`
- Startadresse: `0100h`

## Installation und Start

1. [`TERTRIS.COM`](TERTRIS.COM) unverändert in das Wurzelverzeichnis der FAT32-SD-Karte kopieren.
2. Am Z1013 `@DL` eingeben und Enter drücken.
3. `TERTRIS.COM` eingeben und erneut Enter drücken.

Da die Datei bereits einen gültigen Kopf besitzt, darf sie nicht nochmals mit `@DS` bearbeitet werden.

Repository-Integration und Dokumentation © 2026 Tobias Bremer. Der Lizenzstatus des Gesamtprojekts richtet sich nach [`../../LICENSE.md`](../../LICENSE.md).

---

## English

TERTRIS is a falling-block game for the Z1013. I am publishing version 2 from my SD-card collection. The original file named `TETRISV2.COM` is provided as `TERTRIS.COM` in this repository and on the SD card.

The file already contains the required 9-byte Z1013 `@DD` header:

- load address: `0100h`
- end address: `43CEh`
- start address: `0100h`

## Installation and startup

1. Copy [`TERTRIS.COM`](TERTRIS.COM) unchanged to the root of the FAT32 SD card.
2. On the Z1013, enter `@DL` and press Enter.
3. Enter `TERTRIS.COM` and press Enter again.

The file already has a valid header and must not be processed with `@DS` again.

Repository integration and documentation © 2026 Tobias Bremer. See [`../../LICENSE.md`](../../LICENSE.md) for the overall project license status.

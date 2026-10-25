# Lautstärkeregelung über F4/F5

F4 senkt, F5 erhöht die gemeinsame Lautstärke des Onboard-Lautsprecherausgangs. Die USB-HID-Codes 61 und 62 werden direkt aus dem bereits synchronisierten Ereignisstrom gelesen. Die bestehende Tastaturmatrix, F1/F2/F3 und F9–F12 bleiben unberührt.

Es gibt neun Stufen: 0 = stumm, 1 bis 8 = 1/8 bis 8/8 der ursprünglichen Signalamplitude. Einschalten oder FPGA-Reset startet mit Stufe 2 (25 Prozent Amplitude, keine Angabe zur empfundenen Lautstärke). Stufe 8 entspricht dem bisherigen ungedämpften Signal. Die Stufe wird nicht dauerhaft gespeichert.

Pro Tastendruck wird eine Stufe geschaltet. Wiederholte Make-Ereignisse einer gehaltenen Taste werden ignoriert; Loslassen gibt den nächsten Schritt frei. Eine Tastatur-Abmeldung löst die gehaltenen F4/F5-Zustände, behält aber die eingestellte Lautstärke bei.

Die Skalierung sitzt hinter dem TED-/PCM-/Kassettenmischer und vor dem I²S-Sender. Alle Soundquellen werden gemeinsam gedämpft; die Soundregister des Z80 und die Stimmenbalance der Programme werden nicht verändert. Der Ausgang ist registriert; es entsteht ein Systemtakt zusätzliche Audiolatenz. Maximalverstärkung ist 1, daher wird die ursprüngliche Signalhöhe nicht überschritten.

Prüfung mit Icarus: positive/negative Samples, Stumm-/Maximalgrenze, Tastendruck/Loslassen, Wiederholungen, Disconnect, Reset und unabhängige Funktionstasten. I²S-Framing und Top-Level-Verbindungen ebenfalls erneut geprüft. Hörtest steht aus.

Lautsprecher bei stromlosem Board an die zwei Kontakte von J4 anschließen. OUTP und OUTN bilden den Lautsprecherausgang; keiner der Kontakte wird mit Masse verbunden.

Gowin-Build 22.10.2026 19:42:03: 0 Setup-/0 Hold-Verletzungen, System-Fmax 38,768 MHz bei geforderten 33 MHz. Der Bitstream wurde noch nicht auf das Board übertragen. Die Breitenwarnung am Gain-Ausgang betrifft das Abschneiden redundanter Vorzeichenbits nach der Division; die überprüfte Stufengrenze 8 verhindert eine Verstärkung über 1.

## Zusätzliche Maximalstufe (+10 Prozent)

Aktuelle Quelldateien bieten zehn Stufen 0..9. Die bisherigen Stufen 0..8 bleiben unverändert, Stufe 9 liefert 141/128 = 1,1015625, also etwa 10,16 Prozent mehr Signalamplitude als der bisherige Maximalwert. Der Start bleibt Stufe 2 (25 Prozent). F4 reduziert von Stufe 9 zunächst auf den bisherigen Maximalwert. Positive und negative Übersteuerung wird auf den 16-Bit-Wertebereich begrenzt; diese Begrenzung verhindert Zahlenüberlauf, kann bei zu hohen Eingangssignalen aber hörbares Clipping erzeugen.

Simulation einschließlich Clippingprüfung bestanden. Gowin-Build 22.10.2026 20:39:29: 0 Setup-/0 Hold-Verletzungen, System-Fmax 35,977 MHz bei geforderten 33 MHz. Datei: `../release/z1013_display_33mhz_volume_plus10.fs`. Noch nicht auf Hardware übertragen. Die vorherige F4/F5-Version bleibt separat erhalten.

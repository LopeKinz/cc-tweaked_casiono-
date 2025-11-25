# Datei-Übersicht

## 📁 Hauptverzeichnis

### `casino.lua` (Hauptprogramm)
- **Zweck:** Hauptprogramm, das alles zusammenführt
- **Funktionen:**
  - Peripherie-Erkennung (Monitor, Player Detector, RS Bridge)
  - Modul-Loading
  - Player Detection und Auswahl
  - Hauptmenü
  - Spiel-Koordination
  - Error Handling
- **Startet:** Alle Spiele und koordiniert den Ablauf

### `ui.lua` (UI-Bibliothek)
- **Zweck:** Zentrale UI-Funktionen für alle Spiele
- **Funktionen:**
  - Touch-Steuerung
  - Button-Rendering
  - Text-Anzeige (zentriert, farbig)
  - Menüs und Listen
  - Fortschrittsbalken
  - Animationen (Gewinn/Verlust)
  - Auswahl-Dialoge
  - Farb-Management
- **Verwendet von:** Alle Spiele und das Hauptprogramm

### `inventory.lua` (Inventar-Management)
- **Zweck:** Verwaltung der Diamanten über RS Bridge
- **Funktionen:**
  - RS Bridge Integration
  - Diamanten zählen
  - Einsätze verarbeiten
  - Gewinne auszahlen
  - Verluste verbuchen
  - Simple Mode (Fallback ohne RS Bridge)
- **Verwendet von:** Alle Spiele

### `startup.lua` (Auto-Start)
- **Zweck:** Startet Casino automatisch beim Booten
- **Funktionen:**
  - Prüft ob casino.lua existiert
  - Startet Casino-Programm
- **Optional:** Kann gelöscht werden für manuellen Start

## 📁 games/ Verzeichnis

### `games/slots.lua` (Slot Machine)
- **Spiel:** Klassischer Spielautomat
- **Features:**
  - 6 verschiedene Symbole ($, 7, *, @, #, &)
  - 3 Walzen mit Animation
  - Verschiedene Gewinn-Kombinationen (3x gleich, 2x gleich)
  - Auszahlungen: 2x bis 100x
  - Animierte Walzen-Drehung
  - Gewinn-Highlight
- **Einsatz:** 1-10 Diamanten

### `games/roulette.lua` (Roulette)
- **Spiel:** Europäisches Roulette
- **Features:**
  - Zahlen 0-36 mit Rot/Schwarz/Grün
  - Wettoptionen:
    - Farbe (Rot/Schwarz) - 2x
    - Gerade/Ungerade - 2x
    - Niedrig (1-18) / Hoch (19-36) - 2x
    - Spezifische Zahl - 36x
  - Animierte Rad-Drehung
  - Touch-Auswahl für alle Zahlen
- **Einsatz:** 1-10 Diamanten

### `games/blackjack.lua` (Blackjack)
- **Spiel:** Klassisches Blackjack (21)
- **Features:**
  - Komplettes 52-Karten-Deck
  - Hit, Stand, Double Down
  - Dealer-KI (muss unter 17 ziehen)
  - Ass-Wert automatisch angepasst (11 oder 1)
  - Karten-Visualisierung mit Farben
  - Blackjack-Bonus (2.5x)
  - Unentschieden (Push)
- **Einsatz:** 1-10 Diamanten

### `games/coinflip.lua` (Coin Flip)
- **Spiel:** Münzwurf - Kopf oder Zahl
- **Features:**
  - Einfaches 50/50 Spiel
  - Flip-Animation
  - Visueller Münz-Effekt
  - Schnelles Spiel
- **Einsatz:** 1-10 Diamanten
- **Auszahlung:** 2x bei Gewinn

### `games/dice.lua` (Würfel)
- **Spiel:** Würfel-Spiel mit 2 Würfeln
- **Features:**
  - 2 Würfel mit Punkt-Visualisierung
  - Wettoptionen:
    - Summe 7 oder 11 - 3x
    - Gerade/Ungerade - 2x
    - Hoch (>7) / Niedrig (<7) - 2x
    - Pasch (beide gleich) - 5x
  - Würfel-Animation
  - Realistische Würfel-Grafik
- **Einsatz:** 1-10 Diamanten

## 📄 Dokumentation

### `README.md`
- Haupt-Dokumentation
- Feature-Übersicht
- Hardware-Setup
- Schnell-Anleitung
- Dateistruktur

### `INSTALLATION.md`
- Detaillierte Schritt-für-Schritt-Anleitung
- Hardware-Aufbau mit Diagrammen
- Software-Installation (3 Methoden)
- Fehlerbehebung
- Test-Anleitung
- Checkliste

### `DATEIEN.md` (diese Datei)
- Übersicht aller Dateien
- Zweck und Funktionen
- Abhängigkeiten

### `.gitignore`
- Git-Konfiguration
- Ignoriert Backup- und System-Dateien

## 📊 Abhängigkeiten

```
casino.lua
├── ui.lua
├── inventory.lua
└── games/
    ├── slots.lua (benötigt ui.lua, inventory.lua)
    ├── roulette.lua (benötigt ui.lua, inventory.lua)
    ├── blackjack.lua (benötigt ui.lua, inventory.lua)
    ├── coinflip.lua (benötigt ui.lua, inventory.lua)
    └── dice.lua (benötigt ui.lua, inventory.lua)

startup.lua → casino.lua
```

## 📝 Gesamt-Dateiliste

### Erforderliche Dateien (9):
1. `casino.lua` - Hauptprogramm
2. `ui.lua` - UI-Bibliothek
3. `inventory.lua` - Inventar-Verwaltung
4. `games/slots.lua` - Slot Machine
5. `games/roulette.lua` - Roulette
6. `games/blackjack.lua` - Blackjack
7. `games/coinflip.lua` - Coin Flip
8. `games/dice.lua` - Würfel
9. `startup.lua` - Auto-Start (optional)

### Dokumentation (4):
10. `README.md` - Haupt-Dokumentation
11. `INSTALLATION.md` - Installations-Anleitung
12. `DATEIEN.md` - Diese Datei
13. `.gitignore` - Git-Konfiguration

**Gesamt: 13 Dateien**

## 🎯 Datei-Größen (ungefähr)

- `casino.lua`: ~5 KB
- `ui.lua`: ~8 KB
- `inventory.lua`: ~4 KB
- `games/slots.lua`: ~5 KB
- `games/roulette.lua`: ~7 KB
- `games/blackjack.lua`: ~8 KB
- `games/coinflip.lua`: ~4 KB
- `games/dice.lua`: ~6 KB
- `startup.lua`: ~0.5 KB

**Gesamt Code: ~47.5 KB**

## 💾 ComputerCraft Limits

ComputerCraft: Tweaked hat großzügige Limits:
- **Festplattenspeicher:** 1 MB (1024 KB) pro Computer
- **RAM:** Unbegrenzt (Lua-VM)
- **Unser Casino:** ~47.5 KB (weniger als 5% des Speichers)

✅ **Kein Problem für ComputerCraft!**

## 🔄 Update-Reihenfolge

Wenn du Dateien aktualisierst:
1. **ui.lua** zuerst (alle hängen davon ab)
2. **inventory.lua** als zweites
3. **Spiele** (games/*.lua) danach
4. **casino.lua** zuletzt

## 🎮 Spiel-Komplexität

Von einfach zu komplex:
1. **Coin Flip** ⭐ (am einfachsten)
2. **Dice** ⭐⭐
3. **Slot Machine** ⭐⭐⭐
4. **Roulette** ⭐⭐⭐⭐
5. **Blackjack** ⭐⭐⭐⭐⭐ (am komplexesten)

---
**Alle Dateien sind kompatibel mit ComputerCraft: Tweaked für Minecraft 1.21.1**

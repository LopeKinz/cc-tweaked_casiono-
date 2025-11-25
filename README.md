# Minecraft Casino - ComputerCraft: Tweaked

Ein vollständiges Casino-System für Minecraft 1.21.1 mit dem Modpack "All the Mods 10" (Version 5.0).

## 🎰 Features

- **5 verschiedene Casino-Spiele:**
  - 🎰 Slot Machine
  - 🎡 Roulette
  - 🃏 Blackjack
  - 🪙 Coin Flip
  - 🎲 Würfel (Dice)

- **Automatisches Inventar-Management** mit RS Bridge
- **Vollständige Touch-Steuerung** (keine Slider!)
- **Player Detection** mit Namensauswahl
- **Diamant-Einsätze**

## 🏗️ Hardware-Setup

### Komponenten:
- **1x Advanced Computer**
- **20x Advanced Monitor** (4x5 Anordnung) - **rechts vom Computer**
- **1x RS Bridge** - **unter dem Computer**
- **1x Player Detector** - **auf dem Computer**
- **1x Double Chest** - **vor dem Computer**

### Aufbau:
```
             [Monitor Monitor Monitor Monitor]
             [Monitor Monitor Monitor Monitor]
[Detector]   [Monitor Monitor Monitor Monitor]
[Computer]   [Monitor Monitor Monitor Monitor]
[RS Bridge]  [Monitor Monitor Monitor Monitor]
  [Chest]
```

## 📥 Installation

1. Alle Dateien in einen Advanced Computer kopieren
2. Hauptprogramm starten: `casino`

```bash
# Auf dem Computer:
cd /
edit startup.lua
# Füge ein: shell.run("casino")
reboot
```

## 🎮 Bedienung

1. System erkennt automatisch Spieler in 15 Blöcken Reichweite
2. Spieler wählt seinen Namen aus der Liste
3. Diamanten in die Truhe legen
4. Spiel auswählen und spielen!

## 📁 Dateistruktur

```
/
├── casino.lua          # Hauptprogramm
├── ui.lua              # UI-Bibliothek für Touch-Steuerung
├── inventory.lua       # Inventar-Management (RS Bridge)
└── games/
    ├── slots.lua       # Slot Machine
    ├── roulette.lua    # Roulette
    ├── blackjack.lua   # Blackjack
    ├── coinflip.lua    # Coin Flip
    └── dice.lua        # Würfel
```

## 🔧 Konfiguration

Die Peripheriegeräte werden automatisch erkannt:
- RS Bridge: `bottom` (unter dem Computer)
- Player Detector: `top` (auf dem Computer)
- Monitor: `right` (rechts vom Computer)
- Chest: wird über RS Bridge gesteuert

## 💎 Diamanten-System

- Diamanten werden automatisch aus der Truhe gezählt
- Einsätze werden bei Verlust eingezogen
- Gewinne werden automatisch ausgezahlt

## 🎲 Spiel-Details

### Slot Machine
- Einsatz: 1-10 Diamanten
- 3 Walzen mit Symbolen
- Verschiedene Gewinnkombinationen

### Roulette
- Einsatz: 1-10 Diamanten
- Setze auf Rot/Schwarz, Gerade/Ungerade, oder spezifische Zahlen
- Auszahlungsquoten: 2x, 2x, 36x

### Blackjack
- Einsatz: 1-10 Diamanten
- Klassisches Blackjack gegen den Dealer
- Hit, Stand, Double Down

### Coin Flip
- Einsatz: 1-10 Diamanten
- Kopf oder Zahl
- 2x Auszahlung bei Gewinn

### Würfel
- Einsatz: 1-10 Diamanten
- 2 Würfel werfen
- Verschiedene Wettoptionen

## 📝 Entwickelt mit

- ComputerCraft: Tweaked
- Advanced Peripherals

---
**Viel Glück beim Spielen! 🍀**

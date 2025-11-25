# Minecraft Casino - ComputerCraft: Tweaked

Ein vollständiges Casino-System für Minecraft 1.21.1 mit dem Modpack "All the Mods 10" (Version 5.0).

## 🎰 Features

### **16 verschiedene Casino-Spiele!**

#### 🎰 Klassische Casino-Spiele:
- **Slot Machine** - 3 Walzen, 6 Symbole, bis zu 100x Gewinn
- **Roulette** - Europäisches Roulette mit allen Wettoptionen
- **Blackjack** - Hit, Stand, Double Down gegen den Dealer
- **Baccarat** - Player, Banker oder Tie

#### 🎲 Würfel & Münzen:
- **Coin Flip** - Kopf oder Zahl, einfach und schnell
- **Dice** - 2 Würfel mit 6 verschiedenen Wettoptionen

#### 🃏 Kartenspiele:
- **High/Low** - Rate höher oder niedriger, baue Streak auf
- **War** - Klassischer Kartenkrieg

#### 🚀 Moderne Casino-Spiele:
- **Crash** - Multiplier steigt, cashout bevor es crasht!
- **Mines** - Finde sichere Felder, vermeide Minen
- **Tower** - Klettere den Turm hoch, wähle den richtigen Weg

#### 🎪 Spezial-Spiele:
- **Plinko** - Ball fällt durch Pins, Multiplikatoren bis 100x
- **Wheel of Fortune** - Drehe das Glücksrad
- **Keno** - Zahlen-Lotterie, wähle 3-10 Zahlen
- **Scratch Cards** - Rubbellose, finde 3 gleiche Symbole
- **Horse Racing** - Wette auf Pferde im Rennen

### 🌟 System-Features:
- **Automatisches Inventar-Management** mit RS Bridge
- **Vollständige Touch-Steuerung** (keine Slider!)
- **Player Detection** mit Namensauswahl (15 Blöcke Reichweite)
- **💎 Unbegrenzte Einsätze** - Setze so viele Diamanten ein wie du hast!
  - Schnellwahl: 1, 5, 10, 25, 50, 100, 500
  - +/- Buttons für präzise Anpassung
  - "ALLES" Button für All-In
- **Animationen** in allen Spielen
- **⚡ Ein-Klick-Installation** mit automatischem Installer
- **Auto-Start** beim Booten

### 🏆 Progression & Belohnungen:
- **📊 Leaderboard** - Top 10 Spieler in 4 Kategorien (Siege, Level, Größter Gewinn, Total Gewonnen)
- **🎖️ Achievements** - 10 freischaltbare Erfolge mit Benachrichtigungen
- **💰 Daily Bonus** - Tägliche Diamanten (5 + Streak-Bonus, max 15)
- **📈 Level-System** - XP sammeln (1 XP pro Diamant Einsatz), Level aufsteigen
- **🎰 Jackpot** - Progressiver Jackpot mit 0.1% Gewinnchance pro Spiel
- **📝 Tägliche Quests** - 3 Quests pro Tag mit Diamanten-Belohnungen
- **📊 Detaillierte Statistiken** - Tracking aller Spiele, Gewinnraten, Profit
- **📜 Spiel-Verlauf** - Letzte 20 Spiele anzeigen
- **🏅 Spieler-Ränge** - Globale Rangliste mit Position
- **💾 Persistente Daten** - Alle Daten werden gespeichert

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

### ⚡ Automatische Installation (Empfohlen):

```bash
# Auf dem Advanced Computer:
pastebin get CODE installer
installer
```

Der Installer lädt automatisch alle 21 Dateien herunter und richtet alles ein!

### 📋 Manuelle Installation:

1. Erstelle das games-Verzeichnis: `mkdir games`
2. Kopiere alle 21 Dateien in den Computer
3. Starte das Casino: `casino`

### 🔧 Auto-Start einrichten:

Die `startup.lua` wird automatisch installiert und startet das Casino beim Booten!

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
    ├── baccarat.lua    # Baccarat
    ├── coinflip.lua    # Coin Flip
    ├── dice.lua        # Würfel
    ├── highlow.lua     # High/Low
    ├── war.lua         # War (Kartenkrieg)
    ├── crash.lua       # Crash
    ├── mines.lua       # Mines
    ├── tower.lua       # Tower Climb
    ├── plinko.lua      # Plinko
    ├── wheel.lua       # Wheel of Fortune
    ├── keno.lua        # Keno
    ├── scratch.lua     # Scratch Cards
    └── horses.lua      # Horse Racing
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

### 🎰 Slot Machine
- **Einsatz:** 1-10 Diamanten
- **Gewinn:** Bis zu 100x bei 3x Dollar
- 3 Walzen mit 6 verschiedenen Symbolen

### 🎡 Roulette
- **Einsatz:** 1-10 Diamanten
- **Wetten:** Rot/Schwarz (2x), Gerade/Ungerade (2x), Zahlen (36x)
- Zahlen 0-36

### 🃏 Blackjack
- **Einsatz:** 1-10 Diamanten
- **Gewinn:** 2x (2.5x bei Blackjack)
- Hit, Stand, Double Down
- Dealer muss unter 17 ziehen

### 🎴 Baccarat
- **Einsatz:** 1-10 Diamanten
- **Wetten:** Player (2x), Banker (1.95x), Tie (8x)
- Klassische Baccarat-Regeln

### 🪙 Coin Flip
- **Einsatz:** 1-10 Diamanten
- **Gewinn:** 2x
- Kopf oder Zahl

### 🎲 Dice
- **Einsatz:** 1-10 Diamanten
- **Gewinn:** 2x bis 5x
- Wettoptionen: 7/11, Gerade/Ungerade, High/Low, Pasch

### 🃏 High/Low
- **Einsatz:** 1-10 Diamanten
- **Gewinn:** +0.5x pro richtiger Runde
- Rate ob nächste Karte höher oder niedriger ist
- Cashout jederzeit möglich

### ⚔️ War
- **Einsatz:** 1-10 Diamanten
- **Gewinn:** 2x
- Kartenkrieg: Höhere Karte gewinnt

### 💥 Crash
- **Einsatz:** 1-10 Diamanten
- **Gewinn:** Variable (bis 10x)
- Multiplier steigt, cashout bevor es crasht!

### 💣 Mines
- **Einsatz:** 1-10 Diamanten
- **Gewinn:** Exponentiell steigend
- 5x5 Grid, vermeide Minen
- 3, 5, 7 oder 10 Minen wählbar

### 🗼 Tower
- **Einsatz:** 1-10 Diamanten
- **Gewinn:** +0.5x pro Level
- Klettere den Turm hoch
- 6, 8 oder 10 Levels

### 🎯 Plinko
- **Einsatz:** 1-10 Diamanten
- **Gewinn:** 0.5x bis 100x
- Ball fällt durch Pins
- 11 Multiplikator-Slots

### 🎡 Wheel of Fortune
- **Einsatz:** 1-10 Diamanten
- **Gewinn:** 2x bis 50x (oder Bankrott)
- Drehe das Glücksrad
- 12 Segmente

### 🔢 Keno
- **Einsatz:** 1-10 Diamanten
- **Gewinn:** 2x bis 500x
- Wähle 3, 5, 7 oder 10 Zahlen
- 20 Zahlen werden gezogen

### 🎫 Scratch Cards
- **Einsatz:** 1-10 Diamanten
- **Gewinn:** 2x bis 100x
- Rubbellose: Finde 3 gleiche Symbole
- 9 Felder zum Aufdecken

### 🐴 Horse Racing
- **Einsatz:** 1-10 Diamanten
- **Gewinn:** 4x
- 4 Pferde im Rennen
- Animiertes Rennen

## 📊 Statistik

- **16 Spiele** insgesamt
- **~80 KB** Code
- **4700+ Zeilen** Lua-Code
- **Unendliche** Spielmöglichkeiten! 🎰

## 📝 Entwickelt mit

- ComputerCraft: Tweaked
- Advanced Peripherals
- Minecraft 1.21.1
- All the Mods 10 Version 5.0

---
**Viel Glück beim Spielen! 🎰💎🍀**

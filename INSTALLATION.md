# Casino Installation - Schritt für Schritt

## 📦 Voraussetzungen

- **Minecraft 1.21.1**
- **Modpack:** All the Mods 10 Version 5.0
- **Mods:**
  - ComputerCraft: Tweaked
  - Advanced Peripherals

## 🛠️ Benötigte Komponenten

### Hardware-Liste:
- **1x Advanced Computer**
- **20x Advanced Monitor** (für 4x5 Anordnung)
- **1x RS Bridge** (von Advanced Peripherals)
- **1x Player Detector** (von Advanced Peripherals)
- **1x Double Chest** (normale Minecraft-Truhe)
- **Ausreichend Diamanten** für den Casino-Betrieb

## 🏗️ Hardware-Aufbau

### Schritt 1: Computer platzieren
Platziere den **Advanced Computer** an deiner gewünschten Position.

### Schritt 2: RS Bridge (UNTER dem Computer)
```
[Computer]
[RS Bridge] ← Direkt unter dem Computer
```
Die RS Bridge muss **direkt unter** dem Computer platziert werden.

### Schritt 3: Player Detector (AUF dem Computer)
```
[Detector] ← Direkt auf dem Computer
[Computer]
```
Der Player Detector muss **direkt auf** dem Computer platziert werden.

### Schritt 4: Monitor (RECHTS vom Computer)
```
[Mon][Mon][Mon][Mon]
[Mon][Mon][Mon][Mon]
[Mon][Mon][Mon][Mon]   [Computer]
[Mon][Mon][Mon][Mon]
[Mon][Mon][Mon][Mon]
```
Platziere die **20 Monitore** in einer **4x5 Anordnung** (4 breit, 5 hoch) **rechts** vom Computer.

Die Monitore werden sich automatisch zu einem großen Bildschirm verbinden.

### Schritt 5: Double Chest (VOR dem Computer)
```
[Computer]
 [Chest]
```
Platziere die **Double Chest** direkt **vor** dem Computer.

### Kompletter Aufbau:
```
Von oben betrachtet:

             [Monitor-Wand]
             [Monitor-Wand]
[Detector]   [Monitor-Wand]
[Computer]   [Monitor-Wand]
[RS Bridge]  [Monitor-Wand]
  [Chest]
```

## 💾 Software-Installation

### Methode 1: Direkt auf dem Computer (manuell)

1. **Rechtsklick** auf den Advanced Computer
2. **Erstelle** das Verzeichnis für Spiele:
   ```lua
   mkdir games
   ```

3. **Kopiere** alle Dateien auf den Computer:
   - `casino.lua` (Hauptprogramm)
   - `ui.lua` (UI-Bibliothek)
   - `inventory.lua` (Inventar-Verwaltung)
   - `startup.lua` (Auto-Start)
   - `games/slots.lua`
   - `games/roulette.lua`
   - `games/blackjack.lua`
   - `games/coinflip.lua`
   - `games/dice.lua`

4. **Jede Datei erstellen:**
   ```lua
   edit casino.lua
   -- Füge den Code ein
   -- Strg+S zum Speichern
   ```

### Methode 2: Mit Pastebin (empfohlen, wenn verfügbar)

Falls du die Dateien auf Pastebin hochlädst:

```lua
pastebin get <code> casino.lua
pastebin get <code> ui.lua
pastebin get <code> inventory.lua
pastebin get <code> startup.lua
mkdir games
cd games
pastebin get <code> slots.lua
pastebin get <code> roulette.lua
pastebin get <code> blackjack.lua
pastebin get <code> coinflip.lua
pastebin get <code> dice.lua
cd ..
```

### Methode 3: Mit wget (wenn HTTP verfügbar)

Falls du einen Webserver hast:
```lua
wget <url>/casino.lua casino.lua
-- Wiederhole für alle Dateien
```

## ✅ Test der Installation

### 1. Peripherie testen
```lua
lua
peripheral.getNames()
```

Du solltest sehen:
- `monitor_X` (Monitor)
- `playerDetector_X` (Player Detector)
- `rsBridge_X` (RS Bridge)

Falls nicht, überprüfe die Platzierung der Hardware!

### 2. Casino starten
```lua
casino
```

Oder einfach **Computer neustarten** (Strg+R), dann startet das Casino automatisch.

## 🎮 Erste Schritte

1. **Diamanten einlegen:**
   - Lege Diamanten in die Double Chest vor dem Computer
   - Oder verbinde die Chest mit deinem RS-System

2. **Näher kommen:**
   - Gehe näher als **15 Blöcke** zum Player Detector

3. **Spielen:**
   - Das System erkennt dich automatisch
   - Wähle deinen Namen aus der Liste
   - Wähle ein Spiel
   - Viel Spaß!

## 🔧 Fehlerbehebung

### "Monitor nicht gefunden"
- **Lösung:** Monitor muss **rechts** vom Computer sein
- Prüfe mit: `peripheral.find("monitor")`

### "Player Detector nicht gefunden"
- **Lösung:** Player Detector muss **auf** dem Computer sein (Position "top")
- Prüfe mit: `peripheral.find("playerDetector")`

### "RS Bridge nicht gefunden"
- **Lösung:** RS Bridge muss **unter** dem Computer sein (Position "bottom")
- **Alternative:** Das System funktioniert auch ohne RS Bridge im "Simple Mode"
- Prüfe mit: `peripheral.find("rsBridge")`

### "Keine Spieler gefunden"
- **Lösung:** Komm näher als 15 Blöcke zum Computer
- Der Player Detector hat eine Reichweite von 15 Blöcken

### Monitor zeigt nichts an
- **Lösung:** Stelle sicher, dass alle 20 Monitore verbunden sind
- Alle Monitore sollten zu einem großen Bildschirm werden
- Rechtsklick auf Monitor zum Testen

### "Keine Diamanten vorhanden"
- **Lösung:** Lege Diamanten in die Chest
- Oder verbinde die Chest mit deinem RS-System
- Drücke "Diamanten Update" im Hauptmenü

## 📋 Checkliste

- [ ] Advanced Computer platziert
- [ ] RS Bridge UNTER Computer
- [ ] Player Detector AUF Computer
- [ ] 20 Monitore (4x5) RECHTS vom Computer
- [ ] Double Chest VOR Computer
- [ ] Alle Dateien kopiert (9 Dateien total)
- [ ] `games/` Verzeichnis erstellt
- [ ] Alle 5 Spiele im `games/` Verzeichnis
- [ ] Startup.lua vorhanden
- [ ] Peripherie getestet
- [ ] Diamanten in Chest
- [ ] Casino gestartet
- [ ] Erfolgreich eingeloggt

## 🎰 Verfügbare Spiele

1. **Slot Machine** - Klassischer Spielautomat mit Symbolen
2. **Roulette** - Setze auf Rot/Schwarz, Zahlen, etc.
3. **Blackjack** - Hit, Stand, Double Down gegen den Dealer
4. **Coin Flip** - Einfach Kopf oder Zahl
5. **Dice** - Würfelspiel mit verschiedenen Wettoptionen

## 💡 Tipps

- **Automatischer Start:** Die `startup.lua` startet das Casino automatisch
- **Neustart:** Drücke `Strg+R` um den Computer neu zu starten
- **Beenden:** Drücke `Strg+T` um das Programm zu beenden (wird aber automatisch neu gestartet)
- **Edit Mode:** Entferne `startup.lua` wenn du das Casino nicht automatisch starten willst

## 📞 Support

Falls Probleme auftreten:
1. Prüfe die Hardware-Platzierung
2. Teste die Peripherie mit `lua` und `peripheral.getNames()`
3. Lies die Fehlermeldungen auf dem Computer-Bildschirm
4. Stelle sicher, dass alle Dateien vorhanden sind

---
**Viel Erfolg mit deinem Casino! 🎰💎**

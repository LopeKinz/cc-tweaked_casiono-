-- Inventory Management über RS Bridge
-- Kompatibel mit Advanced Peripherals 0.7+ API
-- Dokumentation: https://docs.advanced-peripherals.de/0.7/peripherals/rs_bridge/
local Inventory = {}

-- Konfiguration: Richtung zur Truhe (laut INSTALLATION.md: vor dem Computer)
Inventory.CHEST_DIRECTION = "front"

-- RS Bridge initialisieren
function Inventory.init(rsBridge)
    Inventory.bridge = rsBridge
    if not rsBridge then
        error("RS Bridge nicht gefunden! Bitte unter dem Computer platzieren.")
    end

    -- Spieler-Kiste (direkt vor dem Computer, NICHT im RS-Netzwerk)
    Inventory.playerChest = peripheral.wrap(Inventory.CHEST_DIRECTION)
    if not Inventory.playerChest then
        print("WARNUNG: Keine Kiste an 'front' gefunden!")
    end

    return Inventory
end

-- Health-Check: Prüft ob RS Bridge funktional ist
-- Testet mit minecraft:diamond da dies das Item ist, das das Casino benötigt
function Inventory.healthCheck()
    if not Inventory.bridge then
        return false, "Keine Bridge konfiguriert"
    end

    -- Prüfe ob getItem() Methode existiert
    if type(Inventory.bridge.getItem) ~= "function" then
        return false, "RS Bridge hat keine getItem() Methode"
    end

    -- Test-Aufruf mit minecraft:diamond (Casino-spezifisches Item)
    -- Wichtig: Nur ob die Methode funktioniert, nicht ob Diamanten vorhanden sind
    local success, result = pcall(function()
        return Inventory.bridge.getItem({ name = "minecraft:diamond" })
    end)

    if not success then
        return false, "getItem() Aufruf fehlgeschlagen: " .. tostring(result)
    end

    -- Bridge ist funktional (egal ob Diamanten gefunden wurden oder nil zurückkam)
    return true, "RS Bridge funktional"
end

-- Hole ein spezifisches Item aus dem Netzwerk (effizienter als listItems)
-- Verwendet getItem() statt listItems() für bessere Kompatibilität und Performance
function Inventory.getItem(itemName)
    if not Inventory.bridge then
        return nil
    end

    -- Prüfe ob getItem() Methode existiert
    if type(Inventory.bridge.getItem) ~= "function" then
        error("RS Bridge hat keine getItem() Methode! Bitte Advanced Peripherals 0.7+ installieren.")
    end

    -- Versuche Item abzurufen mit Fehlerbehandlung
    local success, result = pcall(function()
        return Inventory.bridge.getItem({ name = itemName })
    end)

    if not success then
        print("[WARNUNG] getItem fehlgeschlagen: " .. tostring(result))
        return nil
    end

    return result
end

-- Diamanten im Netzwerk zählen (direkte Abfrage statt Loop über alle Items)
-- HINWEIS: Dies zählt Diamanten im RS-Netzwerk (Casino-Bank)
function Inventory.countNetworkDiamonds()
    if not Inventory.bridge then
        return 0
    end

    local item = Inventory.getItem("minecraft:diamond")

    if not item then
        return 0  -- Keine Diamanten im Netzwerk
    end

    -- Kompatibilität: res.amount oder res.count
    return item.amount or item.count or 0
end

-- Diamanten in der Spieler-Kiste zählen (front)
-- Dies ist die Balance des Spielers!
function Inventory.countPlayerDiamonds()
    if not Inventory.playerChest then
        print("WARNUNG: Keine Spieler-Kiste gefunden!")
        return 0
    end

    local totalDiamonds = 0

    -- Durchsuche alle Slots der Kiste
    for slot = 1, Inventory.playerChest.size() do
        local item = Inventory.playerChest.getItemDetail(slot)
        if item and item.name == "minecraft:diamond" then
            totalDiamonds = totalDiamonds + item.count
        end
    end

    return totalDiamonds
end

-- Hauptfunktion: Spieler-Balance abrufen (aus der Front-Kiste)
function Inventory.countDiamonds()
    return Inventory.countPlayerDiamonds()
end

-- Diamanten aus der Spieler-Kiste nehmen (Verlust)
-- Transferiert Diamanten aus der Front-Kiste ins RS-Netzwerk (Casino-Bank)
function Inventory.takeFromPlayer(amount)
    if not Inventory.playerChest or not Inventory.bridge then
        print("WARNUNG: Kann Diamanten nicht transferieren - Kiste oder Bridge fehlt")
        return false
    end

    -- Prüfe ob genug Diamanten vorhanden sind
    local available = Inventory.countPlayerDiamonds()
    if available < amount then
        print("WARNUNG: Nicht genug Diamanten in Spieler-Kiste")
        return false
    end

    -- Importiere Diamanten aus der Front-Kiste ins RS-Netzwerk
    local success, imported = pcall(function()
        return Inventory.bridge.importItem(
            {name = "minecraft:diamond", count = amount},
            Inventory.CHEST_DIRECTION
        )
    end)

    if not success or not imported or imported < amount then
        print("FEHLER: Konnte Diamanten nicht aus Spieler-Kiste nehmen")
        return false
    end

    return true
end

-- Diamanten zur Spieler-Kiste hinzufügen (Gewinn)
-- Transferiert Diamanten aus dem RS-Netzwerk (Casino-Bank) in die Front-Kiste
function Inventory.giveToPlayer(amount)
    if not Inventory.playerChest or not Inventory.bridge then
        print("WARNUNG: Kann Diamanten nicht transferieren - Kiste oder Bridge fehlt")
        return false
    end

    -- Prüfe ob genug Diamanten im Casino vorhanden sind
    local available = Inventory.countNetworkDiamonds()
    if available < amount then
        print("WARNUNG: Casino hat nicht genug Diamanten!")
        return false
    end

    -- Exportiere Diamanten aus dem RS-Netzwerk in die Front-Kiste
    local success, exported = pcall(function()
        return Inventory.bridge.exportItem(
            {name = "minecraft:diamond", count = amount},
            Inventory.CHEST_DIRECTION
        )
    end)

    if not success or not exported or exported < amount then
        print("FEHLER: Konnte Diamanten nicht zur Spieler-Kiste hinzufügen")
        return false
    end

    return true
end

-- Balance synchronisieren: Aktualisiere physische Diamanten basierend auf Balance-Änderung
function Inventory.syncBalance(oldBalance, newBalance)
    local difference = newBalance - oldBalance

    if difference > 0 then
        -- Spieler hat gewonnen - Diamanten hinzufügen
        return Inventory.giveToPlayer(difference)
    elseif difference < 0 then
        -- Spieler hat verloren - Diamanten nehmen
        return Inventory.takeFromPlayer(math.abs(difference))
    end

    -- Keine Änderung
    return true
end

-- Diamanten aus dem Netzwerk nehmen
function Inventory.takeDiamonds(amount, targetChest)
    if not Inventory.bridge then
        return 0
    end

    -- Prüfe erst ob genug Diamanten vorhanden sind
    local available = Inventory.countDiamonds()
    if available <= 0 then
        return 0
    end

    -- Nimm nur so viele wie verfügbar sind
    local toTake = math.min(amount, available)

    -- Exportiere in Truhe (Richtung konfigurierbar)
    local direction = targetChest or Inventory.CHEST_DIRECTION

    -- Korrekte API: exportItem(item: table, direction: string) -> number
    local success, exported = pcall(function()
        return Inventory.bridge.exportItem(
            {name = "minecraft:diamond", count = toTake},
            direction
        )
    end)

    if not success then
        print("[FEHLER] exportItem fehlgeschlagen: " .. tostring(exported))
        return 0
    end

    return exported or 0
end

-- Diamanten ins Netzwerk zurücklegen
function Inventory.returnDiamonds(amount, sourceChest)
    if not Inventory.bridge then
        return false
    end

    -- Import von Truhe (Richtung konfigurierbar)
    local direction = sourceChest or Inventory.CHEST_DIRECTION

    -- Korrekte API: importItem(item: table, direction: string) -> number
    local imported = Inventory.bridge.importItem(
        {name = "minecraft:diamond", count = amount},
        direction
    )

    return imported and imported > 0
end

-- Prüfen ob genug Diamanten vorhanden sind
function Inventory.hasDiamonds(amount)
    return Inventory.countDiamonds() >= amount
end

-- Einsatz verarbeiten (Diamanten entfernen)
function Inventory.placeBet(amount, playerName)
    if not Inventory.hasDiamonds(amount) then
        return false, "Nicht genug Diamanten!"
    end

    -- In einem echten System würden wir hier die Diamanten
    -- in eine "Wett-Truhe" verschieben oder markieren
    -- Für Simulation: Speichern wir nur den Betrag
    Inventory.currentBet = {
        amount = amount,
        player = playerName
    }

    return true, "Einsatz platziert!"
end

-- Gewinn auszahlen (Diamanten hinzufügen)
function Inventory.payoutWin(amount, multiplier)
    if not Inventory.currentBet then
        return false
    end

    local payout = math.floor(amount * multiplier)

    -- In echtem System: Diamanten aus Casino-Reserve in Spieler-Truhe
    -- Für Simulation: Markieren als ausgezahlt
    Inventory.currentBet = nil

    return true, payout
end

-- Verlust verarbeiten (Diamanten behalten)
function Inventory.processLoss(amount)
    if not Inventory.currentBet then
        return false
    end

    -- Diamanten bleiben im Casino
    Inventory.currentBet = nil

    return true
end

-- Statistik: Gesamte Casino-Diamanten
function Inventory.getCasinoBalance()
    return Inventory.countDiamonds()
end

-- Detaillierte Inventar-Info für Debugging
-- Hinweis: Diese Funktion verwendet weiterhin listItems() da sie ALLE Items benötigt
function Inventory.getInventoryDetails()
    if not Inventory.bridge then
        return {totalItems = 0, diamonds = 0, otherItems = {}}
    end

    local details = {
        totalItems = 0,
        diamonds = 0,
        otherItems = {}
    }

    -- Nur für Debug-Zwecke: Verwende listItems() um alle Items zu sehen
    local success, items = pcall(function()
        return Inventory.bridge.listItems()
    end)

    if not success or not items then
        print("[WARNUNG] listItems für Debug fehlgeschlagen")
        -- Fallback: Nutze getItem für Diamanten
        local diamondItem = Inventory.getItem("minecraft:diamond")
        if diamondItem then
            details.diamonds = diamondItem.amount or diamondItem.count or 0
            details.totalItems = 1
        end
        return details
    end

    for _, item in pairs(items) do
        details.totalItems = details.totalItems + 1

        if item.name == "minecraft:diamond" then
            details.diamonds = details.diamonds + item.amount
        else
            table.insert(details.otherItems, {
                name = item.name,
                amount = item.amount
            })
        end
    end

    return details
end

-- Alternative einfache Implementierung ohne RS Bridge
-- (Falls RS Bridge Probleme macht oder für Tests)
function Inventory.initSimple()
    Inventory.simpleMode = true
    Inventory.virtualBalance = 100 -- Start mit 100 Diamanten für Tests

    -- Versuche trotzdem die Spieler-Kiste zu finden
    Inventory.playerChest = peripheral.wrap(Inventory.CHEST_DIRECTION)
    if not Inventory.playerChest then
        print("WARNUNG: Keine Kiste an 'front' gefunden! Verwende virtuelles Balance-System.")
    end

    return Inventory
end

function Inventory.countDiamondsSimple()
    -- Wenn Spieler-Kiste verfügbar ist, verwende sie
    if Inventory.playerChest then
        return Inventory.countPlayerDiamonds()
    end
    -- Sonst virtuelles Balance-System
    return Inventory.virtualBalance or 0
end

function Inventory.placeBetSimple(amount, playerName)
    if (Inventory.virtualBalance or 0) < amount then
        return false, "Nicht genug Diamanten!"
    end

    Inventory.currentBet = {
        amount = amount,
        player = playerName
    }

    return true, "Einsatz platziert!"
end

function Inventory.payoutWinSimple(amount, multiplier)
    local payout = math.floor(amount * multiplier)
    Inventory.virtualBalance = (Inventory.virtualBalance or 0) + (payout - amount)
    Inventory.currentBet = nil
    return true, payout
end

function Inventory.processLossSimple(amount)
    Inventory.virtualBalance = (Inventory.virtualBalance or 0) - amount
    Inventory.currentBet = nil
    return true
end

-- Wrapper-Funktionen die simple/normal Mode automatisch wählen
function Inventory.wrap()
    if Inventory.simpleMode then
        Inventory.countDiamonds = Inventory.countDiamondsSimple
        Inventory.placeBet = Inventory.placeBetSimple
        Inventory.payoutWin = Inventory.payoutWinSimple
        Inventory.processLoss = Inventory.processLossSimple
    end
end

return Inventory

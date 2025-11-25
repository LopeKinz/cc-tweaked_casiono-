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
function Inventory.countDiamonds()
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
    return Inventory
end

function Inventory.countDiamondsSimple()
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

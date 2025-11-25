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

-- Alle verfügbaren Items im Netzwerk abrufen
function Inventory.getItems()
    if not Inventory.bridge then
        return {}
    end

    -- Prüfe ob listItems() Methode existiert
    if type(Inventory.bridge.listItems) ~= "function" then
        error("RS Bridge hat keine listItems() Methode! Bitte Advanced Peripherals 0.7+ installieren.")
    end

    -- Versuche Items abzurufen mit Fehlerbehandlung
    local success, result = pcall(function()
        return Inventory.bridge.listItems()
    end)

    if not success then
        error("Fehler beim Abrufen der Items: " .. tostring(result))
    end

    return result or {}
end

-- Diamanten im Netzwerk zählen
function Inventory.countDiamonds()
    local items = Inventory.getItems()
    local total = 0

    for _, item in pairs(items) do
        if item.name == "minecraft:diamond" then
            total = total + item.amount
        end
    end

    return total
end

-- Diamanten aus dem Netzwerk nehmen
function Inventory.takeDiamonds(amount, targetChest)
    if not Inventory.bridge then
        return false
    end

    -- Versuche Diamanten aus dem Netzwerk zu exportieren
    local taken = 0
    local items = Inventory.getItems()

    for _, item in pairs(items) do
        if item.name == "minecraft:diamond" then
            local toTake = math.min(amount - taken, item.amount)

            -- Exportiere in Truhe (Richtung konfigurierbar)
            local direction = targetChest or Inventory.CHEST_DIRECTION

            -- Korrekte API: exportItem(item: table, direction: string) -> number
            local exported = Inventory.bridge.exportItem(
                {name = "minecraft:diamond", count = toTake},
                direction
            )

            if exported and exported > 0 then
                taken = taken + exported
            end

            if taken >= amount then
                break
            end
        end
    end

    return taken
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
function Inventory.getInventoryDetails()
    local items = Inventory.getItems()
    local details = {
        totalItems = 0,
        diamonds = 0,
        otherItems = {}
    }

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

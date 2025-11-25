-- Inventory Management über RS Bridge
local Inventory = {}

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
    return Inventory.bridge.listItems()
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

            -- Exportiere in Computer-Inventar (oder spezifische Truhe)
            if targetChest then
                local success = Inventory.bridge.exportItem(
                    {name = "minecraft:diamond", count = toTake},
                    targetChest
                )
                if success then
                    taken = taken + toTake
                end
            else
                -- Export in Computer selbst (falls möglich)
                local success = Inventory.bridge.exportItem(
                    {name = "minecraft:diamond"},
                    toTake
                )
                if success then
                    taken = taken + toTake
                end
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

    -- Import von Computer oder spezifischer Truhe
    if sourceChest then
        return Inventory.bridge.importItem(
            {name = "minecraft:diamond", count = amount},
            sourceChest
        )
    else
        return Inventory.bridge.importItem(
            {name = "minecraft:diamond"},
            amount
        )
    end
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

-- Slot Machine (Spielautomat)
local Slots = {}

-- Symbole für die Walzen
local symbols = {
    {char = "$", color = colors.yellow, name = "Dollar"},
    {char = "7", color = colors.red, name = "Sieben"},
    {char = "*", color = colors.orange, name = "Stern"},
    {char = "@", color = colors.blue, name = "Diamant"},
    {char = "#", color = colors.purple, name = "Kirsche"},
    {char = "&", color = colors.lime, name = "Glocke"}
}

-- Gewinn-Tabelle
local payouts = {
    ["$$$"] = 100,  -- 3x Dollar = 100x
    ["777"] = 50,   -- 3x Sieben = 50x
    ["***"] = 20,   -- 3x Stern = 20x
    ["@@@"] = 15,   -- 3x Diamant = 15x
    ["###"] = 10,   -- 3x Kirsche = 10x
    ["&&&"] = 10,   -- 3x Glocke = 10x
    ["$$-"] = 5,    -- 2x Dollar = 5x
    ["77-"] = 3,    -- 2x Sieben = 3x
    ["**-"] = 2,    -- 2x Stern = 2x
}

-- Initialisierung
function Slots.init(ui, inventory)
    Slots.ui = ui
    Slots.inventory = inventory
    return Slots
end

-- Haupt-Spiel-Loop
function Slots.play(playerName, playerBalance)
    while true do
        -- Einsatz wählen
        local bet = Slots.selectBet(playerBalance)
        if bet == 0 then
            return playerBalance -- Zurück zum Menü
        end

        if bet > playerBalance then
            Slots.ui.clear()
            Slots.ui.drawTitle("SLOT MACHINE")
            Slots.ui.centerText(10, "Nicht genug Diamanten!", colors.red)
            sleep(2)
        else
            -- Spiel starten
            local won, payout = Slots.spin(bet)

            -- Balance aktualisieren
            if won then
                playerBalance = playerBalance + payout
            else
                playerBalance = playerBalance - bet
            end

            -- Ergebnis anzeigen
            Slots.ui.showResult(won, won and payout or bet)

            -- Prüfen ob Spieler pleite ist
            if playerBalance <= 0 then
                Slots.ui.clear()
                Slots.ui.drawTitle("GAME OVER")
                Slots.ui.centerText(10, "Keine Diamanten mehr!", colors.red)
                Slots.ui.centerText(12, "Bitte Diamanten nachtanken.", colors.white)
                sleep(3)
                return 0
            end
        end
    end
end

-- Einsatz auswählen
function Slots.selectBet(maxBet)
    local result = Slots.ui.selectAmount(
        "SLOT MACHINE - Einsatz waehlen",
        1,
        maxBet
    )

    return result[1].amount
end

-- Walzen drehen
function Slots.spin(bet)
    Slots.ui.clear()
    Slots.ui.drawTitle("SLOT MACHINE")

    -- Einsatz anzeigen
    Slots.ui.centerText(4, "Einsatz: " .. bet .. " Diamanten", colors.yellow)

    -- Walzen-Positionen
    local reel1X = math.floor(Slots.ui.width / 2) - 12
    local reel2X = math.floor(Slots.ui.width / 2) - 4
    local reel3X = math.floor(Slots.ui.width / 2) + 4
    local reelY = 10

    -- Walzen zeichnen (Rahmen)
    for _, x in ipairs({reel1X, reel2X, reel3X}) do
        Slots.ui.drawBorder(x, reelY - 1, 8, 10, colors.yellow)
    end

    -- Animation
    local results = {}
    local spinDurations = {1.5, 2.0, 2.5} -- Walzen stoppen nacheinander

    for i = 1, 3 do
        local x = i == 1 and reel1X or (i == 2 and reel2X or reel3X)
        Slots.animateReel(x, reelY, spinDurations[i])
        results[i] = Slots.getRandomSymbol()
        Slots.drawSymbol(x, reelY, results[i])
        sleep(0.3)
    end

    -- Gewinn prüfen
    local won, payout = Slots.checkWin(results, bet)

    -- Gewinnlinie anzeigen
    sleep(0.5)
    if won then
        Slots.highlightWin(reel1X, reel2X, reel3X, reelY)
    end

    sleep(1)
    return won, payout
end

-- Walze animieren
function Slots.animateReel(x, y, duration)
    local steps = math.floor(duration / 0.1)

    for i = 1, steps do
        local symbol = symbols[math.random(#symbols)]
        Slots.drawSymbol(x, y, symbol)
        sleep(0.1)
    end
end

-- Symbol zeichnen
function Slots.drawSymbol(x, y, symbol)
    Slots.ui.drawBox(x + 1, y + 2, 6, 5, colors.black)

    -- Großes Symbol
    Slots.ui.monitor.setTextColor(symbol.color)
    Slots.ui.monitor.setBackgroundColor(colors.black)

    -- Zentriert in der Box
    local charX = x + 4
    local charY = y + 4

    Slots.ui.monitor.setCursorPos(charX, charY)
    Slots.ui.monitor.write(symbol.char)
end

-- Zufälliges Symbol
function Slots.getRandomSymbol()
    return symbols[math.random(#symbols)]
end

-- Gewinn prüfen
function Slots.checkWin(results, bet)
    -- Alle 3 gleich?
    local pattern = results[1].char .. results[2].char .. results[3].char
    if payouts[pattern] then
        return true, bet * payouts[pattern]
    end

    -- Erste 2 gleich?
    if results[1].char == results[2].char then
        local twoPattern = results[1].char .. results[1].char .. "-"
        if payouts[twoPattern] then
            return true, bet * payouts[twoPattern]
        end
    end

    return false, 0
end

-- Gewinn hervorheben
function Slots.highlightWin(x1, x2, x3, y)
    for i = 1, 3 do
        -- Blinkende Umrandung
        for _, x in ipairs({x1, x2, x3}) do
            Slots.ui.drawBorder(x, y - 1, 8, 10, colors.lime)
        end
        sleep(0.2)

        for _, x in ipairs({x1, x2, x3}) do
            Slots.ui.drawBorder(x, y - 1, 8, 10, colors.yellow)
        end
        sleep(0.2)
    end
end

-- Gewinn-Tabelle anzeigen
function Slots.showPayoutTable()
    Slots.ui.clear()
    Slots.ui.drawTitle("SLOT MACHINE - Gewinntabelle")

    local y = 5
    Slots.ui.centerText(y, "Gewinnkombinationen:", colors.white)
    y = y + 2

    local payoutList = {
        {"$$$", "100x Einsatz"},
        {"777", "50x Einsatz"},
        {"***", "20x Einsatz"},
        {"@@@", "15x Einsatz"},
        {"###", "10x Einsatz"},
        {"&&&", "10x Einsatz"},
        {"$$", "5x Einsatz"},
        {"77", "3x Einsatz"},
        {"**", "2x Einsatz"},
    }

    for _, entry in ipairs(payoutList) do
        Slots.ui.centerText(y, entry[1] .. " = " .. entry[2], colors.yellow)
        y = y + 1
    end

    y = y + 2
    local backButton = Slots.ui.drawButton(
        math.floor(Slots.ui.width / 2) - 10,
        y,
        20, 3,
        "Zurueck",
        colors.red,
        colors.white
    )

    Slots.ui.waitForTouch({backButton})
end

return Slots

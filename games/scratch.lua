-- Scratch Cards (Rubbellose)
local Scratch = {}

-- Symbole und ihre Werte
local symbols = {
    {char = "$", multiplier = 100, color = colors.yellow},
    {char = "7", multiplier = 50, color = colors.red},
    {char = "*", multiplier = 20, color = colors.orange},
    {char = "@", multiplier = 10, color = colors.blue},
    {char = "#", multiplier = 5, color = colors.purple},
    {char = "&", multiplier = 2, color = colors.lime}
}

-- Initialisierung
function Scratch.init(ui, inventory)
    Scratch.ui = ui
    Scratch.inventory = inventory
    return Scratch
end

-- Haupt-Spiel-Loop
function Scratch.play(playerName, playerBalance)
    while true do
        -- Einsatz wählen
        local bet = Scratch.selectBet(playerBalance)
        if bet == 0 then
            return playerBalance
        end

        if bet > playerBalance then
            Scratch.ui.clear()
            Scratch.ui.drawTitle("SCRATCH CARDS")
            Scratch.ui.centerText(10, "Nicht genug Diamanten!", colors.red)
            sleep(2)
        else
            -- Rubbellos spielen
            local won, payout = Scratch.playCard(bet)

            -- Balance aktualisieren
            if won then
                playerBalance = playerBalance + payout
            else
                playerBalance = playerBalance - bet
            end

            -- Ergebnis anzeigen
            Scratch.ui.showResult(won, won and payout or bet)

            if playerBalance <= 0 then
                Scratch.ui.clear()
                Scratch.ui.drawTitle("GAME OVER")
                Scratch.ui.centerText(10, "Keine Diamanten mehr!", colors.red)
                sleep(3)
                return 0
            end
        end
    end
end

-- Einsatz wählen
function Scratch.selectBet(maxBet)
    local result = Scratch.ui.selectAmount(
        "SCRATCH CARDS - Einsatz",
        1,
        maxBet
    )
    return result[1].amount
end

-- Rubbellos spielen
function Scratch.playCard(bet)
    Scratch.ui.clear()
    Scratch.ui.drawTitle("SCRATCH CARDS")

    Scratch.ui.centerText(4, "Einsatz: " .. bet .. " Diamanten", colors.yellow)
    Scratch.ui.centerText(5, "Finde 3 gleiche Symbole!", colors.white)

    -- 9 Felder generieren (3x3)
    local fields = {}
    for i = 1, 9 do
        table.insert(fields, symbols[math.random(#symbols)])
    end

    -- Mit etwas Glück ein paar gleiche hinzufügen
    if math.random(100) <= 30 then  -- 30% Gewinnchance
        local winSymbol = symbols[math.random(#symbols)]
        -- 3 eindeutige zufällige Positionen mit Gewinn-Symbol ersetzen
        local positions = {}
        while #positions < 3 do
            local pos = math.random(9)
            local alreadyExists = false
            for _, existingPos in ipairs(positions) do
                if existingPos == pos then
                    alreadyExists = true
                    break
                end
            end
            if not alreadyExists then
                table.insert(positions, pos)
            end
        end
        for _, pos in ipairs(positions) do
            fields[pos] = winSymbol
        end
    end

    -- Felder anzeigen (verdeckt)
    local revealed = {}
    local buttons = {}

    local fieldSize = 10
    local spacing = 2
    local startX = math.floor((Scratch.ui.width - (3 * fieldSize + 2 * spacing)) / 2)
    local startY = 10

    for row = 0, 2 do
        for col = 0, 2 do
            local index = row * 3 + col + 1
            local x = startX + col * (fieldSize + spacing)
            local y = startY + row * (fieldSize + spacing)

            local button = Scratch.ui.drawButton(
                x, y, fieldSize, fieldSize - 1,
                "?",
                colors.gray,
                colors.white
            )
            button.index = index
            table.insert(buttons, button)
        end
    end

    -- Felder einzeln aufdecken
    for i = 1, 9 do
        local choice, button = Scratch.ui.waitForTouch(buttons)
        local index = button.index

        if not revealed[index] then
            revealed[index] = true

            -- Feld aufdecken
            local row = math.floor((index - 1) / 3)
            local col = (index - 1) % 3
            local x = startX + col * (fieldSize + spacing)
            local y = startY + row * (fieldSize + spacing)

            local symbol = fields[index]

            Scratch.ui.drawBox(x, y, fieldSize, fieldSize - 1, symbol.color)
            Scratch.ui.monitor.setCursorPos(x + 4, y + 4)
            Scratch.ui.monitor.setTextColor(colors.white)
            Scratch.ui.monitor.setBackgroundColor(symbol.color)
            Scratch.ui.monitor.write(symbol.char)

            -- Button aus Liste entfernen
            for j = #buttons, 1, -1 do
                if buttons[j].index == index then
                    table.remove(buttons, j)
                    break
                end
            end
        end
    end

    sleep(1)

    -- Alle Felder aufgedeckt - Gewinn prüfen
    local symbolCounts = {}
    for _, symbol in ipairs(fields) do
        local char = symbol.char
        symbolCounts[char] = (symbolCounts[char] or 0) + 1
    end

    -- 3 oder mehr gleiche?
    local won = false
    local winSymbol = nil
    for char, count in pairs(symbolCounts) do
        if count >= 3 then
            won = true
            -- Finde das Symbol
            for _, s in ipairs(symbols) do
                if s.char == char then
                    winSymbol = s
                    break
                end
            end
            break
        end
    end

    if won and winSymbol then
        local payout = bet * winSymbol.multiplier
        Scratch.ui.centerText(startY + 3 * (fieldSize + spacing) + 2,
                            "3x " .. winSymbol.char .. " = " .. winSymbol.multiplier .. "x",
                            colors.lime)
        sleep(2)
        return true, payout
    else
        Scratch.ui.centerText(startY + 3 * (fieldSize + spacing) + 2,
                            "Kein Gewinn!",
                            colors.red)
        sleep(2)
        return false, 0
    end
end

return Scratch

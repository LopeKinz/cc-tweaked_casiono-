-- Tower Climb (Turm-Kletterspiel)
local Tower = {}

-- Initialisierung
function Tower.init(ui, inventory)
    Tower.ui = ui
    Tower.inventory = inventory
    return Tower
end

-- Haupt-Spiel-Loop
function Tower.play(playerName, playerBalance)
    while true do
        -- Einsatz wählen
        local bet = Tower.selectBet(playerBalance)
        if bet == 0 then
            return playerBalance
        end

        if bet > playerBalance then
            Tower.ui.clear()
            Tower.ui.drawTitle("TOWER")
            Tower.ui.centerText(10, "Nicht genug Diamanten!", colors.red)
            sleep(2)
        else
            -- Schwierigkeit wählen
            local difficulty = Tower.selectDifficulty()
            if not difficulty then
                -- Zurück
            else
                -- Spiel starten
                local won, payout = Tower.climb(bet, difficulty)

                -- Balance aktualisieren
                if won then
                    playerBalance = playerBalance + payout
                else
                    playerBalance = playerBalance - bet
                end

                -- Ergebnis anzeigen
                Tower.ui.showResult(won, won and payout or bet)

                if playerBalance <= 0 then
                    Tower.ui.clear()
                    Tower.ui.drawTitle("GAME OVER")
                    Tower.ui.centerText(10, "Keine Diamanten mehr!", colors.red)
                    sleep(3)
                    return 0
                end
            end
        end
    end
end

-- Einsatz wählen
function Tower.selectBet(maxBet)
    local buttons = Tower.ui.selectAmount(
        "TOWER - Einsatz waehlen",
        1,
        math.min(10, maxBet)
    )
    local choice, button = Tower.ui.waitForTouch(buttons)
    return button.amount
end

-- Schwierigkeit wählen
function Tower.selectDifficulty()
    Tower.ui.clear()
    Tower.ui.drawTitle("TOWER - Schwierigkeit")

    local options = {
        {text = "Einfach (2 Wege)", ways = 2, levels = 6, color = colors.lime},
        {text = "Mittel (3 Wege)", ways = 3, levels = 8, color = colors.yellow},
        {text = "Schwer (4 Wege)", ways = 4, levels = 10, color = colors.red},
        {text = "Zurueck", ways = nil, color = colors.red}
    }

    local buttons = Tower.ui.drawMenu("", options, 8)
    local choice, button = Tower.ui.waitForTouch(buttons)

    if choice == #buttons then
        return nil
    end

    return options[choice]
end

-- Turm klettern
function Tower.climb(bet, difficulty)
    local numWays = difficulty.ways
    local numLevels = difficulty.levels
    local currentLevel = 0

    -- Sichere Wege für jedes Level generieren
    local safeWays = {}
    for level = 1, numLevels do
        safeWays[level] = math.random(numWays)
    end

    while currentLevel < numLevels do
        Tower.ui.clear()
        Tower.ui.drawTitle("TOWER")

        -- Info
        local currentMultiplier = 1.0 + (currentLevel * 0.5)
        Tower.ui.centerText(3, "Level: " .. currentLevel .. "/" .. numLevels, colors.white)
        Tower.ui.centerText(4, "Multiplikator: " .. string.format("%.1fx", currentMultiplier), colors.yellow)

        -- Turm zeichnen (bisherige Levels)
        local tileWidth = math.floor(40 / numWays)
        local startX = math.floor((Tower.ui.width - (numWays * tileWidth)) / 2)
        local startY = 28  -- Von unten nach oben

        for level = 0, math.min(currentLevel, 5) do
            local y = startY - level * 3

            for way = 1, numWays do
                local x = startX + (way - 1) * tileWidth

                -- Bereits gekletterte Levels grün
                if level < currentLevel then
                    local color = (safeWays[level + 1] == way) and colors.lime or colors.red
                    Tower.ui.drawBox(x, y, tileWidth - 1, 2, color)
                end
            end
        end

        -- Aktuelles Level - Auswahl
        local y = startY - currentLevel * 3
        local buttons = {}

        for way = 1, numWays do
            local x = startX + (way - 1) * tileWidth

            local button = Tower.ui.drawButton(
                x, y, tileWidth - 1, 2,
                tostring(way),
                colors.gray,
                colors.white
            )
            button.way = way
            table.insert(buttons, button)
        end

        -- Cashout Button (wenn nicht erste Stufe)
        if currentLevel > 0 then
            local cashoutButton = Tower.ui.drawButton(
                math.floor(Tower.ui.width / 2) - 12,
                startY + 3,
                25, 3,
                "CASHOUT",
                colors.yellow,
                colors.black
            )
            cashoutButton.way = -1
            table.insert(buttons, cashoutButton)
        end

        -- Aufgeben Button
        local quitButton = Tower.ui.drawButton(
            math.floor(Tower.ui.width / 2) + 15,
            startY + 3,
            12, 3,
            "Aufgeben",
            colors.red,
            colors.white
        )
        quitButton.way = -2
        table.insert(buttons, quitButton)

        local choice, button = Tower.ui.waitForTouch(buttons)

        if button.way == -1 then
            -- Cashout
            local payout = math.floor(bet * currentMultiplier)
            return true, payout
        elseif button.way == -2 then
            -- Aufgeben
            return false, 0
        else
            -- Weg wählen
            local chosenWay = button.way
            local safeWay = safeWays[currentLevel + 1]

            -- Animation - Weg aufdecken
            sleep(0.5)

            for way = 1, numWays do
                local x = startX + (way - 1) * tileWidth
                local color = (way == safeWay) and colors.lime or colors.red

                Tower.ui.drawBox(x, y, tileWidth - 1, 2, color)

                sleep(0.2)
            end

            sleep(1)

            if chosenWay == safeWay then
                -- Richtig!
                currentLevel = currentLevel + 1

                if currentLevel >= numLevels then
                    -- Alle Levels geschafft!
                    local payout = math.floor(bet * (1.0 + (numLevels * 0.5)))
                    Tower.ui.clear()
                    Tower.ui.drawTitle("TOWER - TOP!")
                    Tower.ui.centerText(10, "Alle Levels geschafft!", colors.lime)
                    Tower.ui.centerText(12, "Gewinn: " .. payout, colors.yellow)
                    sleep(3)
                    return true, payout
                end
            else
                -- Falsch!
                Tower.ui.clear()
                Tower.ui.drawTitle("TOWER - GEFALLEN!")
                Tower.ui.centerText(10, "Falscher Weg!", colors.red)
                Tower.ui.centerText(12, "Erreicht: Level " .. currentLevel, colors.white)
                sleep(3)
                return false, 0
            end
        end
    end
end

return Tower

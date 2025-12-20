-- Mines (Minesweeper Casino)
local Mines = {}

-- Initialisierung
function Mines.init(ui, inventory)
    Mines.ui = ui
    Mines.inventory = inventory
    return Mines
end

-- Haupt-Spiel-Loop
function Mines.play(playerName, playerBalance)
    while true do
        -- Einsatz wählen
        local bet = Mines.selectBet(playerBalance)
        if bet == 0 then
            return playerBalance
        end

        if bet > playerBalance then
            Mines.ui.clear()
            Mines.ui.drawTitle("MINES")
            Mines.ui.centerText(10, "Nicht genug Diamanten!", colors.red)
            sleep(2)
        else
            -- Anzahl Minen wählen
            local numMines = Mines.selectMineCount()
            if not numMines then
                -- Zurück
            else
                -- Spiel starten
                local won, payout = Mines.playRound(bet, numMines)

                -- Balance aktualisieren
                if won then
                    playerBalance = playerBalance + payout
                else
                    playerBalance = playerBalance - bet
                end

                -- Ergebnis anzeigen
                Mines.ui.showResult(won, won and payout or bet)

                if playerBalance <= 0 then
                    Mines.ui.clear()
                    Mines.ui.drawTitle("GAME OVER")
                    Mines.ui.centerText(10, "Keine Diamanten mehr!", colors.red)
                    sleep(3)
                    return 0
                end
            end
        end
    end
end

-- Einsatz wählen
function Mines.selectBet(maxBet)
    local result = Mines.ui.selectAmount(
        "MINES - Einsatz waehlen",
        1,
        maxBet
    )
    return result[1].amount
end

-- Anzahl Minen wählen
function Mines.selectMineCount()
    Mines.ui.clear()
    Mines.ui.drawTitle("MINES - Schwierigkeit")

    local options = {
        {text = "3 Minen (Einfach)", mines = 3, color = colors.lime},
        {text = "5 Minen (Mittel)", mines = 5, color = colors.yellow},
        {text = "7 Minen (Schwer)", mines = 7, color = colors.orange},
        {text = "10 Minen (Extrem)", mines = 10, color = colors.red},
        {text = "Zurueck", mines = nil, color = colors.red}
    }

    local buttons = Mines.ui.drawMenu("", options, 8)
    local choice, button = Mines.ui.waitForTouch(buttons)

    if choice == #buttons then
        return nil
    end

    return options[choice].mines
end

-- Eine Runde spielen
function Mines.playRound(bet, numMines)
    local gridSize = 5  -- 5x5 Grid = 25 Felder
    local totalFields = gridSize * gridSize
    local safeFields = totalFields - numMines

    -- Minen-Positionen generieren (effiziente Set-basierte Methode)
    local minePositions = {}
    local mineSet = {}  -- Set für O(1) Lookup

    while #minePositions < numMines do
        local pos = math.random(totalFields)
        if not mineSet[pos] then
            table.insert(minePositions, pos)
            mineSet[pos] = true
        end
    end

    -- Spielfeld-Status
    local revealed = {}
    local numRevealed = 0
    local hitMine = false

    while not hitMine do
        Mines.ui.clear()
        Mines.ui.drawTitle("MINES")

        -- Info
        local currentMultiplier = Mines.calculateMultiplier(numRevealed, safeFields)
        Mines.ui.centerText(3, "Einsatz: " .. bet .. " | Minen: " .. numMines, colors.yellow)
        Mines.ui.centerText(4, "Aufgedeckt: " .. numRevealed .. "/" .. safeFields, colors.lime)
        Mines.ui.centerText(5, "Multiplikator: " .. string.format("%.2fx", currentMultiplier), colors.orange)

        -- Grid zeichnen
        local buttons = {}
        local cellSize = 6
        local spacing = 1
        local startX = math.floor((Mines.ui.width - (gridSize * cellSize + (gridSize - 1) * spacing)) / 2)
        local startY = 8

        for row = 0, gridSize - 1 do
            for col = 0, gridSize - 1 do
                local pos = row * gridSize + col + 1
                local x = startX + col * (cellSize + spacing)
                local y = startY + row * (cellSize + spacing)

                local isRevealed = revealed[pos]

                if isRevealed then
                    -- Aufgedeckt - sicheres Feld
                    Mines.ui.drawBox(x, y, cellSize, cellSize - 1, colors.lime)
                    Mines.ui.monitor.setCursorPos(x + 2, y + 2)
                    Mines.ui.monitor.setTextColor(colors.white)
                    Mines.ui.monitor.setBackgroundColor(colors.lime)
                    Mines.ui.monitor.write("OK")
                else
                    -- Verdeckt
                    local button = Mines.ui.drawButton(
                        x, y, cellSize, cellSize - 1,
                        "?",
                        colors.gray,
                        colors.white
                    )
                    button.position = pos
                    table.insert(buttons, button)
                end
            end
        end

        -- Cashout Button (wenn mindestens 1 aufgedeckt)
        if numRevealed > 0 then
            local cashoutButton = Mines.ui.drawButton(
                math.floor(Mines.ui.width / 2) - 12,
                startY + gridSize * (cellSize + spacing) + 2,
                25, 3,
                "CASHOUT",
                colors.yellow,
                colors.black
            )
            cashoutButton.position = -1
            table.insert(buttons, cashoutButton)
        end

        -- Zurück Button
        local backButton = Mines.ui.drawButton(
            math.floor(Mines.ui.width / 2) + 15,
            startY + gridSize * (cellSize + spacing) + 2,
            12, 3,
            "Aufgeben",
            colors.red,
            colors.white
        )
        backButton.position = -2
        table.insert(buttons, backButton)

        local choice, button = Mines.ui.waitForTouch(buttons)

        if button.position == -1 then
            -- Cashout
            local payout = math.floor(bet * currentMultiplier)
            return true, payout
        elseif button.position == -2 then
            -- Aufgeben
            return false, 0
        else
            -- Feld aufdecken
            local selectedPos = button.position

            -- Prüfen ob Mine
            local isMine = false
            for _, minePos in ipairs(minePositions) do
                if minePos == selectedPos then
                    isMine = true
                    break
                end
            end

            if isMine then
                -- Mine getroffen!
                hitMine = true

                Mines.ui.clear()
                Mines.ui.drawTitle("MINES - BOOM!")

                -- Alle Felder aufdecken
                local startX = math.floor((Mines.ui.width - (gridSize * cellSize + (gridSize - 1) * spacing)) / 2)
                local startY = 8

                for row = 0, gridSize - 1 do
                    for col = 0, gridSize - 1 do
                        local pos = row * gridSize + col + 1
                        local x = startX + col * (cellSize + spacing)
                        local y = startY + row * (cellSize + spacing)

                        local isMinePos = false
                        for _, minePos in ipairs(minePositions) do
                            if minePos == pos then
                                isMinePos = true
                                break
                            end
                        end

                        if isMinePos then
                            Mines.ui.drawBox(x, y, cellSize, cellSize - 1, colors.red)
                            Mines.ui.monitor.setCursorPos(x + 2, y + 2)
                            Mines.ui.monitor.setTextColor(colors.white)
                            Mines.ui.monitor.setBackgroundColor(colors.red)
                            Mines.ui.monitor.write("X")
                        else
                            Mines.ui.drawBox(x, y, cellSize, cellSize - 1, colors.lime)
                        end
                    end
                end

                Mines.ui.centerText(startY + gridSize * (cellSize + spacing) + 3, "MINE GETROFFEN!", colors.red)
                sleep(3)
                return false, 0
            else
                -- Sicheres Feld!
                revealed[selectedPos] = true
                numRevealed = numRevealed + 1

                -- Alle sicheren Felder aufgedeckt?
                if numRevealed >= safeFields then
                    local payout = math.floor(bet * Mines.calculateMultiplier(numRevealed, safeFields))
                    Mines.ui.clear()
                    Mines.ui.drawTitle("MINES - PERFEKT!")
                    Mines.ui.centerText(10, "Alle sicheren Felder gefunden!", colors.lime)
                    Mines.ui.centerText(12, "Gewinn: " .. payout, colors.yellow)
                    sleep(3)
                    return true, payout
                end
            end
        end
    end
end

-- Multiplikator berechnen
function Mines.calculateMultiplier(revealed, safeFields)
    if revealed == 0 then
        return 1.0
    end

    -- Exponentielles Wachstum
    local baseMultiplier = 1.2
    return baseMultiplier ^ revealed
end

return Mines

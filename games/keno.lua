-- Keno (Zahlen-Lotterie)
local Keno = {}

-- Initialisierung
function Keno.init(ui, inventory)
    Keno.ui = ui
    Keno.inventory = inventory
    return Keno
end

-- Haupt-Spiel-Loop
function Keno.play(playerName, playerBalance)
    while true do
        -- Einsatz wählen
        local bet = Keno.selectBet(playerBalance)
        if bet == 0 then
            return playerBalance
        end

        if bet > playerBalance then
            Keno.ui.clear()
            Keno.ui.drawTitle("KENO")
            Keno.ui.centerText(10, "Nicht genug Diamanten!", colors.red)
            sleep(2)
        else
            -- Anzahl Zahlen wählen
            local numPicks = Keno.selectNumberCount()
            if not numPicks then
                -- Zurück
            else
                -- Zahlen auswählen
                local playerNumbers = Keno.selectNumbers(numPicks)
                if not playerNumbers then
                    -- Zurück
                else
                    -- Spiel starten
                    local won, payout = Keno.draw(bet, playerNumbers, numPicks)

                    -- Balance aktualisieren
                    if won then
                        playerBalance = playerBalance + payout
                    else
                        playerBalance = playerBalance - bet
                    end

                    -- Ergebnis anzeigen
                    Keno.ui.showResult(won, won and payout or bet)

                    if playerBalance <= 0 then
                        Keno.ui.clear()
                        Keno.ui.drawTitle("GAME OVER")
                        Keno.ui.centerText(10, "Keine Diamanten mehr!", colors.red)
                        sleep(3)
                        return 0
                    end
                end
            end
        end
    end
end

-- Einsatz wählen
function Keno.selectBet(maxBet)
    local result = Keno.ui.selectAmount(
        "KENO - Einsatz waehlen",
        1,
        maxBet
    )
    return result[1].amount
end

-- Anzahl Zahlen wählen
function Keno.selectNumberCount()
    Keno.ui.clear()
    Keno.ui.drawTitle("KENO - Wie viele Zahlen?")

    local options = {
        {text = "3 Zahlen waehlen", count = 3, color = colors.lime},
        {text = "5 Zahlen waehlen", count = 5, color = colors.blue},
        {text = "7 Zahlen waehlen", count = 7, color = colors.orange},
        {text = "10 Zahlen waehlen", count = 10, color = colors.purple},
        {text = "Zurueck", count = nil, color = colors.red}
    }

    local buttons = Keno.ui.drawMenu("", options, 8)
    local choice, button = Keno.ui.waitForTouch(buttons)

    if choice == #buttons then
        return nil
    end

    return options[choice].count
end

-- Zahlen auswählen
function Keno.selectNumbers(numPicks)
    local selected = {}

    while #selected < numPicks do
        Keno.ui.clear()
        Keno.ui.drawTitle("KENO - Zahlen waehlen")
        Keno.ui.centerText(4, "Waehle " .. numPicks .. " Zahlen (1-40)", colors.white)
        Keno.ui.centerText(5, "Gewaehlt: " .. #selected .. "/" .. numPicks, colors.yellow)

        -- Zeige gewählte Zahlen
        if #selected > 0 then
            local selectedStr = ""
            for i, num in ipairs(selected) do
                selectedStr = selectedStr .. num
                if i < #selected then selectedStr = selectedStr .. ", " end
            end
            Keno.ui.centerText(6, selectedStr, colors.lime)
        end

        local buttons = {}
        local cols = 8
        local buttonSize = 4
        local spacingX = 1
        local spacingY = 1
        local startX = math.floor((Keno.ui.width - (cols * buttonSize + (cols - 1) * spacingX)) / 2)
        local startY = 9

        -- Zahlen 1-40
        for num = 1, 40 do
            local row = math.floor((num - 1) / cols)
            local col = (num - 1) % cols
            local x = startX + col * (buttonSize + spacingX)
            local y = startY + row * (buttonSize + spacingY)

            -- Prüfen ob bereits gewählt
            local isSelected = false
            for _, selected_num in ipairs(selected) do
                if selected_num == num then
                    isSelected = true
                    break
                end
            end

            local bgColor = isSelected and colors.lime or colors.blue
            local button = Keno.ui.drawButton(
                x, y, buttonSize, buttonSize - 1,
                tostring(num),
                bgColor,
                colors.white
            )
            button.number = num
            button.isSelected = isSelected
            table.insert(buttons, button)
        end

        -- Bestätigen Button (wenn genug gewählt)
        if #selected == numPicks then
            local confirmButton = Keno.ui.drawButton(
                math.floor(Keno.ui.width / 2) - 12,
                startY + 7 * (buttonSize + spacingY),
                25, 3,
                "Bestaetigen",
                colors.green,
                colors.white
            )
            confirmButton.number = -1
            table.insert(buttons, confirmButton)
        end

        -- Zurück Button
        local backButton = Keno.ui.drawButton(
            math.floor(Keno.ui.width / 2) + 14,
            startY + 7 * (buttonSize + spacingY),
            12, 3,
            "Zurueck",
            colors.red,
            colors.white
        )
        backButton.number = -2
        table.insert(buttons, backButton)

        local choice, button = Keno.ui.waitForTouch(buttons)

        if button.number == -2 then
            return nil  -- Zurück
        elseif button.number == -1 then
            return selected  -- Bestätigen
        elseif button.isSelected then
            -- Abwählen
            for i, num in ipairs(selected) do
                if num == button.number then
                    table.remove(selected, i)
                    break
                end
            end
        elseif #selected < numPicks then
            -- Hinzufügen
            table.insert(selected, button.number)
        end
    end

    return selected
end

-- Ziehung durchführen
function Keno.draw(bet, playerNumbers, numPicks)
    Keno.ui.clear()
    Keno.ui.drawTitle("KENO - Ziehung")

    -- Spieler Zahlen anzeigen
    local playerStr = ""
    for i, num in ipairs(playerNumbers) do
        playerStr = playerStr .. num
        if i < #playerNumbers then playerStr = playerStr .. ", " end
    end
    Keno.ui.centerText(4, "Deine Zahlen:", colors.white)
    Keno.ui.centerText(5, playerStr, colors.lime)

    sleep(2)

    -- 20 Zahlen ziehen
    local drawnNumbers = {}
    local allNumbers = {}
    for i = 1, 40 do
        table.insert(allNumbers, i)
    end

    -- Ziehe 20 zufällige Zahlen
    for i = 1, 20 do
        local index = math.random(#allNumbers)
        table.insert(drawnNumbers, table.remove(allNumbers, index))
    end

    -- Animation der Ziehung
    Keno.ui.centerText(8, "Gezogene Zahlen:", colors.yellow)

    local displayY = 10
    local displayX = 5
    local count = 0

    for i, num in ipairs(drawnNumbers) do
        -- Prüfen ob Treffer
        local isHit = false
        for _, playerNum in ipairs(playerNumbers) do
            if playerNum == num then
                isHit = true
                break
            end
        end

        local color = isHit and colors.lime or colors.white
        local bgColor = isHit and colors.green or colors.gray

        Keno.ui.drawBox(displayX, displayY, 4, 2, bgColor)
        Keno.ui.monitor.setCursorPos(displayX + 1, displayY + 1)
        Keno.ui.monitor.setTextColor(color)
        Keno.ui.monitor.setBackgroundColor(bgColor)
        Keno.ui.monitor.write(tostring(num))

        displayX = displayX + 5
        count = count + 1

        if count >= 10 then
            count = 0
            displayX = 5
            displayY = displayY + 3
        end

        sleep(0.15)
    end

    sleep(1)

    -- Treffer zählen
    local hits = 0
    for _, playerNum in ipairs(playerNumbers) do
        for _, drawnNum in ipairs(drawnNumbers) do
            if playerNum == drawnNum then
                hits = hits + 1
                break
            end
        end
    end

    -- Gewinn berechnen
    local payoutTable = {
        [3] = {[2] = 2, [3] = 10},
        [5] = {[3] = 2, [4] = 5, [5] = 20},
        [7] = {[4] = 3, [5] = 10, [6] = 50, [7] = 100},
        [10] = {[5] = 5, [6] = 15, [7] = 40, [8] = 100, [9] = 250, [10] = 500}
    }

    local multiplier = 0
    if payoutTable[numPicks] and payoutTable[numPicks][hits] then
        multiplier = payoutTable[numPicks][hits]
    end

    local won = multiplier > 0
    local payout = won and (bet * multiplier) or 0

    -- Ergebnis anzeigen
    Keno.ui.centerText(displayY + 2, "Treffer: " .. hits .. "/" .. numPicks, colors.white)

    if won then
        Keno.ui.centerText(displayY + 4, "GEWONNEN! " .. multiplier .. "x", colors.lime)
    else
        Keno.ui.centerText(displayY + 4, "VERLOREN!", colors.red)
    end

    sleep(3)
    return won, payout
end

return Keno

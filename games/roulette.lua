-- Roulette
local Roulette = {}

-- Roulette Zahlen mit Farben
local numbers = {
    [0] = {num = 0, color = "green"},
    [1] = {num = 1, color = "red"},
    [2] = {num = 2, color = "black"},
    [3] = {num = 3, color = "red"},
    [4] = {num = 4, color = "black"},
    [5] = {num = 5, color = "red"},
    [6] = {num = 6, color = "black"},
    [7] = {num = 7, color = "red"},
    [8] = {num = 8, color = "black"},
    [9] = {num = 9, color = "red"},
    [10] = {num = 10, color = "black"},
    [11] = {num = 11, color = "black"},
    [12] = {num = 12, color = "red"},
    [13] = {num = 13, color = "black"},
    [14] = {num = 14, color = "red"},
    [15] = {num = 15, color = "black"},
    [16] = {num = 16, color = "red"},
    [17] = {num = 17, color = "black"},
    [18] = {num = 18, color = "red"},
    [19] = {num = 19, color = "red"},
    [20] = {num = 20, color = "black"},
    [21] = {num = 21, color = "red"},
    [22] = {num = 22, color = "black"},
    [23] = {num = 23, color = "red"},
    [24] = {num = 24, color = "black"},
    [25] = {num = 25, color = "red"},
    [26] = {num = 26, color = "black"},
    [27] = {num = 27, color = "red"},
    [28] = {num = 28, color = "black"},
    [29] = {num = 29, color = "black"},
    [30] = {num = 30, color = "red"},
    [31] = {num = 31, color = "black"},
    [32] = {num = 32, color = "red"},
    [33] = {num = 33, color = "black"},
    [34] = {num = 34, color = "red"},
    [35] = {num = 35, color = "black"},
    [36] = {num = 36, color = "red"}
}

-- Initialisierung
function Roulette.init(ui, inventory)
    Roulette.ui = ui
    Roulette.inventory = inventory
    return Roulette
end

-- Haupt-Spiel-Loop
function Roulette.play(playerName, playerBalance)
    while true do
        -- Einsatz wählen
        local bet = Roulette.selectBet(playerBalance)
        if bet == 0 then
            return playerBalance
        end

        if bet > playerBalance then
            Roulette.ui.clear()
            Roulette.ui.drawTitle("ROULETTE")
            Roulette.ui.centerText(10, "Nicht genug Diamanten!", colors.red)
            sleep(2)
        else
            -- Wett-Typ wählen
            local betType, betValue = Roulette.selectBetType()
            if not betType then
                -- Zurück wurde gedrückt
            else
                -- Spiel starten
                local won, payout = Roulette.spin(bet, betType, betValue)

                -- Balance aktualisieren
                if won then
                    playerBalance = playerBalance + payout
                else
                    playerBalance = playerBalance - bet
                end

                -- Ergebnis anzeigen
                Roulette.ui.showResult(won, won and payout or bet)

                -- Prüfen ob Spieler pleite ist
                if playerBalance <= 0 then
                    Roulette.ui.clear()
                    Roulette.ui.drawTitle("GAME OVER")
                    Roulette.ui.centerText(10, "Keine Diamanten mehr!", colors.red)
                    Roulette.ui.centerText(12, "Bitte Diamanten nachtanken.", colors.white)
                    sleep(3)
                    return 0
                end
            end
        end
    end
end

-- Einsatz wählen
function Roulette.selectBet(maxBet)
    local buttons = Roulette.ui.selectAmount(
        "ROULETTE - Einsatz waehlen",
        1,
        math.min(10, maxBet)
    )

    local choice, button = Roulette.ui.waitForTouch(buttons)
    return button.amount
end

-- Wett-Typ auswählen
function Roulette.selectBetType()
    local options = {
        {text = "ROT (2x)", color = colors.red, type = "color", value = "red", payout = 2},
        {text = "SCHWARZ (2x)", color = colors.gray, type = "color", value = "black", payout = 2},
        {text = "GERADE (2x)", color = colors.blue, type = "even", value = true, payout = 2},
        {text = "UNGERADE (2x)", color = colors.orange, type = "odd", value = true, payout = 2},
        {text = "1-18 (2x)", color = colors.purple, type = "low", value = true, payout = 2},
        {text = "19-36 (2x)", color = colors.lime, type = "high", value = true, payout = 2},
        {text = "Spez. Zahl (36x)", color = colors.yellow, type = "number", value = nil, payout = 36},
        {text = "Zurueck", color = colors.red}
    }

    local buttons = Roulette.ui.drawMenu("ROULETTE - Wette waehlen", options, 5)

    local choice, button = Roulette.ui.waitForTouch(buttons)

    if choice == #buttons then
        return nil, nil -- Zurück
    end

    local option = options[choice]

    -- Wenn spezifische Zahl, dann Zahlen-Auswahl
    if option.type == "number" then
        local number = Roulette.selectNumber()
        if number == nil then
            return nil, nil -- Zurück
        end
        return option.type, number, option.payout
    end

    return option.type, option.value, option.payout
end

-- Spezifische Zahl auswählen
function Roulette.selectNumber()
    Roulette.ui.clear()
    Roulette.ui.drawTitle("ROULETTE - Zahl waehlen")

    local buttons = {}
    local cols = 7
    local buttonSize = 5
    local spacingX = 2
    local spacingY = 1
    local startX = math.floor((Roulette.ui.width - (cols * buttonSize + (cols - 1) * spacingX)) / 2)
    local startY = 6

    -- Zahlen 0-36
    for num = 0, 36 do
        local row = math.floor(num / cols)
        local col = num % cols
        local x = startX + col * (buttonSize + spacingX)
        local y = startY + row * (buttonSize + spacingY)

        local numData = numbers[num]
        local bgColor = numData.color == "red" and colors.red or
                       (numData.color == "black" and colors.gray or colors.green)

        local button = Roulette.ui.drawButton(
            x, y, buttonSize, buttonSize - 1,
            tostring(num),
            bgColor,
            colors.white
        )
        button.number = num
        table.insert(buttons, button)
    end

    -- Zurück-Button
    local backButton = Roulette.ui.drawButton(
        math.floor(Roulette.ui.width / 2) - 10,
        startY + 7 * (buttonSize + spacingY),
        20, 3,
        "Zurueck",
        colors.red,
        colors.white
    )
    backButton.number = nil
    table.insert(buttons, backButton)

    local choice, button = Roulette.ui.waitForTouch(buttons)
    return button.number
end

-- Rad drehen
function Roulette.spin(bet, betType, betValue, betPayout)
    Roulette.ui.clear()
    Roulette.ui.drawTitle("ROULETTE")

    -- Einsatz anzeigen
    Roulette.ui.centerText(4, "Einsatz: " .. bet .. " Diamanten", colors.yellow)

    local betText = ""
    if betType == "color" then
        betText = betValue == "red" and "ROT" or "SCHWARZ"
    elseif betType == "even" then
        betText = "GERADE"
    elseif betType == "odd" then
        betText = "UNGERADE"
    elseif betType == "low" then
        betText = "1-18"
    elseif betType == "high" then
        betText = "19-36"
    elseif betType == "number" then
        betText = "Zahl: " .. betValue
    end

    Roulette.ui.centerText(5, "Wette: " .. betText, colors.white)

    -- Animation
    local centerX = math.floor(Roulette.ui.width / 2)
    local centerY = math.floor(Roulette.ui.height / 2)

    Roulette.ui.centerText(centerY - 2, "Rad dreht sich...", colors.white)

    -- Simuliere Rad-Drehung
    for i = 1, 20 do
        local tempNum = math.random(0, 36)
        local tempData = numbers[tempNum]
        local displayColor = tempData.color == "red" and colors.red or
                            (tempData.color == "black" and colors.gray or colors.green)

        Roulette.ui.drawBox(centerX - 5, centerY, 10, 5, displayColor)
        Roulette.ui.centerText(centerY + 2, tostring(tempNum), colors.white, displayColor)

        sleep(0.1 + (i * 0.02)) -- Wird langsamer
    end

    -- Finales Ergebnis
    local result = math.random(0, 36)
    local resultData = numbers[result]
    local resultColor = resultData.color == "red" and colors.red or
                       (resultData.color == "black" and colors.gray or colors.green)

    Roulette.ui.drawBox(centerX - 5, centerY, 10, 5, resultColor)
    Roulette.ui.centerText(centerY + 2, tostring(result), colors.white, resultColor)

    sleep(1)

    -- Gewinn prüfen
    local won = Roulette.checkWin(betType, betValue, result)
    local payout = won and (bet * betPayout) or 0

    -- Ergebnis anzeigen
    Roulette.ui.centerText(centerY + 5, won and "GEWONNEN!" or "VERLOREN!",
                          won and colors.lime or colors.red)

    sleep(2)
    return won, payout
end

-- Gewinn prüfen
function Roulette.checkWin(betType, betValue, result)
    local resultData = numbers[result]

    if betType == "color" then
        return resultData.color == betValue
    elseif betType == "even" then
        return result > 0 and result % 2 == 0
    elseif betType == "odd" then
        return result > 0 and result % 2 == 1
    elseif betType == "low" then
        return result >= 1 and result <= 18
    elseif betType == "high" then
        return result >= 19 and result <= 36
    elseif betType == "number" then
        return result == betValue
    end

    return false
end

return Roulette

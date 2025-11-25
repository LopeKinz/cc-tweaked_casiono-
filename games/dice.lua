-- Dice (Würfel)
local Dice = {}

-- Würfel-Punkte Muster
local diceDots = {
    [1] = {{2, 2}},
    [2] = {{1, 1}, {3, 3}},
    [3] = {{1, 1}, {2, 2}, {3, 3}},
    [4] = {{1, 1}, {1, 3}, {3, 1}, {3, 3}},
    [5] = {{1, 1}, {1, 3}, {2, 2}, {3, 1}, {3, 3}},
    [6] = {{1, 1}, {1, 2}, {1, 3}, {3, 1}, {3, 2}, {3, 3}}
}

-- Initialisierung
function Dice.init(ui, inventory)
    Dice.ui = ui
    Dice.inventory = inventory
    return Dice
end

-- Haupt-Spiel-Loop
function Dice.play(playerName, playerBalance)
    while true do
        -- Einsatz wählen
        local bet = Dice.selectBet(playerBalance)
        if bet == 0 then
            return playerBalance
        end

        if bet > playerBalance then
            Dice.ui.clear()
            Dice.ui.drawTitle("DICE")
            Dice.ui.centerText(10, "Nicht genug Diamanten!", colors.red)
            sleep(2)
        else
            -- Wett-Typ wählen
            local betType = Dice.selectBetType()
            if not betType then
                -- Zurück
            else
                -- Würfeln
                local won, payout = Dice.roll(bet, betType)

                -- Balance aktualisieren
                if won then
                    playerBalance = playerBalance + payout
                else
                    playerBalance = playerBalance - bet
                end

                -- Ergebnis anzeigen
                Dice.ui.showResult(won, won and payout or bet)

                -- Prüfen ob Spieler pleite ist
                if playerBalance <= 0 then
                    Dice.ui.clear()
                    Dice.ui.drawTitle("GAME OVER")
                    Dice.ui.centerText(10, "Keine Diamanten mehr!", colors.red)
                    Dice.ui.centerText(12, "Bitte Diamanten nachtanken.", colors.white)
                    sleep(3)
                    return 0
                end
            end
        end
    end
end

-- Einsatz wählen
function Dice.selectBet(maxBet)
    local result = Dice.ui.selectAmount(
        "DICE - Einsatz waehlen",
        1,
        maxBet
    )

    return result[1].amount
end

-- Wett-Typ auswählen
function Dice.selectBetType()
    local options = {
        {
            text = "Summe 7 oder 11 (3x)",
            type = "lucky",
            payout = 3,
            color = colors.lime
        },
        {
            text = "Summe gerade (2x)",
            type = "even",
            payout = 2,
            color = colors.blue
        },
        {
            text = "Summe ungerade (2x)",
            type = "odd",
            payout = 2,
            color = colors.orange
        },
        {
            text = "Summe > 7 (2x)",
            type = "high",
            payout = 2,
            color = colors.purple
        },
        {
            text = "Summe < 7 (2x)",
            type = "low",
            payout = 2,
            color = colors.pink
        },
        {
            text = "Beide gleich (5x)",
            type = "doubles",
            payout = 5,
            color = colors.yellow
        },
        {
            text = "Zurueck",
            type = nil,
            color = colors.red
        }
    }

    local buttons = Dice.ui.drawMenu("DICE - Wette waehlen", options, 4)

    local choice, button = Dice.ui.waitForTouch(buttons)

    if choice == #buttons then
        return nil
    end

    return options[choice]
end

-- Würfeln
function Dice.roll(bet, betType)
    Dice.ui.clear()
    Dice.ui.drawTitle("DICE")

    Dice.ui.centerText(4, "Einsatz: " .. bet .. " Diamanten", colors.yellow)
    Dice.ui.centerText(5, "Wette: " .. betType.text:sub(1, 30), colors.white)

    local die1X = math.floor(Dice.ui.width / 2) - 10
    local die2X = math.floor(Dice.ui.width / 2) + 3
    local dieY = 10

    -- Animation
    Dice.ui.centerText(dieY - 2, "Wuerfeln...", colors.white)

    for i = 1, 15 do
        local tempDie1 = math.random(1, 6)
        local tempDie2 = math.random(1, 6)

        Dice.drawDie(die1X, dieY, tempDie1)
        Dice.drawDie(die2X, dieY, tempDie2)

        sleep(0.05 + (i * 0.02))
    end

    -- Ergebnis
    local die1 = math.random(1, 6)
    local die2 = math.random(1, 6)
    local sum = die1 + die2

    Dice.drawDie(die1X, dieY, die1)
    Dice.drawDie(die2X, dieY, die2)

    sleep(1)

    -- Summe anzeigen
    Dice.ui.centerText(dieY + 10, "Summe: " .. sum, colors.white, colors.black)

    -- Gewinn prüfen
    local won = Dice.checkWin(betType.type, die1, die2, sum)
    local payout = won and (bet * betType.payout) or 0

    if won then
        Dice.ui.centerText(dieY + 12, "GEWONNEN!", colors.lime)
    else
        Dice.ui.centerText(dieY + 12, "VERLOREN!", colors.red)
    end

    sleep(2)

    return won, payout
end

-- Würfel zeichnen
function Dice.drawDie(x, y, value)
    local size = 7

    -- Hintergrund
    Dice.ui.drawBox(x, y, size, size, colors.white)
    Dice.ui.drawBorder(x, y, size, size, colors.gray)

    -- Punkte
    local dots = diceDots[value]
    for _, dot in ipairs(dots) do
        local dotX = x + dot[1] * 2
        local dotY = y + dot[2] * 2

        Dice.ui.monitor.setCursorPos(dotX, dotY)
        Dice.ui.monitor.setBackgroundColor(colors.black)
        Dice.ui.monitor.write(" ")
    end
end

-- Gewinn prüfen
function Dice.checkWin(betType, die1, die2, sum)
    if betType == "lucky" then
        return sum == 7 or sum == 11
    elseif betType == "even" then
        return sum % 2 == 0
    elseif betType == "odd" then
        return sum % 2 == 1
    elseif betType == "high" then
        return sum > 7
    elseif betType == "low" then
        return sum < 7
    elseif betType == "doubles" then
        return die1 == die2
    end

    return false
end

-- Spielregeln anzeigen
function Dice.showRules()
    Dice.ui.clear()
    Dice.ui.drawTitle("DICE - Spielregeln")

    local y = 5
    local rules = {
        "2 Wuerfel werden geworfen",
        "",
        "Wettoptionen:",
        "- Summe 7 oder 11: 3x",
        "- Summe gerade: 2x",
        "- Summe ungerade: 2x",
        "- Summe > 7: 2x",
        "- Summe < 7: 2x",
        "- Beide gleich (Pasch): 5x"
    }

    for _, rule in ipairs(rules) do
        Dice.ui.centerText(y, rule, colors.white)
        y = y + 1
    end

    y = y + 2
    local backButton = Dice.ui.drawButton(
        math.floor(Dice.ui.width / 2) - 10,
        y,
        20, 3,
        "Zurueck",
        colors.red,
        colors.white
    )

    Dice.ui.waitForTouch({backButton})
end

return Dice

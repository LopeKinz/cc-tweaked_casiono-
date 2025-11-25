-- High/Low (Kartenrate-Spiel)
local HighLow = {}

-- Karten-Werte
local cards = {
    {value = 1, name = "A"}, {value = 2, name = "2"}, {value = 3, name = "3"},
    {value = 4, name = "4"}, {value = 5, name = "5"}, {value = 6, name = "6"},
    {value = 7, name = "7"}, {value = 8, name = "8"}, {value = 9, name = "9"},
    {value = 10, name = "10"}, {value = 11, name = "J"}, {value = 12, name = "Q"},
    {value = 13, name = "K"}
}

-- Initialisierung
function HighLow.init(ui, inventory)
    HighLow.ui = ui
    HighLow.inventory = inventory
    return HighLow
end

-- Haupt-Spiel-Loop
function HighLow.play(playerName, playerBalance)
    while true do
        -- Einsatz wählen
        local bet = HighLow.selectBet(playerBalance)
        if bet == 0 then
            return playerBalance
        end

        if bet > playerBalance then
            HighLow.ui.clear()
            HighLow.ui.drawTitle("HIGH/LOW")
            HighLow.ui.centerText(10, "Nicht genug Diamanten!", colors.red)
            sleep(2)
        else
            -- Spiel starten
            local won, payout = HighLow.playRound(bet)

            -- Balance aktualisieren
            if won then
                playerBalance = playerBalance + payout
            else
                playerBalance = playerBalance - bet
            end

            -- Ergebnis anzeigen
            HighLow.ui.showResult(won, won and payout or bet)

            if playerBalance <= 0 then
                HighLow.ui.clear()
                HighLow.ui.drawTitle("GAME OVER")
                HighLow.ui.centerText(10, "Keine Diamanten mehr!", colors.red)
                sleep(3)
                return 0
            end
        end
    end
end

-- Einsatz wählen
function HighLow.selectBet(maxBet)
    local result = HighLow.ui.selectAmount(
        "HIGH/LOW - Einsatz waehlen",
        1,
        maxBet
    )
    return result[1].amount
end

-- Eine Runde spielen
function HighLow.playRound(bet)
    local currentCard = cards[math.random(#cards)]
    local streak = 0
    local currentMultiplier = 1.0

    while true do
        HighLow.ui.clear()
        HighLow.ui.drawTitle("HIGH/LOW")

        HighLow.ui.centerText(4, "Einsatz: " .. bet .. " Diamanten", colors.yellow)
        HighLow.ui.centerText(5, "Streak: " .. streak, colors.lime)
        HighLow.ui.centerText(6, "Multiplier: " .. string.format("%.1fx", currentMultiplier), colors.orange)

        -- Aktuelle Karte anzeigen
        HighLow.drawCard(math.floor(HighLow.ui.width / 2) - 3, 10, currentCard)

        HighLow.ui.centerText(17, "Ist die naechste Karte...", colors.white)

        -- Buttons
        local buttonY = 20

        local higherButton = HighLow.ui.drawButton(
            math.floor(HighLow.ui.width / 2) - 30,
            buttonY,
            18, 4,
            "HOEHER",
            colors.lime,
            colors.white
        )

        local lowerButton = HighLow.ui.drawButton(
            math.floor(HighLow.ui.width / 2) - 9,
            buttonY,
            18, 4,
            "NIEDRIGER",
            colors.red,
            colors.white
        )

        local cashoutButton = HighLow.ui.drawButton(
            math.floor(HighLow.ui.width / 2) + 12,
            buttonY,
            18, 4,
            "CASHOUT",
            colors.yellow,
            colors.black
        )

        -- Wenn erster Zug, Cashout deaktivieren
        local buttons = {}
        table.insert(buttons, higherButton)
        table.insert(buttons, lowerButton)

        if streak > 0 then
            table.insert(buttons, cashoutButton)
        end

        local choice, button = HighLow.ui.waitForTouch(buttons)

        -- Cashout?
        if button == cashoutButton then
            local payout = math.floor(bet * currentMultiplier)
            return true, payout
        end

        -- Nächste Karte ziehen
        local nextCard = cards[math.random(#cards)]

        -- Animation
        HighLow.ui.centerText(17, "Naechste Karte...", colors.orange)
        sleep(0.5)

        for i = 1, 5 do
            local tempCard = cards[math.random(#cards)]
            HighLow.drawCard(math.floor(HighLow.ui.width / 2) + 10, 10, tempCard)
            sleep(0.1)
        end

        HighLow.drawCard(math.floor(HighLow.ui.width / 2) + 10, 10, nextCard)
        sleep(1)

        -- Prüfen ob richtig geraten
        local guessedHigher = (button == higherButton)
        local isHigher = nextCard.value > currentCard.value
        local isEqual = nextCard.value == currentCard.value

        local correct = false
        if isEqual then
            -- Gleiche Karte = Push (weiter spielen)
            HighLow.ui.centerText(26, "GLEICH! Noch einmal!", colors.yellow)
            sleep(2)
            -- Nicht weitermachen, neue Karte ziehen
        elseif guessedHigher == isHigher then
            correct = true
        end

        if correct then
            -- Richtig geraten!
            streak = streak + 1
            currentMultiplier = currentMultiplier + 0.5
            currentCard = nextCard

            HighLow.ui.centerText(26, "RICHTIG!", colors.lime)
            sleep(1.5)
        else
            -- Falsch geraten!
            HighLow.ui.centerText(26, "FALSCH!", colors.red)
            sleep(2)
            return false, 0
        end
    end
end

-- Karte zeichnen
function HighLow.drawCard(x, y, card)
    local cardWidth = 7
    local cardHeight = 5

    -- Karten-Hintergrund
    HighLow.ui.drawBox(x, y, cardWidth, cardHeight, colors.white)
    HighLow.ui.drawBorder(x, y, cardWidth, cardHeight, colors.gray)

    -- Karten-Wert
    HighLow.ui.monitor.setCursorPos(x + 2, y + 2)
    HighLow.ui.monitor.setTextColor(colors.black)
    HighLow.ui.monitor.setBackgroundColor(colors.white)
    HighLow.ui.monitor.write(card.name)
end

return HighLow

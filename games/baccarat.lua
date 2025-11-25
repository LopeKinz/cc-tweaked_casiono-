-- Baccarat
local Baccarat = {}

-- Karten-Werte (Baccarat-System: 10,J,Q,K = 0)
local cards = {
    {value = 1, name = "A"}, {value = 2, name = "2"}, {value = 3, name = "3"},
    {value = 4, name = "4"}, {value = 5, name = "5"}, {value = 6, name = "6"},
    {value = 7, name = "7"}, {value = 8, name = "8"}, {value = 9, name = "9"},
    {value = 0, name = "10"}, {value = 0, name = "J"}, {value = 0, name = "Q"},
    {value = 0, name = "K"}
}

-- Initialisierung
function Baccarat.init(ui, inventory)
    Baccarat.ui = ui
    Baccarat.inventory = inventory
    return Baccarat
end

-- Haupt-Spiel-Loop
function Baccarat.play(playerName, playerBalance)
    while true do
        -- Einsatz wählen
        local bet = Baccarat.selectBet(playerBalance)
        if bet == 0 then
            return playerBalance
        end

        if bet > playerBalance then
            Baccarat.ui.clear()
            Baccarat.ui.drawTitle("BACCARAT")
            Baccarat.ui.centerText(10, "Nicht genug Diamanten!", colors.red)
            sleep(2)
        else
            -- Wette wählen
            local betType = Baccarat.selectBetType()
            if not betType then
                -- Zurück
            else
                -- Spiel starten
                local won, payout = Baccarat.playRound(bet, betType)

                -- Balance aktualisieren
                if won then
                    playerBalance = playerBalance + payout
                else
                    playerBalance = playerBalance - bet
                end

                -- Ergebnis anzeigen
                Baccarat.ui.showResult(won, won and payout or bet)

                if playerBalance <= 0 then
                    Baccarat.ui.clear()
                    Baccarat.ui.drawTitle("GAME OVER")
                    Baccarat.ui.centerText(10, "Keine Diamanten mehr!", colors.red)
                    sleep(3)
                    return 0
                end
            end
        end
    end
end

-- Einsatz wählen
function Baccarat.selectBet(maxBet)
    local result = Baccarat.ui.selectAmount(
        "BACCARAT - Einsatz waehlen",
        1,
        maxBet
    )
    return result[1].amount
end

-- Wett-Typ wählen
function Baccarat.selectBetType()
    Baccarat.ui.clear()
    Baccarat.ui.drawTitle("BACCARAT - Wette")

    local options = {
        {text = "PLAYER (2x)", type = "player", payout = 2, color = colors.blue},
        {text = "BANKER (1.95x)", type = "banker", payout = 1.95, color = colors.red},
        {text = "TIE (8x)", type = "tie", payout = 8, color = colors.yellow},
        {text = "Zurueck", type = nil, color = colors.red}
    }

    local buttons = Baccarat.ui.drawMenu("", options, 10)
    local choice, button = Baccarat.ui.waitForTouch(buttons)

    if choice == #buttons then
        return nil
    end

    return options[choice]
end

-- Eine Runde spielen
function Baccarat.playRound(bet, betType)
    Baccarat.ui.clear()
    Baccarat.ui.drawTitle("BACCARAT")

    Baccarat.ui.centerText(4, "Wette: " .. betType.text, colors.white)
    Baccarat.ui.centerText(5, "Einsatz: " .. bet, colors.yellow)

    sleep(1)

    -- Karten austeilen
    local playerHand = {
        cards[math.random(#cards)],
        cards[math.random(#cards)]
    }

    local bankerHand = {
        cards[math.random(#cards)],
        cards[math.random(#cards)]
    }

    -- Werte berechnen
    local playerValue = Baccarat.calculateValue(playerHand)
    local bankerValue = Baccarat.calculateValue(bankerHand)

    -- Hände anzeigen
    Baccarat.ui.centerText(8, "PLAYER", colors.blue)
    Baccarat.drawHand(10, playerHand, playerValue)

    sleep(1)

    Baccarat.ui.centerText(16, "BANKER", colors.red)
    Baccarat.drawHand(18, bankerHand, bankerValue)

    sleep(2)

    -- Dritte Karte Regeln (vereinfacht)
    if playerValue < 6 and bankerValue < 6 then
        Baccarat.ui.centerText(26, "Dritte Karte...", colors.white)
        sleep(1)

        if playerValue < 6 then
            table.insert(playerHand, cards[math.random(#cards)])
            playerValue = Baccarat.calculateValue(playerHand)
        end

        if bankerValue < 6 then
            table.insert(bankerHand, cards[math.random(#cards)])
            bankerValue = Baccarat.calculateValue(bankerHand)
        end

        -- Neu zeichnen
        Baccarat.ui.clear()
        Baccarat.ui.drawTitle("BACCARAT")

        Baccarat.ui.centerText(8, "PLAYER", colors.blue)
        Baccarat.drawHand(10, playerHand, playerValue)

        Baccarat.ui.centerText(16, "BANKER", colors.red)
        Baccarat.drawHand(18, bankerHand, bankerValue)

        sleep(2)
    end

    -- Gewinner ermitteln
    local winner = ""
    if playerValue > bankerValue then
        winner = "player"
    elseif bankerValue > playerValue then
        winner = "banker"
    else
        winner = "tie"
    end

    -- Ergebnis
    Baccarat.ui.centerText(26, "Gewinner: " .. string.upper(winner), colors.yellow)
    sleep(2)

    if winner == betType.type then
        local payout = math.floor(bet * betType.payout)
        return true, payout
    else
        return false, 0
    end
end

-- Hand-Wert berechnen (Baccarat: Modulo 10)
function Baccarat.calculateValue(hand)
    local total = 0
    for _, card in ipairs(hand) do
        total = total + card.value
    end
    return total % 10
end

-- Hand zeichnen
function Baccarat.drawHand(startY, hand, value)
    local cardWidth = 7
    local spacing = 2
    local totalWidth = #hand * cardWidth + (#hand - 1) * spacing
    local startX = math.floor((Baccarat.ui.width - totalWidth) / 2)

    for i, card in ipairs(hand) do
        local x = startX + (i - 1) * (cardWidth + spacing)

        Baccarat.ui.drawBox(x, startY, cardWidth, 5, colors.white)
        Baccarat.ui.drawBorder(x, startY, cardWidth, 5, colors.gray)

        Baccarat.ui.monitor.setCursorPos(x + 2, startY + 2)
        Baccarat.ui.monitor.setTextColor(colors.black)
        Baccarat.ui.monitor.setBackgroundColor(colors.white)
        Baccarat.ui.monitor.write(card.name)
    end

    -- Wert anzeigen
    Baccarat.ui.centerText(startY + 6, "Wert: " .. value, colors.white)
end

return Baccarat

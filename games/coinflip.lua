-- Coin Flip (Münzwurf)
local CoinFlip = {}

-- Initialisierung
function CoinFlip.init(ui, inventory)
    CoinFlip.ui = ui
    CoinFlip.inventory = inventory
    return CoinFlip
end

-- Haupt-Spiel-Loop
function CoinFlip.play(playerName, playerBalance)
    while true do
        -- Einsatz wählen
        local bet = CoinFlip.selectBet(playerBalance)
        if bet == 0 then
            return playerBalance
        end

        if bet > playerBalance then
            CoinFlip.ui.clear()
            CoinFlip.ui.drawTitle("COIN FLIP")
            CoinFlip.ui.centerText(10, "Nicht genug Diamanten!", colors.red)
            sleep(2)
        else
            -- Seite wählen
            local choice = CoinFlip.selectSide()
            if not choice then
                -- Zurück
            else
                -- Münze werfen
                local won, payout = CoinFlip.flip(bet, choice)

                -- Balance aktualisieren
                if won then
                    playerBalance = playerBalance + payout
                else
                    playerBalance = playerBalance - bet
                end

                -- Ergebnis anzeigen
                CoinFlip.ui.showResult(won, won and payout or bet)

                -- Prüfen ob Spieler pleite ist
                if playerBalance <= 0 then
                    CoinFlip.ui.clear()
                    CoinFlip.ui.drawTitle("GAME OVER")
                    CoinFlip.ui.centerText(10, "Keine Diamanten mehr!", colors.red)
                    CoinFlip.ui.centerText(12, "Bitte Diamanten nachtanken.", colors.white)
                    sleep(3)
                    return 0
                end
            end
        end
    end
end

-- Einsatz wählen
function CoinFlip.selectBet(maxBet)
    local result = CoinFlip.ui.selectAmount(
        "COIN FLIP - Einsatz waehlen",
        1,
        maxBet
    )

    return result[1].amount
end

-- Seite wählen
function CoinFlip.selectSide()
    CoinFlip.ui.clear()
    CoinFlip.ui.drawTitle("COIN FLIP - Seite waehlen")

    CoinFlip.ui.centerText(8, "Kopf oder Zahl?", colors.white)
    CoinFlip.ui.centerText(10, "Gewinn: 2x Einsatz", colors.yellow)

    local buttons = {}

    -- Kopf Button
    local headsButton = CoinFlip.ui.drawButton(
        math.floor(CoinFlip.ui.width / 2) - 25,
        15,
        20, 8,
        "KOPF",
        colors.orange,
        colors.white
    )
    headsButton.side = "heads"
    table.insert(buttons, headsButton)

    -- Zahl Button
    local tailsButton = CoinFlip.ui.drawButton(
        math.floor(CoinFlip.ui.width / 2) + 5,
        15,
        20, 8,
        "ZAHL",
        colors.blue,
        colors.white
    )
    tailsButton.side = "tails"
    table.insert(buttons, tailsButton)

    -- Zurück Button
    local backButton = CoinFlip.ui.drawButton(
        math.floor(CoinFlip.ui.width / 2) - 10,
        26,
        20, 3,
        "Zurueck",
        colors.red,
        colors.white
    )
    backButton.side = nil
    table.insert(buttons, backButton)

    local choice, button = CoinFlip.ui.waitForTouch(buttons)
    return button.side
end

-- Münze werfen
function CoinFlip.flip(bet, playerChoice)
    CoinFlip.ui.clear()
    CoinFlip.ui.drawTitle("COIN FLIP")

    CoinFlip.ui.centerText(4, "Einsatz: " .. bet .. " Diamanten", colors.yellow)
    CoinFlip.ui.centerText(5, "Deine Wahl: " .. (playerChoice == "heads" and "KOPF" or "ZAHL"), colors.white)

    local centerX = math.floor(CoinFlip.ui.width / 2)
    local centerY = math.floor(CoinFlip.ui.height / 2)

    -- Animation
    CoinFlip.ui.centerText(centerY - 2, "Muenze wird geworfen...", colors.white)

    -- Flip-Animation
    local flipSteps = 15
    for i = 1, flipSteps do
        local side = (i % 2 == 0) and "heads" or "tails"
        CoinFlip.drawCoin(centerX, centerY, side)
        sleep(0.1 + (i * 0.02))
    end

    -- Ergebnis
    local result = math.random(2) == 1 and "heads" or "tails"

    -- Finale Münze zeigen
    CoinFlip.drawCoin(centerX, centerY, result)

    sleep(1)

    -- Text anzeigen
    CoinFlip.ui.centerText(centerY + 6, "Ergebnis: " .. (result == "heads" and "KOPF" or "ZAHL"),
                          colors.white)

    local won = result == playerChoice

    if won then
        CoinFlip.ui.centerText(centerY + 8, "DU GEWINNST!", colors.lime)
    else
        CoinFlip.ui.centerText(centerY + 8, "DU VERLIERST!", colors.red)
    end

    sleep(2)

    local payout = won and (bet * 2) or 0
    return won, payout
end

-- Münze zeichnen
function CoinFlip.drawCoin(centerX, centerY, side)
    local coinWidth = 12
    local coinHeight = 8
    local x = centerX - math.floor(coinWidth / 2)
    local y = centerY - math.floor(coinHeight / 2)

    local color = side == "heads" and colors.orange or colors.blue

    -- Münze
    CoinFlip.ui.drawBox(x, y, coinWidth, coinHeight, color)
    CoinFlip.ui.drawBorder(x, y, coinWidth, coinHeight, colors.yellow)

    -- Text
    local text = side == "heads" and "KOPF" or "ZAHL"
    CoinFlip.ui.monitor.setCursorPos(centerX - math.floor(#text / 2), centerY)
    CoinFlip.ui.monitor.setTextColor(colors.white)
    CoinFlip.ui.monitor.setBackgroundColor(color)
    CoinFlip.ui.monitor.write(text)

    -- Symbol
    local symbol = side == "heads" and "H" or "Z"
    CoinFlip.ui.monitor.setCursorPos(centerX, centerY + 2)
    CoinFlip.ui.monitor.setTextColor(colors.yellow)
    CoinFlip.ui.monitor.setBackgroundColor(color)
    CoinFlip.ui.monitor.write(symbol)
end

return CoinFlip

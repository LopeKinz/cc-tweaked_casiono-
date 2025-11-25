-- War (Kartenkrieg)
local War = {}

-- Karten
local cards = {
    {value = 2, name = "2"}, {value = 3, name = "3"}, {value = 4, name = "4"},
    {value = 5, name = "5"}, {value = 6, name = "6"}, {value = 7, name = "7"},
    {value = 8, name = "8"}, {value = 9, name = "9"}, {value = 10, name = "10"},
    {value = 11, name = "J"}, {value = 12, name = "Q"}, {value = 13, name = "K"},
    {value = 14, name = "A"}
}

-- Initialisierung
function War.init(ui, inventory)
    War.ui = ui
    War.inventory = inventory
    return War
end

-- Haupt-Spiel-Loop
function War.play(playerName, playerBalance)
    while true do
        -- Einsatz wählen
        local bet = War.selectBet(playerBalance)
        if bet == 0 then
            return playerBalance
        end

        if bet > playerBalance then
            War.ui.clear()
            War.ui.drawTitle("WAR")
            War.ui.centerText(10, "Nicht genug Diamanten!", colors.red)
            sleep(2)
        else
            -- Spiel starten
            local won, payout = War.playRound(bet)

            -- Balance aktualisieren
            if won == "tie" then
                War.ui.clear()
                War.ui.drawTitle("WAR")
                War.ui.centerText(10, "UNENTSCHIEDEN!", colors.yellow)
                War.ui.centerText(12, "Einsatz zurueck", colors.white)
                sleep(2)
            elseif won then
                playerBalance = playerBalance + payout
                War.ui.showResult(true, payout)
            else
                playerBalance = playerBalance - bet
                War.ui.showResult(false, bet)
            end

            if playerBalance <= 0 then
                War.ui.clear()
                War.ui.drawTitle("GAME OVER")
                War.ui.centerText(10, "Keine Diamanten mehr!", colors.red)
                sleep(3)
                return 0
            end
        end
    end
end

-- Einsatz wählen
function War.selectBet(maxBet)
    local buttons = War.ui.selectAmount(
        "WAR - Einsatz waehlen",
        1,
        math.min(10, maxBet)
    )
    local choice, button = War.ui.waitForTouch(buttons)
    return button.amount
end

-- Eine Runde spielen
function War.playRound(bet)
    War.ui.clear()
    War.ui.drawTitle("WAR")

    War.ui.centerText(4, "Einsatz: " .. bet .. " Diamanten", colors.yellow)
    War.ui.centerText(6, "Karten werden gezogen...", colors.white)

    sleep(1)

    -- Karten ziehen
    local playerCard = cards[math.random(#cards)]
    local dealerCard = cards[math.random(#cards)]

    -- Karten anzeigen
    local centerY = 12

    War.ui.centerText(centerY - 3, "DEALER", colors.white)
    War.drawCard(math.floor(War.ui.width / 2) - 3, centerY - 1, dealerCard)

    sleep(1)

    War.ui.centerText(centerY + 7, "DU", colors.white)
    War.drawCard(math.floor(War.ui.width / 2) - 3, centerY + 9, playerCard)

    sleep(2)

    -- Gewinner ermitteln
    if playerCard.value > dealerCard.value then
        War.ui.centerText(centerY + 16, "DU GEWINNST!", colors.lime)
        sleep(2)
        return true, bet * 2
    elseif playerCard.value < dealerCard.value then
        War.ui.centerText(centerY + 16, "DEALER GEWINNT!", colors.red)
        sleep(2)
        return false, 0
    else
        -- Unentschieden
        War.ui.centerText(centerY + 16, "UNENTSCHIEDEN!", colors.yellow)
        sleep(2)
        return "tie", 0
    end
end

-- Karte zeichnen
function War.drawCard(x, y, card)
    local cardWidth = 7
    local cardHeight = 5

    War.ui.drawBox(x, y, cardWidth, cardHeight, colors.white)
    War.ui.drawBorder(x, y, cardWidth, cardHeight, colors.gray)

    War.ui.monitor.setCursorPos(x + 2, y + 2)
    War.ui.monitor.setTextColor(colors.black)
    War.ui.monitor.setBackgroundColor(colors.white)
    War.ui.monitor.write(card.name)
end

return War

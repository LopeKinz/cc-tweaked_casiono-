-- Horse Racing (Pferderennen)
local Horses = {}

-- Pferde
local horses = {
    {name = "BLITZ", color = colors.red, symbol = "1"},
    {name = "THUNDER", color = colors.blue, symbol = "2"},
    {name = "STAR", color = colors.yellow, symbol = "3"},
    {name = "ROCKET", color = colors.lime, symbol = "4"}
}

-- Initialisierung
function Horses.init(ui, inventory)
    Horses.ui = ui
    Horses.inventory = inventory
    return Horses
end

-- Haupt-Spiel-Loop
function Horses.play(playerName, playerBalance)
    while true do
        -- Einsatz wählen
        local bet = Horses.selectBet(playerBalance)
        if bet == 0 then
            return playerBalance
        end

        if bet > playerBalance then
            Horses.ui.clear()
            Horses.ui.drawTitle("HORSE RACING")
            Horses.ui.centerText(10, "Nicht genug Diamanten!", colors.red)
            sleep(2)
        else
            -- Pferd wählen
            local selectedHorse = Horses.selectHorse()
            if not selectedHorse then
                -- Zurück
            else
                -- Rennen starten
                local won, payout = Horses.race(bet, selectedHorse)

                -- Balance aktualisieren
                if won then
                    playerBalance = playerBalance + payout
                else
                    playerBalance = playerBalance - bet
                end

                -- Ergebnis anzeigen
                Horses.ui.showResult(won, won and payout or bet)

                if playerBalance <= 0 then
                    Horses.ui.clear()
                    Horses.ui.drawTitle("GAME OVER")
                    Horses.ui.centerText(10, "Keine Diamanten mehr!", colors.red)
                    sleep(3)
                    return 0
                end
            end
        end
    end
end

-- Einsatz wählen
function Horses.selectBet(maxBet)
    local buttons = Horses.ui.selectAmount(
        "HORSE RACING - Einsatz",
        1,
        math.min(10, maxBet)
    )
    local choice, button = Horses.ui.waitForTouch(buttons)
    return button.amount
end

-- Pferd wählen
function Horses.selectHorse()
    Horses.ui.clear()
    Horses.ui.drawTitle("HORSE RACING - Pferd waehlen")

    local options = {}
    for i, horse in ipairs(horses) do
        table.insert(options, {
            text = horse.symbol .. " - " .. horse.name .. " (4x)",
            horse = i,
            color = horse.color
        })
    end
    table.insert(options, {text = "Zurueck", horse = nil, color = colors.red})

    local buttons = Horses.ui.drawMenu("", options, 8)
    local choice, button = Horses.ui.waitForTouch(buttons)

    if choice == #buttons then
        return nil
    end

    return options[choice].horse
end

-- Rennen durchführen
function Horses.race(bet, selectedHorse)
    Horses.ui.clear()
    Horses.ui.drawTitle("HORSE RACING")

    local selectedHorseName = horses[selectedHorse].name
    Horses.ui.centerText(4, "Dein Pferd: " .. selectedHorseName, horses[selectedHorse].color)

    sleep(1)

    -- Rennbahn
    local trackLength = 40
    local startX = 5
    local startY = 8

    -- Pferde-Positionen
    local positions = {0, 0, 0, 0}

    -- Startlinie
    Horses.ui.centerText(startY - 1, "START", colors.white)

    -- Rennen!
    local winner = nil
    while not winner do
        -- Jedes Pferd bewegt sich zufällig
        for i = 1, 4 do
            positions[i] = positions[i] + math.random(1, 3)

            if positions[i] >= trackLength then
                positions[i] = trackLength
                if not winner then
                    winner = i
                end
            end
        end

        -- Pferde zeichnen
        for i, horse in ipairs(horses) do
            local y = startY + (i - 1) * 3

            -- Name
            Horses.ui.monitor.setCursorPos(startX - 3, y)
            Horses.ui.monitor.setTextColor(horse.color)
            Horses.ui.monitor.setBackgroundColor(colors.black)
            Horses.ui.monitor.write(horse.symbol)

            -- Spur löschen
            Horses.ui.monitor.setCursorPos(startX, y)
            Horses.ui.monitor.setBackgroundColor(colors.black)
            Horses.ui.monitor.write(string.rep("-", trackLength))

            -- Pferd zeichnen
            local horseX = startX + positions[i]
            if horseX <= startX + trackLength then
                Horses.ui.monitor.setCursorPos(horseX, y)
                Horses.ui.monitor.setBackgroundColor(horse.color)
                Horses.ui.monitor.write(" ")
            end
        end

        sleep(0.2)
    end

    -- Ziellinie
    Horses.ui.monitor.setCursorPos(startX + trackLength + 2, startY + 5)
    Horses.ui.monitor.setTextColor(colors.white)
    Horses.ui.monitor.setBackgroundColor(colors.black)
    Horses.ui.monitor.write("ZIEL")

    sleep(1)

    -- Gewinner anzeigen
    local winnerHorse = horses[winner]
    Horses.ui.centerText(startY + 14, "GEWINNER: " .. winnerHorse.name, winnerHorse.color)

    sleep(2)

    -- Prüfen ob Spieler gewonnen hat
    if winner == selectedHorse then
        local payout = bet * 4
        return true, payout
    else
        return false, 0
    end
end

return Horses

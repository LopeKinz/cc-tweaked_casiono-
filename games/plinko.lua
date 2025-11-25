-- Plinko
local Plinko = {}

-- Auszahlungs-Multiplikatoren (von links nach rechts)
local multipliers = {100, 20, 5, 2, 1, 0.5, 1, 2, 5, 20, 100}

-- Initialisierung
function Plinko.init(ui, inventory)
    Plinko.ui = ui
    Plinko.inventory = inventory
    return Plinko
end

-- Haupt-Spiel-Loop
function Plinko.play(playerName, playerBalance)
    while true do
        -- Einsatz wählen
        local bet = Plinko.selectBet(playerBalance)
        if bet == 0 then
            return playerBalance
        end

        if bet > playerBalance then
            Plinko.ui.clear()
            Plinko.ui.drawTitle("PLINKO")
            Plinko.ui.centerText(10, "Nicht genug Diamanten!", colors.red)
            sleep(2)
        else
            -- Ball werfen
            local won, payout = Plinko.drop(bet)

            -- Balance aktualisieren
            if payout > bet then
                playerBalance = playerBalance + (payout - bet)
                Plinko.ui.showResult(true, payout - bet)
            elseif payout < bet then
                playerBalance = playerBalance - (bet - payout)
                Plinko.ui.showResult(false, bet - payout)
            else
                -- Break-even
                Plinko.ui.clear()
                Plinko.ui.drawTitle("PLINKO")
                Plinko.ui.centerText(10, "BREAK EVEN!", colors.yellow)
                Plinko.ui.centerText(12, "Einsatz zurueck", colors.white)
                sleep(2)
            end

            if playerBalance <= 0 then
                Plinko.ui.clear()
                Plinko.ui.drawTitle("GAME OVER")
                Plinko.ui.centerText(10, "Keine Diamanten mehr!", colors.red)
                sleep(3)
                return 0
            end
        end
    end
end

-- Einsatz wählen
function Plinko.selectBet(maxBet)
    local buttons = Plinko.ui.selectAmount(
        "PLINKO - Einsatz waehlen",
        1,
        math.min(10, maxBet)
    )
    local choice, button = Plinko.ui.waitForTouch(buttons)
    return button.amount
end

-- Ball fallen lassen
function Plinko.drop(bet)
    Plinko.ui.clear()
    Plinko.ui.drawTitle("PLINKO")

    local boardWidth = 50
    local boardHeight = 25
    local startX = math.floor((Plinko.ui.width - boardWidth) / 2)
    local startY = 4

    -- Zeichne Slots am Boden
    local slotWidth = math.floor(boardWidth / #multipliers)
    for i = 1, #multipliers do
        local x = startX + (i - 1) * slotWidth
        local y = startY + boardHeight - 3

        local mult = multipliers[i]
        local color = mult >= 20 and colors.lime or
                     (mult >= 5 and colors.yellow or
                     (mult >= 2 and colors.orange or
                     (mult >= 1 and colors.blue or colors.red)))

        Plinko.ui.drawBox(x, y, slotWidth - 1, 3, color)

        -- Multiplikator anzeigen
        local text = tostring(mult) .. "x"
        Plinko.ui.monitor.setCursorPos(x + math.floor((slotWidth - #text) / 2), y + 1)
        Plinko.ui.monitor.setTextColor(colors.white)
        Plinko.ui.monitor.setBackgroundColor(color)
        Plinko.ui.monitor.write(text)
    end

    sleep(1)

    -- Ball-Animation
    local ballX = math.floor(boardWidth / 2)  -- Start in der Mitte
    local ballY = 0

    local rows = 10  -- Anzahl der Pin-Reihen

    for row = 1, rows do
        -- Ball fällt nach links oder rechts
        if math.random(2) == 1 then
            ballX = ballX - 1
        else
            ballX = ballX + 1
        end

        -- Begrenzen
        ballX = math.max(1, math.min(ballX, boardWidth - 2))
        ballY = row * 2

        -- Ball zeichnen
        Plinko.ui.monitor.setCursorPos(startX + ballX, startY + ballY)
        Plinko.ui.monitor.setBackgroundColor(colors.yellow)
        Plinko.ui.monitor.setTextColor(colors.black)
        Plinko.ui.monitor.write("O")

        sleep(0.2)

        -- Ball löschen
        Plinko.ui.monitor.setCursorPos(startX + ballX, startY + ballY)
        Plinko.ui.monitor.setBackgroundColor(colors.black)
        Plinko.ui.monitor.write(" ")
    end

    -- Finale Position - welcher Slot?
    local slotIndex = math.max(1, math.min(math.floor(ballX / slotWidth) + 1, #multipliers))
    local finalMultiplier = multipliers[slotIndex]

    -- Ball in Slot fallen lassen
    for y = ballY, startY + boardHeight - 4 do
        local slotX = startX + (slotIndex - 1) * slotWidth + math.floor(slotWidth / 2)

        Plinko.ui.monitor.setCursorPos(slotX, y)
        Plinko.ui.monitor.setBackgroundColor(colors.yellow)
        Plinko.ui.monitor.write("O")

        sleep(0.1)

        if y < startY + boardHeight - 4 then
            Plinko.ui.monitor.setCursorPos(slotX, y)
            Plinko.ui.monitor.setBackgroundColor(colors.black)
            Plinko.ui.monitor.write(" ")
        end
    end

    sleep(1)

    -- Ergebnis
    local payout = math.floor(bet * finalMultiplier)

    Plinko.ui.centerText(startY + boardHeight + 1, "Multiplikator: " .. finalMultiplier .. "x", colors.white)
    Plinko.ui.centerText(startY + boardHeight + 2, "Auszahlung: " .. payout, colors.yellow)

    sleep(2)

    return payout >= bet, payout
end

return Plinko

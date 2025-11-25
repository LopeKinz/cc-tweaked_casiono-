-- Crash Game
local Crash = {}

-- Initialisierung
function Crash.init(ui, inventory)
    Crash.ui = ui
    Crash.inventory = inventory
    return Crash
end

-- Haupt-Spiel-Loop
function Crash.play(playerName, playerBalance)
    while true do
        -- Einsatz wählen
        local bet = Crash.selectBet(playerBalance)
        if bet == 0 then
            return playerBalance
        end

        if bet > playerBalance then
            Crash.ui.clear()
            Crash.ui.drawTitle("CRASH")
            Crash.ui.centerText(10, "Nicht genug Diamanten!", colors.red)
            sleep(2)
        else
            -- Spiel starten
            local won, payout = Crash.playRound(bet)

            -- Balance aktualisieren
            if won then
                playerBalance = playerBalance + payout
            else
                playerBalance = playerBalance - bet
            end

            -- Ergebnis anzeigen
            Crash.ui.showResult(won, won and payout or bet)

            if playerBalance <= 0 then
                Crash.ui.clear()
                Crash.ui.drawTitle("GAME OVER")
                Crash.ui.centerText(10, "Keine Diamanten mehr!", colors.red)
                sleep(3)
                return 0
            end
        end
    end
end

-- Einsatz wählen
function Crash.selectBet(maxBet)
    local buttons = Crash.ui.selectAmount(
        "CRASH - Einsatz waehlen",
        1,
        math.min(10, maxBet)
    )
    local choice, button = Crash.ui.waitForTouch(buttons)
    return button.amount
end

-- Eine Runde spielen
function Crash.playRound(bet)
    Crash.ui.clear()
    Crash.ui.drawTitle("CRASH")

    Crash.ui.centerText(4, "Einsatz: " .. bet .. " Diamanten", colors.yellow)
    Crash.ui.centerText(6, "Multiplier steigt...", colors.white)
    Crash.ui.centerText(7, "Druecke CASHOUT bevor es crasht!", colors.orange)

    -- Crash-Punkt bestimmen (1.0x bis 10.0x)
    local crashPoint = 1.0 + (math.random() ^ 2) * 9.0

    local multiplier = 1.0
    local cashedOut = false
    local cashoutMultiplier = 0

    local centerY = 12

    -- Cashout Button
    local cashoutButton = Crash.ui.drawButton(
        math.floor(Crash.ui.width / 2) - 12,
        centerY + 8,
        25, 4,
        "CASHOUT",
        colors.lime,
        colors.white
    )

    -- Multiplier steigt
    while multiplier < crashPoint do
        -- Multiplier anzeigen
        Crash.ui.drawBox(
            math.floor(Crash.ui.width / 2) - 10,
            centerY - 2,
            20, 6,
            colors.gray
        )

        local multText = string.format("%.2fx", multiplier)
        local color = multiplier < 2.0 and colors.lime or
                     (multiplier < 5.0 and colors.yellow or colors.red)

        Crash.ui.centerText(centerY, multText, color, colors.gray)
        Crash.ui.centerText(centerY + 2, "Gewinn: " .. math.floor(bet * multiplier), colors.white, colors.gray)

        -- Prüfen auf Touch
        local event, side, x, y = os.pullEvent()

        if event == "monitor_touch" then
            if Crash.ui.isInBounds(x, y, cashoutButton) then
                cashedOut = true
                cashoutMultiplier = multiplier
                break
            end
        end

        -- Multiplier erhöhen
        multiplier = multiplier + 0.1
        sleep(0.1)
    end

    -- Crash Animation
    Crash.ui.clear()
    Crash.ui.drawTitle("CRASH")

    if cashedOut then
        -- Gewonnen!
        local payout = math.floor(bet * cashoutMultiplier)

        for i = 1, 3 do
            Crash.ui.drawBox(
                math.floor(Crash.ui.width / 2) - 15,
                centerY - 3,
                30, 8,
                colors.lime
            )

            Crash.ui.centerText(centerY, "CASHOUT!", colors.white, colors.lime)
            Crash.ui.centerText(centerY + 2, string.format("%.2fx", cashoutMultiplier), colors.yellow, colors.lime)
            Crash.ui.centerText(centerY + 4, "Gewinn: " .. payout, colors.white, colors.lime)

            sleep(0.3)

            Crash.ui.drawBox(
                math.floor(Crash.ui.width / 2) - 15,
                centerY - 3,
                30, 8,
                colors.black
            )
            sleep(0.2)
        end

        sleep(1)
        return true, payout

    else
        -- Crashed!
        for i = 1, 3 do
            Crash.ui.drawBox(
                math.floor(Crash.ui.width / 2) - 15,
                centerY - 3,
                30, 8,
                colors.red
            )

            Crash.ui.centerText(centerY, "CRASHED!", colors.white, colors.red)
            Crash.ui.centerText(centerY + 2, string.format("bei %.2fx", crashPoint), colors.yellow, colors.red)

            sleep(0.3)

            Crash.ui.drawBox(
                math.floor(Crash.ui.width / 2) - 15,
                centerY - 3,
                30, 8,
                colors.black
            )
            sleep(0.2)
        end

        sleep(1)
        return false, 0
    end
end

return Crash

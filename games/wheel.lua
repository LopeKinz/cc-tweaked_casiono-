-- Wheel of Fortune (Glücksrad)
local Wheel = {}

-- Rad-Segmente mit Multiplikatoren
local segments = {
    {multiplier = 2, color = colors.blue},
    {multiplier = 5, color = colors.green},
    {multiplier = 1, color = colors.gray},
    {multiplier = 10, color = colors.yellow},
    {multiplier = 0, color = colors.red},  -- Bankrott
    {multiplier = 3, color = colors.lime},
    {multiplier = 1, color = colors.gray},
    {multiplier = 20, color = colors.purple},
    {multiplier = 1, color = colors.gray},
    {multiplier = 5, color = colors.green},
    {multiplier = 2, color = colors.blue},
    {multiplier = 50, color = colors.orange}
}

-- Initialisierung
function Wheel.init(ui, inventory)
    Wheel.ui = ui
    Wheel.inventory = inventory
    return Wheel
end

-- Haupt-Spiel-Loop
function Wheel.play(playerName, playerBalance)
    while true do
        -- Einsatz wählen
        local bet = Wheel.selectBet(playerBalance)
        if bet == 0 then
            return playerBalance
        end

        if bet > playerBalance then
            Wheel.ui.clear()
            Wheel.ui.drawTitle("WHEEL OF FORTUNE")
            Wheel.ui.centerText(10, "Nicht genug Diamanten!", colors.red)
            sleep(2)
        else
            -- Rad drehen
            local won, payout = Wheel.spin(bet)

            -- Balance aktualisieren
            if won then
                playerBalance = playerBalance + payout
            else
                playerBalance = playerBalance - bet
            end

            -- Ergebnis anzeigen
            Wheel.ui.showResult(won, won and payout or bet)

            if playerBalance <= 0 then
                Wheel.ui.clear()
                Wheel.ui.drawTitle("GAME OVER")
                Wheel.ui.centerText(10, "Keine Diamanten mehr!", colors.red)
                sleep(3)
                return 0
            end
        end
    end
end

-- Einsatz wählen
function Wheel.selectBet(maxBet)
    local result = Wheel.ui.selectAmount(
        "WHEEL OF FORTUNE - Einsatz",
        1,
        maxBet
    )
    return result[1].amount
end

-- Rad drehen
function Wheel.spin(bet)
    Wheel.ui.clear()
    Wheel.ui.drawTitle("WHEEL OF FORTUNE")

    Wheel.ui.centerText(4, "Einsatz: " .. bet .. " Diamanten", colors.yellow)
    Wheel.ui.centerText(6, "Rad dreht sich...", colors.white)

    local centerY = 12

    -- Rad-Animation
    local spins = 20 + math.random(10)
    local currentSegment = 1

    for i = 1, spins do
        currentSegment = (currentSegment % #segments) + 1

        -- Rad zeichnen
        Wheel.drawWheel(centerY, currentSegment)

        local delay = 0.05 + (i * 0.02)
        sleep(delay)
    end

    -- Finales Ergebnis
    local finalSegment = segments[currentSegment]
    local multiplier = finalSegment.multiplier

    sleep(1)

    Wheel.ui.centerText(centerY + 8, "Multiplier: " .. multiplier .. "x", colors.white)

    if multiplier == 0 then
        Wheel.ui.centerText(centerY + 10, "BANKROTT!", colors.red)
        sleep(2)
        return false, 0
    else
        local payout = bet * multiplier
        Wheel.ui.centerText(centerY + 10, "Gewinn: " .. payout, colors.lime)
        sleep(2)
        return true, payout
    end
end

-- Rad zeichnen
function Wheel.drawWheel(centerY, currentSegment)
    local width = 40
    local height = 6
    local startX = math.floor((Wheel.ui.width - width) / 2)

    -- Aktuelle Segment hervorheben
    for i = 1, 3 do
        local segmentIndex = ((currentSegment - 2 + i) - 1) % #segments + 1
        local segment = segments[segmentIndex]

        local x = startX + (i - 1) * (width / 3)
        local w = math.floor(width / 3)

        local bgColor = i == 2 and segment.color or colors.gray

        Wheel.ui.drawBox(x, centerY, w, height, bgColor)

        -- Multiplikator
        local text = tostring(segment.multiplier) .. "x"
        Wheel.ui.monitor.setCursorPos(x + math.floor((w - #text) / 2), centerY + 3)
        Wheel.ui.monitor.setTextColor(colors.white)
        Wheel.ui.monitor.setBackgroundColor(bgColor)
        Wheel.ui.monitor.write(text)
    end

    -- Zeiger (Pfeil nach unten)
    local pointerX = startX + math.floor(width / 2)
    Wheel.ui.monitor.setCursorPos(pointerX, centerY - 1)
    Wheel.ui.monitor.setBackgroundColor(colors.black)
    Wheel.ui.monitor.setTextColor(colors.yellow)
    Wheel.ui.monitor.write("V")
end

return Wheel

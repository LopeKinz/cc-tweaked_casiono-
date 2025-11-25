-- UI Library für Touch-Steuerung
local UI = {}

-- Farben
UI.colors = {
    primary = colors.green,
    secondary = colors.lime,
    danger = colors.red,
    warning = colors.orange,
    info = colors.blue,
    success = colors.lime,
    bg = colors.black,
    text = colors.white,
    gold = colors.yellow
}

-- Monitor initialisieren
function UI.init(monitor)
    UI.monitor = monitor
    UI.width, UI.height = monitor.getSize()
    monitor.setTextScale(0.5)
    UI.width, UI.height = monitor.getSize()
    monitor.clear()
    return UI
end

-- Bildschirm leeren
function UI.clear(color)
    UI.monitor.setBackgroundColor(color or UI.colors.bg)
    UI.monitor.clear()
    UI.monitor.setCursorPos(1, 1)
end

-- Text zentriert anzeigen
function UI.centerText(y, text, textColor, bgColor)
    local x = math.floor((UI.width - #text) / 2) + 1
    UI.monitor.setCursorPos(x, y)
    UI.monitor.setTextColor(textColor or UI.colors.text)
    UI.monitor.setBackgroundColor(bgColor or UI.colors.bg)
    UI.monitor.write(text)
end

-- Text anzeigen
function UI.drawText(x, y, text, textColor, bgColor)
    UI.monitor.setCursorPos(x, y)
    UI.monitor.setTextColor(textColor or UI.colors.text)
    UI.monitor.setBackgroundColor(bgColor or UI.colors.bg)
    UI.monitor.write(text)
end

-- Button zeichnen
function UI.drawButton(x, y, width, height, text, bgColor, textColor)
    UI.monitor.setBackgroundColor(bgColor or UI.colors.primary)
    UI.monitor.setTextColor(textColor or UI.colors.text)

    -- Button-Hintergrund
    for i = 0, height - 1 do
        UI.monitor.setCursorPos(x, y + i)
        UI.monitor.write(string.rep(" ", width))
    end

    -- Text zentrieren
    local textX = x + math.floor((width - #text) / 2)
    local textY = y + math.floor(height / 2)
    UI.monitor.setCursorPos(textX, textY)
    UI.monitor.write(text)

    return {x = x, y = y, width = width, height = height, text = text}
end

-- Box zeichnen
function UI.drawBox(x, y, width, height, bgColor)
    UI.monitor.setBackgroundColor(bgColor or UI.colors.primary)
    for i = 0, height - 1 do
        UI.monitor.setCursorPos(x, y + i)
        UI.monitor.write(string.rep(" ", width))
    end
end

-- Rahmen zeichnen
function UI.drawBorder(x, y, width, height, color)
    UI.monitor.setBackgroundColor(color or UI.colors.primary)

    -- Oben und unten
    UI.monitor.setCursorPos(x, y)
    UI.monitor.write(string.rep(" ", width))
    UI.monitor.setCursorPos(x, y + height - 1)
    UI.monitor.write(string.rep(" ", width))

    -- Seiten
    for i = 1, height - 2 do
        UI.monitor.setCursorPos(x, y + i)
        UI.monitor.write(" ")
        UI.monitor.setCursorPos(x + width - 1, y + i)
        UI.monitor.write(" ")
    end
end

-- Prüfen ob Punkt in Bereich ist
function UI.isInBounds(x, y, bounds)
    return x >= bounds.x and
           x < bounds.x + bounds.width and
           y >= bounds.y and
           y < bounds.y + bounds.height
end

-- Touch-Event verarbeiten
function UI.waitForTouch(buttons)
    while true do
        local event, side, x, y = os.pullEvent("monitor_touch")

        for i, button in ipairs(buttons) do
            if UI.isInBounds(x, y, button) then
                return i, button
            end
        end
    end
end

-- Titel anzeigen
function UI.drawTitle(text)
    UI.monitor.setBackgroundColor(UI.colors.primary)
    UI.monitor.setTextColor(UI.colors.text)
    UI.monitor.setCursorPos(1, 1)
    UI.monitor.clearLine()
    UI.centerText(1, text, UI.colors.text, UI.colors.primary)

    UI.monitor.setCursorPos(1, 2)
    UI.monitor.setBackgroundColor(UI.colors.secondary)
    UI.monitor.clearLine()
end

-- Fortschrittsbalken
function UI.drawProgressBar(x, y, width, percent, color)
    local filled = math.floor(width * percent / 100)

    UI.monitor.setCursorPos(x, y)
    UI.monitor.setBackgroundColor(color or UI.colors.success)
    UI.monitor.write(string.rep(" ", filled))

    UI.monitor.setBackgroundColor(colors.gray)
    UI.monitor.write(string.rep(" ", width - filled))

    UI.monitor.setBackgroundColor(UI.colors.bg)
end

-- Auswahl-Menu
function UI.drawMenu(title, options, startY)
    UI.clear()
    UI.drawTitle(title)

    local buttons = {}
    local buttonHeight = 3
    local buttonWidth = UI.width - 20
    local buttonX = 11
    local y = startY or 5

    for i, option in ipairs(options) do
        local button = UI.drawButton(
            buttonX,
            y,
            buttonWidth,
            buttonHeight,
            option.text,
            option.color or UI.colors.primary,
            UI.colors.text
        )
        button.action = option.action
        table.insert(buttons, button)
        y = y + buttonHeight + 2
    end

    return buttons
end

-- Liste mit Scroll-Funktion
function UI.drawList(title, items, startY, maxVisible)
    UI.clear()
    UI.drawTitle(title)

    local buttons = {}
    local itemHeight = 3
    local itemWidth = UI.width - 20
    local itemX = 11
    local y = startY or 5
    local maxItems = maxVisible or 8

    for i = 1, math.min(#items, maxItems) do
        local button = UI.drawButton(
            itemX,
            y,
            itemWidth,
            itemHeight,
            items[i],
            UI.colors.info,
            UI.colors.text
        )
        button.value = items[i]
        table.insert(buttons, button)
        y = y + itemHeight + 1
    end

    return buttons
end

-- Geld-Auswahl (1-10 Diamanten)
function UI.selectAmount(title, minAmount, maxAmount)
    minAmount = minAmount or 1
    maxAmount = maxAmount or 10

    UI.clear()
    UI.drawTitle(title)

    local buttons = {}
    local cols = 5
    local rows = 2
    local buttonSize = 6
    local spacingX = 3
    local spacingY = 2
    local startX = math.floor((UI.width - (cols * buttonSize + (cols - 1) * spacingX)) / 2)
    local startY = 8

    local amount = 1
    for row = 0, rows - 1 do
        for col = 0, cols - 1 do
            if amount <= maxAmount then
                local x = startX + col * (buttonSize + spacingX)
                local y = startY + row * (buttonSize + spacingY)

                local button = UI.drawButton(
                    x, y, buttonSize, buttonSize,
                    tostring(amount),
                    UI.colors.gold,
                    colors.black
                )
                button.amount = amount
                table.insert(buttons, button)
                amount = amount + 1
            end
        end
    end

    -- Zurück-Button
    local backButton = UI.drawButton(
        math.floor(UI.width / 2) - 10,
        startY + rows * (buttonSize + spacingY) + 3,
        20, 3,
        "Zurueck",
        UI.colors.danger,
        UI.colors.text
    )
    backButton.amount = 0
    table.insert(buttons, backButton)

    return buttons
end

-- Diamanten-Anzeige
function UI.showDiamonds(amount, x, y)
    x = x or 2
    y = y or 4

    UI.drawText(x, y, "Diamanten: ", UI.colors.text, UI.colors.bg)
    UI.drawText(x + 11, y, tostring(amount), UI.colors.gold, UI.colors.bg)
end

-- Gewinn/Verlust Animation
function UI.showResult(won, amount)
    local text = won and ("GEWONNEN! +" .. amount) or ("VERLOREN! -" .. amount)
    local color = won and UI.colors.success or UI.colors.danger

    local y = math.floor(UI.height / 2)

    for i = 1, 3 do
        UI.drawBox(1, y - 2, UI.width, 5, color)
        UI.centerText(y, text, colors.white, color)
        sleep(0.3)

        UI.drawBox(1, y - 2, UI.width, 5, UI.colors.bg)
        sleep(0.2)
    end

    UI.drawBox(1, y - 2, UI.width, 5, color)
    UI.centerText(y, text, colors.white, color)
    sleep(1.5)
end

-- Lade-Animation
function UI.showLoading(text, duration)
    local y = math.floor(UI.height / 2)
    UI.centerText(y, text, UI.colors.text, UI.colors.bg)

    local dots = ""
    local steps = math.floor(duration / 0.3)
    for i = 1, steps do
        dots = dots .. "."
        if #dots > 3 then dots = "." end
        UI.centerText(y + 1, dots .. string.rep(" ", 3 - #dots), UI.colors.text, UI.colors.bg)
        sleep(0.3)
    end
end

-- Bestätigungs-Dialog
function UI.confirm(message, yesText, noText)
    yesText = yesText or "Ja"
    noText = noText or "Nein"

    local y = math.floor(UI.height / 2) - 4

    -- Hintergrund
    UI.drawBox(10, y, UI.width - 20, 12, colors.gray)
    UI.drawBorder(10, y, UI.width - 20, 12, UI.colors.primary)

    -- Nachricht
    local lines = {}
    for line in message:gmatch("[^\n]+") do
        table.insert(lines, line)
    end

    for i, line in ipairs(lines) do
        UI.centerText(y + 2 + i, line, UI.colors.text, colors.gray)
    end

    -- Buttons
    local buttonY = y + 7
    local buttonWidth = 15
    local spacing = 5
    local totalWidth = buttonWidth * 2 + spacing
    local startX = math.floor((UI.width - totalWidth) / 2)

    local yesButton = UI.drawButton(
        startX, buttonY, buttonWidth, 3,
        yesText, UI.colors.success, UI.colors.text
    )

    local noButton = UI.drawButton(
        startX + buttonWidth + spacing, buttonY, buttonWidth, 3,
        noText, UI.colors.danger, UI.colors.text
    )

    local choice, button = UI.waitForTouch({yesButton, noButton})
    return choice == 1
end

return UI

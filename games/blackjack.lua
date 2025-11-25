-- Blackjack (21)
local Blackjack = {}

-- Karten-Werte
local cards = {
    {name = "A", value = 11, altValue = 1, symbol = "A"},
    {name = "2", value = 2, symbol = "2"},
    {name = "3", value = 3, symbol = "3"},
    {name = "4", value = 4, symbol = "4"},
    {name = "5", value = 5, symbol = "5"},
    {name = "6", value = 6, symbol = "6"},
    {name = "7", value = 7, symbol = "7"},
    {name = "8", value = 8, symbol = "8"},
    {name = "9", value = 9, symbol = "9"},
    {name = "10", value = 10, symbol = "10"},
    {name = "J", value = 10, symbol = "J"},
    {name = "Q", value = 10, symbol = "Q"},
    {name = "K", value = 10, symbol = "K"}
}

-- Farben
local suits = {"Herz", "Karo", "Pik", "Kreuz"}
local suitColors = {
    Herz = colors.red,
    Karo = colors.red,
    Pik = colors.gray,
    Kreuz = colors.gray
}

-- Initialisierung
function Blackjack.init(ui, inventory)
    Blackjack.ui = ui
    Blackjack.inventory = inventory
    return Blackjack
end

-- Haupt-Spiel-Loop
function Blackjack.play(playerName, playerBalance)
    while true do
        -- Einsatz wählen
        local bet = Blackjack.selectBet(playerBalance)
        if bet == 0 then
            return playerBalance
        end

        if bet > playerBalance then
            Blackjack.ui.clear()
            Blackjack.ui.drawTitle("BLACKJACK")
            Blackjack.ui.centerText(10, "Nicht genug Diamanten!", colors.red)
            sleep(2)
        else
            -- Spiel starten
            local won, payout = Blackjack.playRound(bet)

            -- Balance aktualisieren
            if won == "push" then
                -- Unentschieden - Einsatz zurück
                Blackjack.ui.clear()
                Blackjack.ui.drawTitle("BLACKJACK")
                Blackjack.ui.centerText(10, "UNENTSCHIEDEN!", colors.yellow)
                Blackjack.ui.centerText(12, "Einsatz zurueck: " .. bet, colors.white)
                sleep(2)
            elseif won then
                playerBalance = playerBalance + payout
                Blackjack.ui.showResult(true, payout)
            else
                playerBalance = playerBalance - bet
                Blackjack.ui.showResult(false, bet)
            end

            -- Prüfen ob Spieler pleite ist
            if playerBalance <= 0 then
                Blackjack.ui.clear()
                Blackjack.ui.drawTitle("GAME OVER")
                Blackjack.ui.centerText(10, "Keine Diamanten mehr!", colors.red)
                Blackjack.ui.centerText(12, "Bitte Diamanten nachtanken.", colors.white)
                sleep(3)
                return 0
            end
        end
    end
end

-- Einsatz wählen
function Blackjack.selectBet(maxBet)
    local result = Blackjack.ui.selectAmount(
        "BLACKJACK - Einsatz waehlen",
        1,
        maxBet
    )

    return result[1].amount
end

-- Eine Runde spielen
function Blackjack.playRound(bet)
    -- Deck erstellen
    local deck = Blackjack.createDeck()

    -- Karten austeilen
    local playerHand = {Blackjack.drawCard(deck), Blackjack.drawCard(deck)}
    local dealerHand = {Blackjack.drawCard(deck), Blackjack.drawCard(deck)}

    -- Spieler-Zug
    local playerBust = false
    local playerBlackjack = Blackjack.calculateValue(playerHand) == 21 and #playerHand == 2

    if not playerBlackjack then
        while true do
            Blackjack.ui.clear()
            Blackjack.ui.drawTitle("BLACKJACK - Dein Zug")

            -- Hände anzeigen
            Blackjack.drawHands(playerHand, dealerHand, true)

            -- Wert anzeigen
            local playerValue = Blackjack.calculateValue(playerHand)
            Blackjack.ui.centerText(Blackjack.ui.height - 8, "Dein Wert: " .. playerValue, colors.white)

            -- Bust?
            if playerValue > 21 then
                playerBust = true
                Blackjack.ui.centerText(Blackjack.ui.height - 6, "BUST! Ueber 21!", colors.red)
                sleep(2)
                break
            end

            -- Aktionen
            local buttons = {}
            local buttonY = Blackjack.ui.height - 4

            local hitButton = Blackjack.ui.drawButton(
                math.floor(Blackjack.ui.width / 2) - 25, buttonY, 15, 3,
                "HIT", colors.lime, colors.white
            )
            table.insert(buttons, hitButton)

            local standButton = Blackjack.ui.drawButton(
                math.floor(Blackjack.ui.width / 2) - 7, buttonY, 15, 3,
                "STAND", colors.orange, colors.white
            )
            table.insert(buttons, standButton)

            -- Double Down nur bei ersten 2 Karten
            if #playerHand == 2 and bet * 2 <= playerBalance then
                local doubleButton = Blackjack.ui.drawButton(
                    math.floor(Blackjack.ui.width / 2) + 11, buttonY, 15, 3,
                    "DOUBLE", colors.yellow, colors.black
                )
                table.insert(buttons, doubleButton)
            end

            local choice, button = Blackjack.ui.waitForTouch(buttons)

            if choice == 1 then
                -- HIT
                table.insert(playerHand, Blackjack.drawCard(deck))
            elseif choice == 2 then
                -- STAND
                break
            elseif choice == 3 then
                -- DOUBLE DOWN
                bet = bet * 2
                table.insert(playerHand, Blackjack.drawCard(deck))
                break
            end
        end
    end

    -- Dealer-Zug (nur wenn Spieler nicht Bust)
    if not playerBust then
        Blackjack.ui.clear()
        Blackjack.ui.drawTitle("BLACKJACK - Dealer Zug")

        Blackjack.drawHands(playerHand, dealerHand, false)
        sleep(2)

        -- Dealer muss unter 17 ziehen
        while Blackjack.calculateValue(dealerHand) < 17 do
            table.insert(dealerHand, Blackjack.drawCard(deck))
            Blackjack.ui.clear()
            Blackjack.ui.drawTitle("BLACKJACK - Dealer Zug")
            Blackjack.drawHands(playerHand, dealerHand, false)
            sleep(1)
        end
    end

    -- Gewinner ermitteln
    local result = Blackjack.determineWinner(playerHand, dealerHand, playerBlackjack)

    -- Ergebnis anzeigen
    Blackjack.ui.clear()
    Blackjack.ui.drawTitle("BLACKJACK - Ergebnis")
    Blackjack.drawHands(playerHand, dealerHand, false)

    local playerValue = Blackjack.calculateValue(playerHand)
    local dealerValue = Blackjack.calculateValue(dealerHand)

    Blackjack.ui.centerText(Blackjack.ui.height - 6, "Dein Wert: " .. playerValue, colors.white)
    Blackjack.ui.centerText(Blackjack.ui.height - 5, "Dealer Wert: " .. dealerValue, colors.white)

    if result == "win" then
        local payout = playerBlackjack and math.floor(bet * 2.5) or (bet * 2)
        Blackjack.ui.centerText(Blackjack.ui.height - 3, "DU GEWINNST!", colors.lime)
        sleep(2)
        return true, payout
    elseif result == "push" then
        return "push", 0
    else
        Blackjack.ui.centerText(Blackjack.ui.height - 3, "DEALER GEWINNT!", colors.red)
        sleep(2)
        return false, 0
    end
end

-- Deck erstellen
function Blackjack.createDeck()
    local deck = {}
    for suit = 1, #suits do
        for card = 1, #cards do
            table.insert(deck, {
                card = cards[card],
                suit = suits[suit]
            })
        end
    end
    return deck
end

-- Karte ziehen
function Blackjack.drawCard(deck)
    local index = math.random(#deck)
    local card = table.remove(deck, index)
    return card
end

-- Hand-Wert berechnen
function Blackjack.calculateValue(hand)
    local value = 0
    local aces = 0

    for _, card in ipairs(hand) do
        value = value + card.card.value
        if card.card.name == "A" then
            aces = aces + 1
        end
    end

    -- Asse anpassen wenn über 21
    while value > 21 and aces > 0 do
        value = value - 10
        aces = aces - 1
    end

    return value
end

-- Gewinner ermitteln
function Blackjack.determineWinner(playerHand, dealerHand, playerBlackjack)
    local playerValue = Blackjack.calculateValue(playerHand)
    local dealerValue = Blackjack.calculateValue(dealerHand)

    if playerValue > 21 then
        return "lose"
    elseif dealerValue > 21 then
        return "win"
    elseif playerValue > dealerValue then
        return "win"
    elseif playerValue < dealerValue then
        return "lose"
    else
        return "push"
    end
end

-- Hände zeichnen
function Blackjack.drawHands(playerHand, dealerHand, hideDealerCard)
    local y = 5

    -- Dealer Hand
    Blackjack.ui.centerText(y, "DEALER:", colors.white)
    y = y + 2
    Blackjack.drawCards(dealerHand, y, hideDealerCard)

    y = y + 8

    -- Spieler Hand
    Blackjack.ui.centerText(y, "DU:", colors.white)
    y = y + 2
    Blackjack.drawCards(playerHand, y, false)
end

-- Karten zeichnen
function Blackjack.drawCards(hand, y, hideFirst)
    local cardWidth = 6
    local cardHeight = 6
    local spacing = 2
    local totalWidth = #hand * cardWidth + (#hand - 1) * spacing
    local startX = math.floor((Blackjack.ui.width - totalWidth) / 2)

    for i, card in ipairs(hand) do
        local x = startX + (i - 1) * (cardWidth + spacing)

        if i == 1 and hideFirst then
            -- Verdeckte Karte
            Blackjack.ui.drawBox(x, y, cardWidth, cardHeight, colors.blue)
            Blackjack.ui.drawBorder(x, y, cardWidth, cardHeight, colors.lightBlue)
            Blackjack.ui.centerText(y + 3, "?", colors.white, colors.blue)
        else
            -- Offene Karte
            local color = suitColors[card.suit]
            Blackjack.ui.drawBox(x, y, cardWidth, cardHeight, colors.white)
            Blackjack.ui.drawBorder(x, y, cardWidth, cardHeight, colors.gray)

            Blackjack.ui.monitor.setCursorPos(x + 2, y + 2)
            Blackjack.ui.monitor.setTextColor(color)
            Blackjack.ui.monitor.setBackgroundColor(colors.white)
            Blackjack.ui.monitor.write(card.card.symbol)
        end
    end
end

return Blackjack

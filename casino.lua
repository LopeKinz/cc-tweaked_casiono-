-- CASINO MAIN PROGRAM
-- Minecraft 1.21.1 - ComputerCraft: Tweaked + Advanced Peripherals

-- ===== PERIPHERIE SETUP =====
local function findPeripherals()
    local peripherals = {
        monitor = nil,
        rsBridge = nil,
        playerDetector = nil
    }

    -- Monitor finden (rechts vom Computer)
    peripherals.monitor = peripheral.find("monitor")
    if not peripherals.monitor then
        error("Monitor nicht gefunden! Bitte rechts vom Computer platzieren.")
    end

    -- RS Bridge finden (unter dem Computer)
    peripherals.rsBridge = peripheral.find("rsBridge")

    -- Player Detector finden (auf dem Computer)
    peripherals.playerDetector = peripheral.find("playerDetector")
    if not peripherals.playerDetector then
        error("Player Detector nicht gefunden! Bitte auf dem Computer platzieren.")
    end

    return peripherals
end

-- ===== MODULE LADEN =====
local function loadModules()
    local modules = {}

    -- UI laden
    if not fs.exists("ui.lua") then
        error("ui.lua nicht gefunden!")
    end
    modules.UI = dofile("ui.lua")

    -- Inventory laden
    if not fs.exists("inventory.lua") then
        error("inventory.lua nicht gefunden!")
    end
    modules.Inventory = dofile("inventory.lua")

    -- Spiele laden
    modules.games = {}

    if fs.exists("games/slots.lua") then
        modules.games.slots = dofile("games/slots.lua")
    end

    if fs.exists("games/roulette.lua") then
        modules.games.roulette = dofile("games/roulette.lua")
    end

    if fs.exists("games/blackjack.lua") then
        modules.games.blackjack = dofile("games/blackjack.lua")
    end

    if fs.exists("games/coinflip.lua") then
        modules.games.coinflip = dofile("games/coinflip.lua")
    end

    if fs.exists("games/dice.lua") then
        modules.games.dice = dofile("games/dice.lua")
    end

    -- Neue Spiele
    if fs.exists("games/keno.lua") then
        modules.games.keno = dofile("games/keno.lua")
    end

    if fs.exists("games/plinko.lua") then
        modules.games.plinko = dofile("games/plinko.lua")
    end

    if fs.exists("games/crash.lua") then
        modules.games.crash = dofile("games/crash.lua")
    end

    if fs.exists("games/highlow.lua") then
        modules.games.highlow = dofile("games/highlow.lua")
    end

    if fs.exists("games/mines.lua") then
        modules.games.mines = dofile("games/mines.lua")
    end

    if fs.exists("games/wheel.lua") then
        modules.games.wheel = dofile("games/wheel.lua")
    end

    if fs.exists("games/baccarat.lua") then
        modules.games.baccarat = dofile("games/baccarat.lua")
    end

    if fs.exists("games/war.lua") then
        modules.games.war = dofile("games/war.lua")
    end

    if fs.exists("games/scratch.lua") then
        modules.games.scratch = dofile("games/scratch.lua")
    end

    if fs.exists("games/horses.lua") then
        modules.games.horses = dofile("games/horses.lua")
    end

    if fs.exists("games/tower.lua") then
        modules.games.tower = dofile("games/tower.lua")
    end

    return modules
end

-- ===== PLAYER DETECTION =====
local function detectPlayers(playerDetector, ui)
    ui.clear()
    ui.drawTitle("CASINO - Willkommen!")

    ui.centerText(8, "Suche nach Spielern...", colors.white)
    ui.centerText(10, "Reichweite: 15 Bloecke", colors.gray)

    sleep(1)

    -- Spieler in Reichweite finden
    local players = playerDetector.getPlayersInRange(15)

    if not players or #players == 0 then
        ui.centerText(12, "Keine Spieler gefunden!", colors.red)
        ui.centerText(14, "Bitte naeher kommen...", colors.yellow)
        sleep(3)
        return nil
    end

    return players
end

local function selectPlayer(players, ui)
    ui.clear()
    ui.drawTitle("CASINO - Spieler waehlen")

    ui.centerText(4, "Gefundene Spieler: " .. #players, colors.lime)
    ui.centerText(5, "Bitte waehle deinen Namen:", colors.white)

    -- Player-Namen extrahieren
    local playerNames = {}
    for _, player in ipairs(players) do
        table.insert(playerNames, player)
    end

    local buttons = ui.drawList("", playerNames, 7, 10)

    local choice, button = ui.waitForTouch(buttons)
    return button.value
end

-- ===== HAUPTMENÜ =====
local function showMainMenu(ui, playerName, balance)
    ui.clear()
    ui.drawTitle("CASINO - Hauptmenue")

    -- Spieler-Info
    ui.drawText(2, 3, "Spieler: " .. playerName, colors.white)
    ui.showDiamonds(balance, 2, 4)

    -- Spiele-Menü (Alle Spiele!)
    local options = {
        -- Klassische Casino-Spiele
        {text = "SLOT MACHINE", color = colors.purple, game = "slots"},
        {text = "ROULETTE", color = colors.red, game = "roulette"},
        {text = "BLACKJACK", color = colors.orange, game = "blackjack"},
        {text = "BACCARAT", color = colors.pink, game = "baccarat"},

        -- Würfel & Münzen
        {text = "COIN FLIP", color = colors.blue, game = "coinflip"},
        {text = "DICE", color = colors.lime, game = "dice"},

        -- Kartenspiele
        {text = "HIGH/LOW", color = colors.lightBlue, game = "highlow"},
        {text = "WAR", color = colors.brown, game = "war"},

        -- Moderne Casino-Spiele
        {text = "CRASH", color = colors.red, game = "crash"},
        {text = "MINES", color = colors.gray, game = "mines"},
        {text = "TOWER", color = colors.cyan, game = "tower"},

        -- Spezial-Spiele
        {text = "PLINKO", color = colors.yellow, game = "plinko"},
        {text = "WHEEL OF FORTUNE", color = colors.orange, game = "wheel"},
        {text = "KENO", color = colors.green, game = "keno"},
        {text = "SCRATCH CARDS", color = colors.magenta, game = "scratch"},
        {text = "HORSE RACING", color = colors.lime, game = "horses"},

        -- System
        {text = "Diamanten Update", color = colors.yellow, game = "refresh"},
        {text = "Beenden", color = colors.red, game = "exit"}
    }

    local buttons = ui.drawMenu("", options, 7)

    local choice, button = ui.waitForTouch(buttons)
    return options[choice].game
end

-- ===== WELCOME SCREEN =====
local function showWelcomeScreen(ui)
    ui.clear()

    -- Großer Titel
    ui.drawBox(1, 1, ui.width, 3, colors.purple)
    ui.centerText(2, "*** CASINO ***", colors.yellow, colors.purple)

    sleep(0.5)

    -- Info
    local y = 5
    local info = {
        "Willkommen im Casino!",
        "",
        "16 spannende Spiele:",
        "Slots, Roulette, Blackjack, Baccarat",
        "Coin Flip, Dice, High/Low, War",
        "Crash, Mines, Tower, Plinko",
        "Wheel, Keno, Scratch, Horses",
        "",
        "Viel Glueck!"
    }

    for _, line in ipairs(info) do
        ui.centerText(y, line, colors.white)
        y = y + 1
    end

    sleep(3)
end

-- ===== HAUPT-PROGRAMM =====
local function main()
    -- Peripherie finden
    print("Suche Peripherie...")
    local peripherals = findPeripherals()

    -- Module laden
    print("Lade Module...")
    local modules = loadModules()

    -- UI initialisieren
    local ui = modules.UI.init(peripherals.monitor)

    -- Inventory initialisieren
    local inventory
    if peripherals.rsBridge then
        inventory = modules.Inventory.init(peripherals.rsBridge)
    else
        print("WARNUNG: RS Bridge nicht gefunden. Verwende Simple Mode.")
        inventory = modules.Inventory.initSimple()
        inventory.wrap()
    end

    -- Spiele initialisieren
    for gameName, game in pairs(modules.games) do
        game.init(ui, inventory)
    end

    -- Welcome Screen
    showWelcomeScreen(ui)

    -- Haupt-Loop
    while true do
        -- Player Detection
        local players = nil
        while not players do
            players = detectPlayers(peripherals.playerDetector, ui)
            if not players then
                sleep(2)
            end
        end

        -- Spieler auswählen
        local playerName = selectPlayer(players, ui)

        -- Diamanten-Balance
        local playerBalance = inventory.countDiamonds()

        if playerBalance <= 0 then
            ui.clear()
            ui.drawTitle("CASINO")
            ui.centerText(10, "Keine Diamanten vorhanden!", colors.red)
            ui.centerText(12, "Bitte Diamanten in Truhe legen.", colors.yellow)
            sleep(5)
        else
            -- Spiel-Loop für diesen Spieler
            local playing = true
            while playing do
                -- Hauptmenü
                local selectedGame = showMainMenu(ui, playerName, playerBalance)

                if selectedGame == "exit" then
                    playing = false
                elseif selectedGame == "refresh" then
                    playerBalance = inventory.countDiamonds()
                    ui.clear()
                    ui.drawTitle("CASINO")
                    ui.centerText(10, "Balance aktualisiert!", colors.lime)
                    ui.showDiamonds(playerBalance, math.floor(ui.width / 2) - 6, 12)
                    sleep(2)
                elseif modules.games[selectedGame] then
                    -- Spiel starten
                    playerBalance = modules.games[selectedGame].play(playerName, playerBalance)

                    -- Balance nach Spiel aktualisieren
                    if playerBalance <= 0 then
                        ui.clear()
                        ui.drawTitle("GAME OVER")
                        ui.centerText(10, "Keine Diamanten mehr!", colors.red)
                        ui.centerText(12, playerName .. ", komm bald wieder!", colors.yellow)
                        sleep(3)
                        playing = false
                    end
                end
            end
        end

        -- Abschied
        ui.clear()
        ui.drawTitle("CASINO")
        ui.centerText(10, "Auf Wiedersehen, " .. playerName .. "!", colors.yellow)
        ui.centerText(12, "Danke fuers Spielen!", colors.white)
        sleep(3)
    end
end

-- ===== ERROR HANDLING =====
local function safeMain()
    local success, err = pcall(main)

    if not success then
        -- Fehler auf Computer anzeigen
        term.clear()
        term.setCursorPos(1, 1)
        term.setTextColor(colors.red)
        print("FEHLER:")
        print(err)
        print("")
        print("Bitte Hardware pruefen:")
        print("- Monitor (rechts)")
        print("- Player Detector (oben)")
        print("- RS Bridge (unten)")
        print("- Double Chest (vorne)")
    end
end

-- ===== START =====
safeMain()

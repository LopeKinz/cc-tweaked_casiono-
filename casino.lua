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
    peripherals.rsBridge = peripheral.find("rs_bridge")

    -- Player Detector finden (auf dem Computer)
    peripherals.playerDetector = peripheral.find("player_detector")
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

    -- Database laden
    if not fs.exists("database.lua") then
        error("database.lua nicht gefunden!")
    end
    modules.Database = dofile("database.lua")

    -- Features laden
    if not fs.exists("features.lua") then
        error("features.lua nicht gefunden!")
    end
    modules.Features = dofile("features.lua")

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
local function showMainMenu(ui, playerName, balance, database)
    ui.clear()
    ui.drawTitle("CASINO - Hauptmenue")

    -- Spieler-Info mit Level
    local player = database.getPlayer(playerName)
    ui.drawText(2, 3, "Spieler: " .. playerName .. " | Level: " .. player.level, colors.white)
    ui.showDiamonds(balance, 2, 4)

    -- Jackpot-Anzeige
    local jackpot = database.getJackpot()
    ui.drawText(2, 5, "JACKPOT: " .. jackpot .. " Diamanten", colors.yellow)

    -- Kategorie-Menü
    local options = {
        {text = "SPIELE SPIELEN", color = colors.lime, game = "games_menu"},
        {text = "STATISTIKEN", color = colors.blue, game = "stats"},
        {text = "LEADERBOARD", color = colors.yellow, game = "leaderboard"},
        {text = "ACHIEVEMENTS", color = colors.purple, game = "achievements"},
        {text = "DAILY BONUS", color = colors.orange, game = "daily"},
        {text = "QUESTS", color = colors.cyan, game = "quests"},
        {text = "JACKPOT INFO", color = colors.yellow, game = "jackpot_info"},
        {text = "Diamanten Update", color = colors.lightGray, game = "refresh"},
        {text = "Beenden", color = colors.red, game = "exit"}
    }

    local buttons = ui.drawMenu("", options, 6)
    local choice, button = ui.waitForTouch(buttons)
    return options[choice].game
end

-- ===== SPIELE-MENÜ =====
local function showGamesMenu(ui)
    ui.clear()
    ui.drawTitle("SPIELE")

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

        -- Zurück
        {text = "Zurueck", color = colors.red, game = "back"}
    }

    local buttons = ui.drawMenu("", options, 5)
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

    -- Database initialisieren
    local database = modules.Database.init()

    -- Features initialisieren
    local features = modules.Features.init(ui, database)

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
                local selectedAction = showMainMenu(ui, playerName, playerBalance, database)

                if selectedAction == "exit" then
                    playing = false

                elseif selectedAction == "refresh" then
                    playerBalance = inventory.countDiamonds()
                    ui.clear()
                    ui.drawTitle("CASINO")
                    ui.centerText(10, "Balance aktualisiert!", colors.lime)
                    ui.showDiamonds(playerBalance, math.floor(ui.width / 2) - 6, 12)
                    sleep(2)

                elseif selectedAction == "games_menu" then
                    -- Spiele-Menü
                    local selectedGame = showGamesMenu(ui)

                    if selectedGame ~= "back" and modules.games[selectedGame] then
                        -- Spiel starten
                        local balanceBefore = playerBalance
                        playerBalance = modules.games[selectedGame].play(playerName, playerBalance)
                        local balanceAfter = playerBalance

                        -- Spiel-Ergebnis in Datenbank speichern
                        local bet = math.abs(balanceAfter - balanceBefore)
                        local won = balanceAfter > balanceBefore
                        local payout = won and (balanceAfter - balanceBefore) or 0

                        if bet > 0 then
                            database.recordGame(playerName, selectedGame, bet, won, payout)

                            -- Jackpot-Prüfung
                            local jackpotWon, jackpotAmount = database.checkJackpot()
                            if jackpotWon then
                                ui.clear()
                                ui.drawTitle("*** JACKPOT ***")
                                ui.centerText(10, "JACKPOT GEWONNEN!", colors.yellow)
                                ui.centerText(12, jackpotAmount .. " DIAMANTEN!", colors.lime)
                                sleep(5)
                                playerBalance = playerBalance + jackpotAmount
                            end

                            -- Achievement-Benachrichtigungen
                            local newAchievements = database.checkAchievements(playerName)
                            if #newAchievements > 0 then
                                ui.clear()
                                ui.drawTitle("ACHIEVEMENT FREIGESCHALTET!")
                                local y = 10
                                for _, achievement in ipairs(newAchievements) do
                                    ui.centerText(y, achievement, colors.lime)
                                    y = y + 2
                                end
                                sleep(3)
                            end
                        end

                        -- Balance nach Spiel prüfen
                        if playerBalance <= 0 then
                            ui.clear()
                            ui.drawTitle("GAME OVER")
                            ui.centerText(10, "Keine Diamanten mehr!", colors.red)
                            ui.centerText(12, playerName .. ", komm bald wieder!", colors.yellow)
                            sleep(3)
                            playing = false
                        end
                    end

                elseif selectedAction == "stats" then
                    features.showStats(playerName)

                elseif selectedAction == "leaderboard" then
                    features.showLeaderboard()

                elseif selectedAction == "achievements" then
                    features.showAchievements(playerName)

                elseif selectedAction == "daily" then
                    local bonus = features.showDailyBonus(playerName)
                    if bonus > 0 then
                        playerBalance = playerBalance + bonus
                    end

                elseif selectedAction == "quests" then
                    features.showQuests(playerName)

                elseif selectedAction == "jackpot_info" then
                    features.showJackpotInfo()
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

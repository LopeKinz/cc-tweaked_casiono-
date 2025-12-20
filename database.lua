-- Database System für Spieler-Daten
local Database = {}

local DATA_FILE = "casino_data.txt"
local BACKUP_FILE = "casino_data.backup.txt"

-- Datenbank initialisieren
function Database.init()
    Database.data = {
        players = {},
        jackpot = 100,  -- Start-Jackpot
        lastDailyReset = os.day()
    }

    -- Lade existierende Daten
    if fs.exists(DATA_FILE) then
        local file = fs.open(DATA_FILE, "r")
        local content = file.readAll()
        file.close()

        if content and content ~= "" then
            local loadedData = textutils.unserialize(content)

            -- Validiere geladene Daten
            if loadedData and type(loadedData) == "table" then
                -- Prüfe ob grundlegende Struktur vorhanden ist
                if loadedData.players and type(loadedData.players) == "table" then
                    Database.data = loadedData

                    -- Stelle sicher, dass alle erforderlichen Felder existieren
                    if not Database.data.jackpot then Database.data.jackpot = 100 end
                    if not Database.data.lastDailyReset then Database.data.lastDailyReset = os.day() end
                else
                    print("WARNUNG: Korrupte Datenbank - verwende Standard-Daten")
                end
            else
                print("WARNUNG: Ungültige Datenbank-Datei - verwende Standard-Daten")
            end
        end
    end

    return Database
end

-- Spieler-Daten laden oder erstellen
function Database.getPlayer(name)
    if not Database.data.players[name] then
        Database.data.players[name] = {
            name = name,
            totalGames = 0,
            totalWins = 0,
            totalLosses = 0,
            totalWagered = 0,
            totalWon = 0,
            biggestWin = 0,
            level = 1,
            xp = 0,
            achievements = {},
            lastDaily = 0,
            dailyStreak = 0,
            gameStats = {},  -- Pro-Spiel Statistiken
            history = {},
            quests = {}
        }
    end

    return Database.data.players[name]
end

-- Speichere alle Daten (mit Backup)
function Database.save()
    -- Erstelle Backup der aktuellen Datei vor dem Überschreiben
    if fs.exists(DATA_FILE) then
        if fs.exists(BACKUP_FILE) then
            fs.delete(BACKUP_FILE)
        end
        fs.copy(DATA_FILE, BACKUP_FILE)
    end

    -- Speichere neue Daten
    local file = fs.open(DATA_FILE, "w")
    file.write(textutils.serialize(Database.data))
    file.close()
end

-- Spiel-Ergebnis aufzeichnen
function Database.recordGame(playerName, gameName, bet, won, payout)
    local player = Database.getPlayer(playerName)

    -- Allgemeine Stats
    player.totalGames = player.totalGames + 1
    player.totalWagered = player.totalWagered + bet

    if won then
        player.totalWins = player.totalWins + 1
        player.totalWon = player.totalWon + payout

        if payout > player.biggestWin then
            player.biggestWin = payout
        end
    else
        player.totalLosses = player.totalLosses + 1
    end

    -- XP vergeben (1 XP pro Diamant Einsatz)
    Database.addXP(playerName, bet)

    -- Spiel-spezifische Stats
    if not player.gameStats[gameName] then
        player.gameStats[gameName] = {
            played = 0,
            wins = 0,
            losses = 0
        }
    end

    player.gameStats[gameName].played = player.gameStats[gameName].played + 1
    if won then
        player.gameStats[gameName].wins = player.gameStats[gameName].wins + 1
    else
        player.gameStats[gameName].losses = player.gameStats[gameName].losses + 1
    end

    -- History (nur letzte 20 Spiele)
    table.insert(player.history, 1, {
        game = gameName,
        bet = bet,
        won = won,
        payout = payout,
        time = os.time()
    })

    if #player.history > 20 then
        table.remove(player.history)
    end

    -- Jackpot erhöhen (5% vom Einsatz)
    Database.data.jackpot = Database.data.jackpot + math.floor(bet * 0.05)

    -- Quest-Fortschritt
    Database.updateQuestProgress(playerName, gameName, won)

    -- Achievement-Prüfung
    Database.checkAchievements(playerName)

    Database.save()
end

-- XP hinzufügen und Level-Up prüfen
function Database.addXP(playerName, amount)
    local player = Database.getPlayer(playerName)
    player.xp = player.xp + amount

    -- Level-Up-Berechnung (100 XP pro Level)
    local requiredXP = player.level * 100

    while player.xp >= requiredXP do
        player.xp = player.xp - requiredXP
        player.level = player.level + 1
        requiredXP = player.level * 100
    end
end

-- Daily Bonus prüfen
function Database.canClaimDaily(playerName)
    local player = Database.getPlayer(playerName)
    local currentDay = os.day()

    return player.lastDaily < currentDay
end

-- Daily Bonus beanspruchen
function Database.claimDaily(playerName)
    local player = Database.getPlayer(playerName)
    local currentDay = os.day()

    -- Streak prüfen
    if player.lastDaily == currentDay - 1 then
        player.dailyStreak = player.dailyStreak + 1
    else
        player.dailyStreak = 1
    end

    player.lastDaily = currentDay

    -- Bonus berechnen (5 + Streak-Bonus)
    local bonus = 5 + math.min(player.dailyStreak, 10)

    Database.save()
    return bonus, player.dailyStreak
end

-- Quest-Fortschritt aktualisieren
function Database.updateQuestProgress(playerName, gameName, won)
    local player = Database.getPlayer(playerName)

    -- Tägliche Quests erstellen wenn nötig
    if not player.quests.daily then
        Database.generateDailyQuests(playerName)
    end

    -- Fortschritt aktualisieren
    for _, quest in ipairs(player.quests.daily or {}) do
        if not quest.completed then
            if quest.type == "play_games" then
                quest.progress = quest.progress + 1
            elseif quest.type == "win_games" and won then
                quest.progress = quest.progress + 1
            elseif quest.type == "play_specific" and quest.game == gameName then
                quest.progress = quest.progress + 1
            end

            if quest.progress >= quest.required then
                quest.completed = true
            end
        end
    end
end

-- Tägliche Quests generieren
function Database.generateDailyQuests(playerName)
    local player = Database.getPlayer(playerName)

    player.quests.daily = {
        {
            type = "play_games",
            name = "Spiele 10 Runden",
            required = 10,
            progress = 0,
            reward = 10,
            completed = false
        },
        {
            type = "win_games",
            name = "Gewinne 5 Spiele",
            required = 5,
            progress = 0,
            reward = 15,
            completed = false
        },
        {
            type = "play_specific",
            name = "Spiele 3x Slots",
            game = "slots",
            required = 3,
            progress = 0,
            reward = 5,
            completed = false
        }
    }
end

-- Achievements prüfen
function Database.checkAchievements(playerName)
    local player = Database.getPlayer(playerName)

    local achievements = {
        {id = "first_win", name = "Erster Sieg", check = function() return player.totalWins >= 1 end},
        {id = "win_10", name = "10 Siege", check = function() return player.totalWins >= 10 end},
        {id = "win_50", name = "50 Siege", check = function() return player.totalWins >= 50 end},
        {id = "win_100", name = "100 Siege", check = function() return player.totalWins >= 100 end},
        {id = "games_100", name = "100 Spiele", check = function() return player.totalGames >= 100 end},
        {id = "big_win_50", name = "50x Gewinn", check = function() return player.biggestWin >= 50 end},
        {id = "big_win_100", name = "100x Gewinn", check = function() return player.biggestWin >= 100 end},
        {id = "level_5", name = "Level 5", check = function() return player.level >= 5 end},
        {id = "level_10", name = "Level 10", check = function() return player.level >= 10 end},
        {id = "streak_7", name = "7 Tage Streak", check = function() return player.dailyStreak >= 7 end}
    }

    local newAchievements = {}
    for _, achievement in ipairs(achievements) do
        if not player.achievements[achievement.id] and achievement.check() then
            player.achievements[achievement.id] = true
            table.insert(newAchievements, achievement.name)
        end
    end

    return newAchievements
end

-- Leaderboard abrufen
function Database.getLeaderboard(category, limit)
    limit = limit or 10

    local players = {}
    for name, player in pairs(Database.data.players) do
        table.insert(players, player)
    end

    -- Sortieren nach Kategorie
    if category == "wins" then
        table.sort(players, function(a, b) return a.totalWins > b.totalWins end)
    elseif category == "level" then
        table.sort(players, function(a, b) return a.level > b.level end)
    elseif category == "biggest_win" then
        table.sort(players, function(a, b) return a.biggestWin > b.biggestWin end)
    elseif category == "total_won" then
        table.sort(players, function(a, b) return a.totalWon > b.totalWon end)
    end

    -- Limitieren
    local result = {}
    for i = 1, math.min(limit, #players) do
        table.insert(result, players[i])
    end

    return result
end

-- Jackpot-Info
function Database.getJackpot()
    return Database.data.jackpot
end

-- Jackpot gewinnen (zufällig)
function Database.checkJackpot()
    -- 0.1% Chance pro Spiel
    if math.random(1000) == 1 then
        local amount = Database.data.jackpot
        Database.data.jackpot = 100  -- Reset auf Minimum
        Database.save()
        return true, amount
    end
    return false, 0
end

-- Spieler-Rang berechnen
function Database.getPlayerRank(playerName, category)
    local leaderboard = Database.getLeaderboard(category, 1000)

    for i, player in ipairs(leaderboard) do
        if player.name == playerName then
            return i
        end
    end

    return #leaderboard + 1
end

return Database

-- Casino Features (Leaderboard, Stats, Achievements, etc.)
local Features = {}

-- Initialisierung
function Features.init(ui, database)
    Features.ui = ui
    Features.db = database
    return Features
end

-- ===== LEADERBOARD =====
function Features.showLeaderboard()
    while true do
        Features.ui.clear()
        Features.ui.drawTitle("LEADERBOARD")

        -- Kategorie wählen
        local options = {
            {text = "Top Gewinner (Total)", category = "total_won", color = colors.yellow},
            {text = "Meiste Siege", category = "wins", color = colors.lime},
            {text = "Hoechste Level", category = "level", color = colors.purple},
            {text = "Groesster Gewinn", category = "biggest_win", color = colors.orange},
            {text = "Zurueck", category = nil, color = colors.red}
        }

        local buttons = Features.ui.drawMenu("", options, 7)
        local choice, button = Features.ui.waitForTouch(buttons)

        if choice == #buttons then
            return
        end

        local category = options[choice].category
        Features.showLeaderboardCategory(category, options[choice].text)
    end
end

function Features.showLeaderboardCategory(category, title)
    Features.ui.clear()
    Features.ui.drawTitle("LEADERBOARD - " .. title)

    local leaderboard = Features.db.getLeaderboard(category, 10)

    local y = 7
    for i, player in ipairs(leaderboard) do
        local text = ""
        local medal = i == 1 and "1." or (i == 2 and "2." or (i == 3 and "3." or tostring(i) .. "."))

        if category == "wins" then
            text = medal .. " " .. player.name .. " - " .. player.totalWins .. " Siege"
        elseif category == "level" then
            text = medal .. " " .. player.name .. " - Level " .. player.level
        elseif category == "biggest_win" then
            text = medal .. " " .. player.name .. " - " .. player.biggestWin .. " Diamanten"
        elseif category == "total_won" then
            text = medal .. " " .. player.name .. " - " .. player.totalWon .. " Diamanten"
        end

        local color = i == 1 and colors.yellow or (i == 2 and colors.orange or (i == 3 and colors.brown or colors.white))
        Features.ui.centerText(y, text, color)
        y = y + 2
    end

    -- Zurück Button
    local backButton = Features.ui.drawButton(
        math.floor(Features.ui.width / 2) - 10,
        Features.ui.height - 3,
        20, 3,
        "Zurueck",
        colors.red,
        colors.white
    )

    Features.ui.waitForTouch({backButton})
end

-- ===== STATISTIKEN =====
function Features.showStats(playerName)
    Features.ui.clear()
    Features.ui.drawTitle("STATISTIKEN - " .. playerName)

    local player = Features.db.getPlayer(playerName)

    local y = 5

    -- Level und XP
    Features.ui.centerText(y, "Level: " .. player.level .. " | XP: " .. player.xp .. "/" .. (player.level * 100), colors.yellow)
    y = y + 2

    -- Allgemeine Stats
    local stats = {
        "Spiele gesamt: " .. player.totalGames,
        "Siege: " .. player.totalWins .. " | Verluste: " .. player.totalLosses,
        "Gewinnrate: " .. (player.totalGames > 0 and math.floor((player.totalWins / player.totalGames) * 100) or 0) .. "%",
        "",
        "Eingesetzt: " .. player.totalWagered .. " Diamanten",
        "Gewonnen: " .. player.totalWon .. " Diamanten",
        "Profit: " .. (player.totalWon - player.totalWagered) .. " Diamanten",
        "",
        "Groesster Gewinn: " .. player.biggestWin .. " Diamanten",
        "Daily Streak: " .. player.dailyStreak .. " Tage"
    }

    for _, stat in ipairs(stats) do
        Features.ui.centerText(y, stat, colors.white)
        y = y + 1
    end

    -- Rang
    y = y + 1
    local rank = Features.db.getPlayerRank(playerName, "total_won")
    Features.ui.centerText(y, "Dein Rang: #" .. rank, colors.lime)

    -- Buttons
    local detailsButton = Features.ui.drawButton(
        math.floor(Features.ui.width / 2) - 28,
        Features.ui.height - 3,
        18, 3,
        "Spiel-Stats",
        colors.blue,
        colors.white
    )

    local historyButton = Features.ui.drawButton(
        math.floor(Features.ui.width / 2) - 8,
        Features.ui.height - 3,
        18, 3,
        "Verlauf",
        colors.purple,
        colors.white
    )

    local backButton = Features.ui.drawButton(
        math.floor(Features.ui.width / 2) + 12,
        Features.ui.height - 3,
        18, 3,
        "Zurueck",
        colors.red,
        colors.white
    )

    local choice, button = Features.ui.waitForTouch({detailsButton, historyButton, backButton})

    if choice == 1 then
        Features.showGameStats(playerName)
    elseif choice == 2 then
        Features.showHistory(playerName)
    end
end

-- Spiel-spezifische Statistiken
function Features.showGameStats(playerName)
    Features.ui.clear()
    Features.ui.drawTitle("SPIEL-STATISTIKEN")

    local player = Features.db.getPlayer(playerName)

    local y = 5

    for gameName, stats in pairs(player.gameStats) do
        local winRate = stats.played > 0 and math.floor((stats.wins / stats.played) * 100) or 0

        Features.ui.centerText(y, gameName:upper(), colors.yellow)
        y = y + 1
        Features.ui.centerText(y, stats.played .. " Spiele | " .. stats.wins .. " Siege | " .. winRate .. "%", colors.white)
        y = y + 2
    end

    -- Zurück
    local backButton = Features.ui.drawButton(
        math.floor(Features.ui.width / 2) - 10,
        Features.ui.height - 3,
        20, 3,
        "Zurueck",
        colors.red,
        colors.white
    )

    Features.ui.waitForTouch({backButton})
    Features.showStats(playerName)
end

-- Spiel-Verlauf
function Features.showHistory(playerName)
    Features.ui.clear()
    Features.ui.drawTitle("VERLAUF - Letzte 10 Spiele")

    local player = Features.db.getPlayer(playerName)

    local y = 6

    for i = 1, math.min(10, #player.history) do
        local entry = player.history[i]

        local result = entry.won and ("+" .. entry.payout) or ("-" .. entry.bet)
        local color = entry.won and colors.lime or colors.red

        Features.ui.centerText(y, entry.game:upper() .. " | " .. result .. " Diamanten", color)
        y = y + 1
    end

    -- Zurück
    local backButton = Features.ui.drawButton(
        math.floor(Features.ui.width / 2) - 10,
        Features.ui.height - 3,
        20, 3,
        "Zurueck",
        colors.red,
        colors.white
    )

    Features.ui.waitForTouch({backButton})
    Features.showStats(playerName)
end

-- ===== ACHIEVEMENTS =====
function Features.showAchievements(playerName)
    Features.ui.clear()
    Features.ui.drawTitle("ACHIEVEMENTS")

    local player = Features.db.getPlayer(playerName)

    local allAchievements = {
        {id = "first_win", name = "Erster Sieg", desc = "Gewinne dein erstes Spiel"},
        {id = "win_10", name = "10 Siege", desc = "Gewinne 10 Spiele"},
        {id = "win_50", name = "50 Siege", desc = "Gewinne 50 Spiele"},
        {id = "win_100", name = "100 Siege", desc = "Gewinne 100 Spiele"},
        {id = "games_100", name = "100 Spiele", desc = "Spiele 100 Runden"},
        {id = "big_win_50", name = "Grossgewinn", desc = "Gewinne 50+ Diamanten"},
        {id = "big_win_100", name = "Mega-Gewinn", desc = "Gewinne 100+ Diamanten"},
        {id = "level_5", name = "Level 5", desc = "Erreiche Level 5"},
        {id = "level_10", name = "Level 10", desc = "Erreiche Level 10"},
        {id = "streak_7", name = "Treuer Spieler", desc = "7 Tage Daily Streak"}
    }

    local y = 5
    local unlocked = 0

    for _, achievement in ipairs(allAchievements) do
        local hasIt = player.achievements[achievement.id]

        if hasIt then
            unlocked = unlocked + 1
        end

        local color = hasIt and colors.lime or colors.gray
        local icon = hasIt and "[X]" or "[ ]"

        Features.ui.centerText(y, icon .. " " .. achievement.name, color)
        y = y + 1
        Features.ui.centerText(y, achievement.desc, colors.lightGray)
        y = y + 2
    end

    -- Fortschritt
    Features.ui.centerText(Features.ui.height - 5, unlocked .. "/" .. #allAchievements .. " freigeschaltet", colors.yellow)

    -- Zurück
    local backButton = Features.ui.drawButton(
        math.floor(Features.ui.width / 2) - 10,
        Features.ui.height - 3,
        20, 3,
        "Zurueck",
        colors.red,
        colors.white
    )

    Features.ui.waitForTouch({backButton})
end

-- ===== DAILY BONUS =====
function Features.showDailyBonus(playerName)
    Features.ui.clear()
    Features.ui.drawTitle("DAILY BONUS")

    if Features.db.canClaimDaily(playerName) then
        Features.ui.centerText(10, "Taeglich kostenlose Diamanten!", colors.yellow)
        Features.ui.centerText(12, "Komm jeden Tag fuer Bonus-Streak!", colors.white)

        local claimButton = Features.ui.drawButton(
            math.floor(Features.ui.width / 2) - 12,
            16,
            25, 4,
            "BONUS ABHOLEN",
            colors.lime,
            colors.white
        )

        local backButton = Features.ui.drawButton(
            math.floor(Features.ui.width / 2) - 10,
            22,
            20, 3,
            "Zurueck",
            colors.red,
            colors.white
        )

        local choice, button = Features.ui.waitForTouch({claimButton, backButton})

        if choice == 1 then
            local bonus, streak = Features.db.claimDaily(playerName)

            Features.ui.clear()
            Features.ui.drawTitle("DAILY BONUS")

            Features.ui.centerText(10, "+" .. bonus .. " DIAMANTEN!", colors.lime)
            Features.ui.centerText(12, "Streak: " .. streak .. " Tage", colors.yellow)
            Features.ui.centerText(14, "Komm morgen wieder!", colors.white)

            sleep(3)
            return bonus
        end
    else
        Features.ui.centerText(10, "Daily Bonus bereits abgeholt!", colors.red)
        Features.ui.centerText(12, "Komm morgen wieder!", colors.white)

        local backButton = Features.ui.drawButton(
            math.floor(Features.ui.width / 2) - 10,
            16,
            20, 3,
            "Zurueck",
            colors.red,
            colors.white
        )

        Features.ui.waitForTouch({backButton})
    end

    return 0
end

-- ===== QUESTS =====
function Features.showQuests(playerName)
    Features.ui.clear()
    Features.ui.drawTitle("TÄGLICHE QUESTS")

    local player = Features.db.getPlayer(playerName)

    if not player.quests.daily then
        Features.db.generateDailyQuests(playerName)
        player = Features.db.getPlayer(playerName)
    end

    local y = 8
    local allCompleted = true

    for _, quest in ipairs(player.quests.daily) do
        local color = quest.completed and colors.lime or colors.white
        local icon = quest.completed and "[X]" or "[ ]"

        Features.ui.centerText(y, icon .. " " .. quest.name, color)
        y = y + 1

        local progress = quest.progress .. "/" .. quest.required
        Features.ui.centerText(y, progress .. " | Belohnung: " .. quest.reward .. " Diamanten", colors.gray)
        y = y + 3

        if not quest.completed then
            allCompleted = false
        end
    end

    if allCompleted then
        Features.ui.centerText(y, "Alle Quests abgeschlossen!", colors.lime)
    end

    -- Zurück
    local backButton = Features.ui.drawButton(
        math.floor(Features.ui.width / 2) - 10,
        Features.ui.height - 3,
        20, 3,
        "Zurueck",
        colors.red,
        colors.white
    )

    Features.ui.waitForTouch({backButton})
end

-- ===== JACKPOT INFO =====
function Features.showJackpotInfo()
    Features.ui.clear()
    Features.ui.drawTitle("JACKPOT")

    local jackpot = Features.db.getJackpot()

    Features.ui.centerText(10, "Aktueller Jackpot:", colors.white)
    Features.ui.centerText(12, jackpot .. " DIAMANTEN", colors.yellow)
    Features.ui.centerText(15, "0.1% Chance bei jedem Spiel!", colors.white)
    Features.ui.centerText(17, "Jackpot waechst mit jedem Einsatz!", colors.gray)

    local backButton = Features.ui.drawButton(
        math.floor(Features.ui.width / 2) - 10,
        22,
        20, 3,
        "Zurueck",
        colors.red,
        colors.white
    )

    Features.ui.waitForTouch({backButton})
end

return Features

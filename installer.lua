-- Casino Installer
-- Automatische Installation aller Casino-Dateien

local REPO_URL = "https://raw.githubusercontent.com/LopeKinz/cc-tweaked_casiono-/main/"

local files = {
    "casino.lua",
    "ui.lua",
    "inventory.lua",
    "database.lua",
    "features.lua",
    "startup.lua",
    "games/slots.lua",
    "games/roulette.lua",
    "games/blackjack.lua",
    "games/baccarat.lua",
    "games/coinflip.lua",
    "games/dice.lua",
    "games/highlow.lua",
    "games/war.lua",
    "games/crash.lua",
    "games/mines.lua",
    "games/tower.lua",
    "games/plinko.lua",
    "games/wheel.lua",
    "games/keno.lua",
    "games/scratch.lua",
    "games/horses.lua"
}

-- Farben
local colors = {
    success = colors.lime,
    error = colors.red,
    info = colors.yellow,
    text = colors.white
}

-- Funktion zum Herunterladen einer Datei
local function downloadFile(url, path)
    local response = http.get(url)

    if response then
        local content = response.readAll()
        response.close()

        local file = fs.open(path, "w")
        file.write(content)
        file.close()

        return true
    end

    return false
end

-- Funktion zum Erstellen von Verzeichnissen
local function ensureDirectory(dir)
    if not fs.exists(dir) then
        fs.makeDir(dir)
    end
end

-- Hauptinstallation
local function install()
    term.clear()
    term.setCursorPos(1, 1)

    -- Titel
    term.setTextColor(colors.yellow)
    print("╔════════════════════════════════════════╗")
    print("║   CASINO INSTALLER                     ║")
    print("║   Minecraft 1.21.1 - CC:Tweaked        ║")
    print("╚════════════════════════════════════════╝")
    print("")

    term.setTextColor(colors.text)
    print("Dieser Installer wird alle Casino-Dateien")
    print("automatisch herunterladen und einrichten.")
    print("")
    print("Benoetigte Komponenten:")
    print("- HTTP API muss aktiviert sein")
    print("- Internet-Verbindung")
    print("")

    term.setTextColor(colors.info)
    write("Fortfahren? (j/n): ")
    term.setTextColor(colors.text)

    local input = read()
    if input ~= "j" and input ~= "J" then
        print("")
        print("Installation abgebrochen.")
        return
    end

    -- Prüfe HTTP
    if not http then
        term.setTextColor(colors.error)
        print("")
        print("FEHLER: HTTP API ist nicht aktiviert!")
        print("Bitte aktiviere HTTP in der CC:Tweaked Config.")
        return
    end

    print("")
    term.setTextColor(colors.info)
    print("Starte Installation...")
    print("")

    -- Erstelle Verzeichnisse
    term.setTextColor(colors.text)
    print("[1/3] Erstelle Verzeichnisse...")
    ensureDirectory("games")
    term.setTextColor(colors.success)
    print("      ✓ Verzeichnisse erstellt")
    print("")

    -- Download Dateien
    term.setTextColor(colors.text)
    print("[2/3] Lade Dateien herunter...")
    print("")

    local successCount = 0
    local failCount = 0

    for i, file in ipairs(files) do
        write("      [" .. i .. "/" .. #files .. "] " .. file .. "... ")

        local url = REPO_URL .. file
        local success = downloadFile(url, file)

        if success then
            term.setTextColor(colors.success)
            print("✓")
            successCount = successCount + 1
        else
            term.setTextColor(colors.error)
            print("✗")
            failCount = failCount + 1
        end

        term.setTextColor(colors.text)
    end

    print("")

    -- Zusammenfassung
    term.setTextColor(colors.text)
    print("[3/3] Installation abgeschlossen!")
    print("")

    if failCount == 0 then
        term.setTextColor(colors.success)
        print("✓ Alle " .. successCount .. " Dateien erfolgreich installiert!")
    else
        term.setTextColor(colors.info)
        print("⚠ " .. successCount .. " Dateien installiert, " .. failCount .. " fehlgeschlagen")
        print("")
        print("Fehlgeschlagene Dateien koennen manuell")
        print("heruntergeladen werden von:")
        print(REPO_URL)
    end

    print("")
    term.setTextColor(colors.text)
    print("═══════════════════════════════════════════")
    print("")
    print("Installation abgeschlossen!")
    print("")
    print("Naechste Schritte:")
    print("")
    print("1. Baue die Hardware auf:")
    print("   - 1x Advanced Computer")
    print("   - 20x Advanced Monitor (rechts)")
    print("   - 1x RS Bridge (unten)")
    print("   - 1x Player Detector (oben)")
    print("   - 1x Double Chest (vorne)")
    print("")
    print("2. Starte das Casino:")
    term.setTextColor(colors.info)
    print("   casino")
    print("")
    term.setTextColor(colors.text)
    print("3. Optional: Auto-Start einrichten")
    print("   (bereits als startup.lua installiert)")
    print("")
    print("═══════════════════════════════════════════")
    print("")
    term.setTextColor(colors.lime)
    print("Viel Erfolg mit deinem Casino! 🎰")
    term.setTextColor(colors.text)
end

-- Alternative: Manuelle Installation
local function manualInstall()
    term.clear()
    term.setCursorPos(1, 1)

    term.setTextColor(colors.yellow)
    print("╔════════════════════════════════════════╗")
    print("║   MANUELLE INSTALLATION                ║")
    print("╚════════════════════════════════════════╝")
    print("")

    term.setTextColor(colors.text)
    print("Fuer manuelle Installation:")
    print("")
    print("1. Erstelle das games-Verzeichnis:")
    term.setTextColor(colors.info)
    print("   mkdir games")
    print("")
    term.setTextColor(colors.text)
    print("2. Kopiere alle Dateien in den Computer")
    print("")
    print("3. Benoetigte Dateien:")
    print("")

    for _, file in ipairs(files) do
        print("   - " .. file)
    end

    print("")
    print("Alternativ: Nutze den automatischen")
    print("Installer mit HTTP-Zugriff.")
end

-- Hauptmenü
local function main()
    term.clear()
    term.setCursorPos(1, 1)

    term.setTextColor(colors.yellow)
    print("╔════════════════════════════════════════╗")
    print("║      MINECRAFT CASINO INSTALLER        ║")
    print("║   16 Spiele + Progression-System       ║")
    print("╚════════════════════════════════════════╝")
    print("")

    term.setTextColor(colors.text)
    print("Waehle Installations-Methode:")
    print("")
    print("1. Automatisch (empfohlen)")
    print("   - Benoetigt HTTP-Zugriff")
    print("   - Laedt automatisch alle Dateien")
    print("")
    print("2. Manuell")
    print("   - Anleitung fuer manuelle Installation")
    print("")
    print("3. Abbrechen")
    print("")

    term.setTextColor(colors.info)
    write("Auswahl (1-3): ")
    term.setTextColor(colors.text)

    local choice = read()

    if choice == "1" then
        install()
    elseif choice == "2" then
        manualInstall()
    else
        print("")
        print("Installation abgebrochen.")
    end
end

-- Programm starten
main()

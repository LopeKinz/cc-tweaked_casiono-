-- Casino Auto-Start
-- Diese Datei startet das Casino automatisch beim Booten

print("Starte Casino...")
sleep(1)

-- Casino-Programm starten
if fs.exists("casino.lua") then
    shell.run("casino.lua")
else
    term.setTextColor(colors.red)
    print("FEHLER: casino.lua nicht gefunden!")
    print("Bitte alle Dateien installieren.")
end

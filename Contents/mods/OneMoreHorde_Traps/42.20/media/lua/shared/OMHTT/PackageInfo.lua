local Foundation = require("OMHTT/Foundation")

---@return nil
local function reportPackages()
    local active = getActivatedMods()
    print("[OMHTT] packages-ready version=" .. Foundation.VERSION
        .. " traps=" .. tostring(active:contains("OneMoreHorde_Traps"))
        .. " turrets=" .. tostring(active:contains("OneMoreHorde_Turrets"))
        .. " game=" .. getCore():getVersionNumber())
end

Events.OnGameStart.Add(reportPackages)
Events.OnServerStarted.Add(reportPackages)

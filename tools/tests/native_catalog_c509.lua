-- Real item scripts, Java inventory objects and effective stats; no connected clients.
local function run()
    local T = require("OMHTT/Turret")
    local Heads = require("OMHTT/TurretHeads")
    local Stats = require("OMHTT/TurretStats")
    local Firearms = require("OMHTT/Firearms")
    local types = {T.HEAD, "Base.Pistol", "Base.Shotgun", "Base.HuntingRifle"}
    for name in pairs(Heads.definitions) do types[#types + 1] = name end
    local cells, accepted, modules = 0, 0, 0
    for name, fullType in pairs(T.TYPES) do
        local item = instanceItem(fullType)
        assert(item and T.component(item:getFullType()) == name, "C509 native module identity: " .. name)
        modules = modules + 1
    end
    for i = 1, #types do
        local head = instanceItem(types[i])
        assert(head, "C509 native head missing: " .. types[i])
        local firearm = Firearms.profile(head)
        for module in pairs(T.MODULES) do
            local supported = Heads.supports(head, module)
            local stats = Stats.resolve({head = head, active = supported and {[module] = 1} or {}, powerLoad = supported and 1 or 0})
            assert(stats.damage >= 0 and stats.damage == stats.damage and stats.range > 0,
                "C509 invalid native stats: " .. types[i] .. " / " .. module)
            assert((firearm ~= nil) == (stats.firearm == true), "C509 firearm classification mismatch")
            cells = cells + 1
            if supported then accepted = accepted + 1 end
        end
    end
    assert(#types == 10 and modules == 36 and cells == 360, "C509 catalog coverage changed")
    print("[OMHTT-C509] native-catalog heads=" .. #types .. " modules=" .. modules .. " cells=" .. cells .. " compatible=" .. accepted .. " clients=0 firing=false")
end
return run

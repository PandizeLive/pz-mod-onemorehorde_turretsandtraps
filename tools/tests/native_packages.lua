local expectedTraps = EXPECT_TRAPS
local expectedTurrets = EXPECT_TURRETS

---@return nil
local function checkPackages()
    local active = getActivatedMods()
    assert(active:contains("OneMoreHorde_Traps") == expectedTraps, "Unexpected Traps dependency")
    assert(active:contains("OneMoreHorde_Turrets") == expectedTurrets, "Unexpected Turrets dependency")
    assert(not active:contains("OneMoreHorde_TurretsAndTraps"), "Retired combined ID loaded")
    local items, counts = getScriptManager():getAllItems(), {}
    for i = 0, items:size() - 1 do
        local name = items:get(i):getFullName()
        counts[name] = (counts[name] or 0) + 1
    end
    assert((counts["Base.OMHTTTrapSpikeBarrier"] == 1) == expectedTraps, "Barrier item registration")
    assert((counts["Base.OMHTTTrapConcertinaWire"] == 1) == expectedTraps, "Wire item isolation")
    assert((SpriteConfigManager.GetObjectInfo("OMHTTDeployConcertinaWire") ~= nil) == expectedTraps, "Wire placement isolation")
    assert((counts["Base.OMHTTTrapBedSpikes"] == 1) == expectedTraps, "Bed Spikes item registration")
    assert((counts["Base.OMHTTTrapBedSpikesReinforced"] == 1) == expectedTraps, "Reinforced Bed Spikes item registration")
    assert((counts["Base.OMHTTTurretBase"] == 1) == expectedTurrets, "Turret item registration")
    assert((counts["Base.OMHTTModuleFiring"] == 1) == expectedTurrets, "Module item registration")
    assert((counts["Base.OMHTTModulePack"] == 1) == expectedTurrets, "Module pack item isolation")
    assert((OMHTT_Turret ~= nil) == expectedTurrets, "Turret runtime isolation")
    assert((OMHTT_BarbSections ~= nil) == expectedTraps, "Barb runtime isolation")
    assert((SpriteConfigManager.GetObjectInfo("OMHTTBarbs") ~= nil) == expectedTraps, "Barb recipe isolation")
    assert(counts["Base.OMHTTTrapController"] == 1 and counts["Base.OMHTTTrapPressurePlate"] == 1 and counts["Base.OMHTTTrapButton"] == 1, "Shared control items must register once")
    assert(OMHTT_ControlWorld and OMHTTControlAction and OMHTTControlTransferAction, "Shared control authority missing")
    local plateInfo = SpriteConfigManager.GetObjectInfo("OMHTTDeployInsetPlate")
    assert(plateInfo and plateInfo:getScript(), "Independent package missing inset plate placement")
    local buttonInfo = SpriteConfigManager.GetObjectInfo("OMHTTDeploySwitchButton")
    assert(buttonInfo and buttonInfo:getScript(), "Independent package missing switch Button placement")
    local plateSquare = IsoGridSquare.new(getCell(), nil, 26, 26, 0)
    local plate = IsoThumpable.new(getCell(), plateSquare, "floors_interior_tilesandwood_01_40", false)
    plateSquare:getObjects():add(plate)
    GameEntityFactory.CreateIsoObjectEntity(plate, SpriteConfigManager.GetObjectInfo("OMHTTDeployPlate"):getScript():getParent(), true)
    local plateState = OMHTT_ControlWorld.register(plate, {getUsername=function() return "package-probe" end}, "Plate")
    local platePrefix = expectedTurrets and "omhtt_turret_01_" or "omhtt_barrier_01_"
    local plateFirst = expectedTurrets and 25 or 80
    assert(plate:getSpriteName() == platePrefix .. plateFirst and not plate:isThumpable(), "Independent plate visual/passive migration failed")
    plateState.active = true
    OMHTT_ControlWorld.plateSprite(plate, plateState, false)
    assert(plate:getSpriteName() == platePrefix .. (plateFirst + 4), "Independent package missing pressed plate state")
    OMHTT_ControlWorld.removed(plate)
    local options, names = getSandboxOptions(), {}
    for i = 0, options:getNumOptions() - 1 do
        local name = options:getOptionByIndex(i):getName()
        assert(not names[name], "Duplicate Sandbox option " .. name)
        names[name] = true
    end
    assert((names["OMHTurretsTraps.SpikeBarrier"] == true) == expectedTraps, "Trap settings isolation")
    assert((names["OMHTurretsTraps.BedSpikes"] == true) == expectedTraps, "Bed settings isolation")
    assert((names["OMHTurretsTraps.BarbWire"] == true) == expectedTraps, "Wire settings isolation")
    assert((names["OMHTurretsTraps.BarbSections"] == true) == expectedTraps, "Barb settings isolation")
    assert((names["OMHTurretsTraps.ShowCollision"] == true) == expectedTraps, "Trap debug isolation")
    assert((names["OMHTurretsTraps.PotatoTurret"] == true) == expectedTurrets, "Turret settings isolation")
    assert((names["OMHTurretsTraps.ModuleLootRate"] == true) == expectedTurrets, "Loot settings isolation")
    assert((names["OMHTurretsTraps.PackZombieChance"] == true) == expectedTurrets, "Pack settings isolation")
    local oldServer, oldClient = isServer, isClient
    isServer = function() return false end
    isClient = function() return false end
    if expectedTurrets then
        local T = require("OMHTT/Turret")
        local oldTraps = SandboxVars.OMHTurretsTraps.Enabled
        SandboxVars.OMHTurretsTraps.Enabled = false
        assert(T.enabled(), "Trap master disables turrets")
        SandboxVars.OMHTurretsTraps.TurretsEnabled = false
        assert(not T.enabled(), "Turret master ineffective")
        SandboxVars.OMHTurretsTraps.TurretsEnabled = true
        SandboxVars.OMHTurretsTraps.Enabled = oldTraps
        require("OMHTT/ModuleLoot").loaded()
    end
    local lootCount, packCount = 0, 0
    for _, pool in pairs(ProceduralDistributions.list) do
        for i = 1, #pool.items, 2 do
            if pool.items[i] == "Base.OMHTTModulePack" then
                packCount = packCount + 1
            elseif string.sub(pool.items[i], 1, 10) == "Base.OMHTT" then
                lootCount = lootCount + 1
            end
        end
    end
    assert(lootCount == (expectedTurrets and 233 or 0), "Wrong component loot count " .. lootCount)
    assert(packCount == (expectedTurrets and 16 or 0), "Wrong pack loot count " .. packCount)
    isServer, isClient = oldServer, oldClient
    print("[OMHTT-Packages] PASS traps=" .. tostring(expectedTraps) .. " turrets=" .. tostring(expectedTurrets)
        .. " loot=" .. lootCount .. " options=unique entries=independent")
end

Events.OnServerStarted.Add(checkPackages)

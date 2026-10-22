local T = require("OMHTT/Turret")
local W = require("OMHTT/TurretWorld")

local function verifyTurrets()
    local serverFunction, clientFunction = isServer, isClient
    isServer = function() return false end
    isClient = function() return false end
    SandboxVars.OMHTurretsTraps.Enabled = true
    SandboxVars.OMHTurretsTraps.PotatoTurret = true
    local atlas = getDebugOptions():getOptionByName("WorldItemAtlas.Enable")
    local oldValue, oldDefault = atlas:getValueAsString() == "true", atlas:getDefaultValue()
    atlas:setValue(false)
    atlas:setDefaultToCurrentValue()
    assert(not atlas:getValue(), "Atlas bypass is ineffective outside debug")
    atlas:setValue(oldDefault)
    atlas:setDefaultToCurrentValue()
    atlas:setValue(oldValue)
    assert(atlas:getDefaultValue() == oldDefault and (atlas:getValueAsString() == "true") == oldValue, "Atlas option restore failed")
    print("[OMHTT-Smoke] native-atlas-lua bypass=verified restore=verified")
    local Accuracy = require("OMHTT/FirearmAccuracy")
    assert(type(GameTime.isGamePaused()) == "boolean", "Native pause API unavailable")
    OMHTT_AccuracyProbe = {}
    assert(CombatManager == nil, "CombatManager unexpectedly exposed; review direct helper use")
    for _, distance in pairs({0.5, 2, 3, 6, 10, 15, 30, 40}) do
        for _, prone in pairs({false, true}) do
            OMHTT_AccuracyProbe[#OMHTT_AccuracyProbe + 1] = {distance = distance, prone = prone,
                sightless = Accuracy.sightless(distance, prone), sights = Accuracy.sights(distance, 2, 10)}
        end
    end
    print("[OMHTT-Smoke] distance-accuracy samples=16 config=native")
    local player = IsoPlayer.new(getCell())
    local capacityItem = instanceItem(T.BASE)
    T.configure(capacityItem:getInventory())
    assert(capacityItem:getCapacity() == 44 and capacityItem:getInventory():getCapacity() == 44, "Carried capacity must subtract six-unit base weight")
    assert(capacityItem:getActualWeight() == 6, "Capacity correction must not reduce turret weight")
    print("[OMHTT-Smoke] native-turret-capacity carried=44 baseWeight=6")
    local Pack = require("OMHTT/TurretModulePack")
    OMHTT_NativeModulePack = instanceItem(Pack.TYPE)
    OMHTT_NativeModulePack:getModData().OMHTTPackRewards = {"Regulator", "CapacityLarge", "Regulator"}
    local pack = instanceItem(Pack.TYPE)
    assert(pack and math.abs(pack:getActualWeight() - 0.2) < .000001, "Native module pack script/weight missing")
    player:getInventory():AddItem(pack)
    pack:getModData().OMHTTPackRewards = {"Regulator", "CapacityLarge", "Regulator"}
    local rewards = Pack.open(player, pack)
    assert(rewards and #rewards == 3 and not player:getInventory():contains(pack), "Native pack exchange failed")
    assert(rewards[1] ~= rewards[3] and rewards[1]:getID() ~= rewards[3]:getID(), "Native pack reused a reward identity")
    for i = 1, #rewards do assert(T.component(rewards[i]:getFullType()), "Native pack reward is not a registered component") end
    assert(Pack.open(player, pack) == nil, "Native pack double completion")
    for i = 1, #rewards do assert(player:getInventory():contains(rewards[i])); player:getInventory():Remove(rewards[i]) end
    require("OMHTT/TurretPackLoot")
    local priorChance = SandboxVars.OMHTurretsTraps.PackZombieChance
    SandboxVars.OMHTurretsTraps.PackZombieChance = 100
    local corpseSource = IsoZombie.new(getCell())
    local before = corpseSource:getInventory():getItems():size()
    Pack.onDeath(corpseSource); Pack.onDeath(corpseSource)
    assert(corpseSource:getInventory():getItems():size() == before + 1, "Native corpse pack must be inserted once")
    SandboxVars.OMHTurretsTraps.PackZombieChance = priorChance
    print("[OMHTT-Smoke] native-module-pack rewards=3 duplicates=distinct expansion=valid repeat=blocked corpse=once")
    local Modules = require("OMHTT/TurretModules")
    local Loot = require("OMHTT/ModuleLoot")
    assert(getSandboxOptions():getOptionByName("OMHTurretsTraps.ModuleLootRate"):getDefaultValue() == Loot.DEFAULTS.global, "Native global loot default drift")
    SandboxVars.OMHTurretsTraps.ModuleLootRate = Loot.DEFAULTS.global
    for kind, value in pairs(Loot.DEFAULTS.items) do
        assert(getSandboxOptions():getOptionByName("OMHTurretsTraps.LootRate" .. kind):getDefaultValue() == value, "Native component loot default drift: " .. kind)
        SandboxVars.OMHTurretsTraps["LootRate" .. kind] = value
    end
    Loot.loaded()
    local count = 0
    for i = 1, #Loot.POOLS do
        local items = ProceduralDistributions.list[Loot.POOLS[i]].items
        local packs = 0
        for n = 1, #items, 2 do
            if items[n] == Pack.TYPE then
                packs = packs + 1
                assert(math.abs(items[n + 1] - Loot.DEFAULTS.global * Loot.SCALES[Loot.POOLS[i]]) < .000001, "Native pack weight mismatch")
            end
            if require("OMHTT/Turret").component(items[n]) then
                assert(instanceItem(items[n]), "Loot module script missing")
                local kind = T.component(items[n])
                assert(math.abs(items[n + 1] - Loot.WEIGHTS[kind] * Loot.SCALES[Loot.POOLS[i]] * Loot.DEFAULTS.global * Loot.DEFAULTS.items[kind]) < 0.000001, "Native effective loot weight mismatch")
                count = count + 1
            end
        end
        assert(packs == 1, "Native pack pool must contain exactly one pack entry")
    end
    assert(count == 246, "Expected 246 component entries across sixteen native loot pools")
    for kind in pairs(Loot.WEIGHTS) do
        local script = getScriptManager():getItem(T.TYPES[kind])
        assert(script and script:getDisplayName() ~= "", "Pack script display metadata unavailable")
        script:getNormalTexture()
        SandboxVars.OMHTurretsTraps["LootRate" .. kind] = 0
    end
    Loot.apply()
    assert(Pack.total == 0, "Loaded empty pool eligibility must be cached")
    for i = 1, #Loot.POOLS do
        local items = ProceduralDistributions.list[Loot.POOLS[i]].items
        for n = 1, #items, 2 do
            assert(items[n] ~= Pack.TYPE, "Empty pool must not inject container packs")
        end
    end
    local emptyPack = instanceItem(Pack.TYPE)
    player:getInventory():AddItem(emptyPack)
    assert(Pack.open(player, emptyPack) == nil and player:getInventory():contains(emptyPack), "Empty pool must preserve carried packs")
    for kind, value in pairs(Loot.DEFAULTS.items) do
        SandboxVars.OMHTurretsTraps["LootRate" .. kind] = value
    end
    Loot.loaded()
    local restored = Pack.open(player, emptyPack)
    assert(restored and #restored == 3, "Existing packs must recover when eligible rewards return")
    for i = 1, #restored do
        player:getInventory():Remove(restored[i])
    end
    print("[OMHTT-Smoke] native-pack-correction scriptMetadata=33 emptyPoolInjection=blocked carriedPack=preserved eligibilityRestore=pass")
    local retired = {"OMHTTModuleCapacitySmall", "OMHTTModuleCapacity", "OMHTTModuleCapacityLarge",
        "OMHTTModuleMotionDetection", "OMHTTModuleDetection360"}
    for i = 1, #retired do
        local fullType = "Base." .. retired[i]
        assert(ScriptManager.instance:getItem(fullType) == nil and T.component(fullType) == nil, "Retired item remains registered")
    end
    local visibleComponents, visibleCount = {}, 0
    local Audit = require("OMHTT/FirearmAudit")
    local auditAccepted, auditRejected = 0, 0
    local scripts = getAllItems()
    for i = 0, scripts:size() - 1 do
        local script = scripts:get(i)
        local fullType = script:getFullName()
        if script:isRanged() then
            local evidence = Audit.inspect(fullType)
            assert(evidence.item == fullType)
            if evidence.accepted then
                assert(evidence.range > 0 and evidence.cooldownMs > 0 and evidence.reloadMs >= 0)
                auditAccepted = auditAccepted + 1
            else
                assert(type(evidence.reason) == "string")
                auditRejected = auditRejected + 1
            end
        end
        if string.find(fullType, "Base.OMHTT", 1, true) == 1 then
            assert(string.find(fullType, "Base.OMHTTTrap", 1, true) == 1 or string.find(fullType, "Base.OMHTTTurret", 1, true) == 1
                or string.find(fullType, "Base.OMHTTModule", 1, true) == 1 or fullType == "Base.OMHTTAmmoMakeshiftBomb", "Inconsistent OMHTT item family: " .. fullType)
        end
        local component = T.component(fullType)
        if component then
            assert(not script:getObsolete() and not script:isHidden(), "Current component is unavailable")
            assert(not visibleComponents[component] and fullType == T.TYPES[component], "Duplicate component type")
            assert(instanceItem(fullType), "Current component cannot be instantiated")
            visibleComponents[component], visibleCount = true, visibleCount + 1
        end
    end
    assert(auditAccepted >= 20 and auditRejected >= 2, "Expected conventional guns and cap-gun rejections")
    print("[OMHTT-Smoke] native-firearm-audit accepted=" .. auditAccepted .. " rejected=" .. auditRejected)
    assert(visibleCount == 36, "Expected thirty-six canonical components")
    local largeStorage = instanceItem(T.BASE):getInventory()
    T.configure(largeStorage)
    local largeGun = instanceItem("Base.Pistol")
    local largeAmmo = require("OMHTT/Firearms").ammoType(largeGun)
    largeStorage:AddItem(largeGun)
    largeStorage:AddItem(T.TYPES.CapacityLarge)
    local largeStats = T.cycleConfig(T.contents(largeStorage))
    assert(largeStats.ammo == 5000, "Large expansion must reach the approved 5000 firearm rounds")
    assert(T.accept(largeStorage, instanceItem(largeAmmo)), "Expanded storage must admit matching ammo")
    for i = 1, largeStats.ammo do
        local round = instanceItem(largeAmmo)
        round:setID(1000000000 + i)
        largeStorage:AddItem(round)
    end
    local summaryStarted = getTimestampMs()
    assert(T.contents(largeStorage).reserveAll == 5000, "Large summary count drift")
    print("[OMHTT-Controls] native-summary rounds=5000 milliseconds=" .. (getTimestampMs() - summaryStarted))
    OMHTT_NativeLargeAmmo = largeStorage:getContainingItem()
    assert(not T.accept(largeStorage, instanceItem(largeAmmo)), "Large ammo limit must still reject overflow")
    local heavyStorage = instanceItem(T.BASE):getInventory()
    T.configure(heavyStorage)
    heavyStorage:AddItem(T.HEAD)
    heavyStorage:AddItem(T.TYPES.CapacityLarge)
    local loaded = 0
    while loaded < 750 do
        local potato = instanceItem("Base.Potato")
        assert(T.accept(heavyStorage, potato), "Count allowance changed before native weight limit")
        if not heavyStorage:hasRoomFor(nil, potato) then break end
        heavyStorage:AddItem(potato)
        loaded = loaded + 1
    end
    assert(loaded > 0 and loaded < 750 and heavyStorage:getCapacity() == 44 and not heavyStorage:hasRoomFor(nil, instanceItem("Base.Potato")), "Native bag weight limit must include the base weight")
    print("[OMHTT-Smoke] native-heavy-expansion potatoes=" .. loaded .. " countAllowance=750 nativeWeightLimit=44")
    print("[OMHTT-Smoke] native-large-expansion rounds=5000 weight=real overflow=blocked")
    print("[OMHTT-Smoke] native-component-list visible=23 hidden=0 duplicates=0 legacy=removed")
    local nativeContents = {active = {Detection360 = 1, Filter = 1}}
    local profile = Modules.profile({baseFacing = 4, facing = 12, priority = "Toughest"}, nativeContents)
    assert(profile.cone == 360 and profile.heading == 90 and profile.priority == "Toughest", "Module profile failed")
    local live = instanceItem("Base.OMHTTTurretBase"):getInventory()
    local tooltipBattery = instanceItem("Base.CarBattery1")
    tooltipBattery:setCurrentUsesFloat(0.37)
    live:AddItem(tooltipBattery)
    for _, name in pairs({"OMHTTCraftTurretHead", "OMHTTCraftTurretHeadImprovised"}) do
        assert(getScriptManager():getCraftRecipe("Base." .. name):getTooltip() == "UI_OMHTT_HeadDescription", "Head recipe uses wrong output description")
    end
    for _, name in pairs({"OMHTTCraftTurretComplete", "OMHTTCraftTurretCompleteImprovised"}) do
        assert(getScriptManager():getCraftRecipe("Base." .. name) == nil, "Removed shortcut recipe still registered")
    end
    local chargeTooltip = T.description(live, 4)
    assert(string.find(chargeTooltip, "37 percent", 1, true), "Charge wording missing")
    assert(getText(chargeTooltip) == chargeTooltip, "Native tooltip translation must not reinterpret charge as format arguments")
    live:Remove(tooltipBattery)

    local detector = instanceItem("Base.OMHTTModuleDetection")
    live:AddItem(detector)
    assert(T.contents(live).active.MotionDetection == 1, "Native module condition defaults are not active")
    detector:setCondition(0)
    assert(T.contents(live).active.MotionDetection == nil, "Broken native module remains active")
    print("[OMHTT-Smoke] native-modules loot=246 profiles=valid condition=checked")
    assert(GameSounds.getSound("OMHTTTriggerClick") ~= nil, "Native click sound is unregistered")
    local resources = ArrayList.new()
    local tools = {"Base.Screwdriver", "Base.Wrench"}
    local routes = {
        {"Base", {MetalPipe = 2, SmallSheetMetal = 2, ScrapMetal = 1, Screws = 8}},
        {"Head", {MetalPipe = 1, SmallSheetMetal = 1, ScrapMetal = 2, ElectronicsScrap = 2, ElectricWire = 1, TirePump = 1, DuctTape = 2}},
        {"HeadImprovised", {MetalPipe = 1, SmallSheetMetal = 1, ScrapMetal = 6, ElectronicsScrap = 2, ElectricWire = 1, DuctTape = 2}},
    }
    routes[#routes + 1] = {"MotionDetectionImprovised", {ElectronicsScrap = 3, ElectricWire = 1, DuctTape = 2}, true}
    routes[#routes + 1] = {"FiringImprovised", {ElectronicsScrap = 2, ElectricWire = 1, Screws = 4}, true}
    routes[#routes + 1] = {"CapacityImprovised", {SmallSheetMetal = 1, ElectronicsScrap = 1, ElectricWire = 1, Screws = 4}, true}
    local packed = nil
    for index = 1, #routes do
        local route = routes[index]
        local prefix = route[3] and "Base.OMHTTCraft" or "Base.OMHTTCraftTurret"
        tools[2] = route[3] and "Base.Pliers" or "Base.Wrench"
        local recipe = getScriptManager():getCraftRecipe(prefix .. route[1])
        if route[3] then
            assert(recipe:getTime() * 5 == 20 * getGameTime():getMultiplierFromTimeDelta(1), "Improvised recipe must take twenty native seconds before skill modifiers")
            assert(recipe:getXPAwardCount() == 1 and recipe:getXPAward(0):getPerk() == Perks.Electricity, "Improvised recipe awards only Electrical XP")
        end
        assert(recipe and not recipe:needToBeLearn(), "Turret recipe unavailable")
        local data = CraftRecipeData.new(CraftMode.Handcraft, false, true, false, true)
        data:setRecipe(recipe)
        local inputs = ArrayList.new()
        for i = 1, #tools do
            local tool = instanceItem(tools[i])
            assert(tool, "Missing vanilla tool " .. tools[i])
            inputs:add(tool)
        end
        for kind, count in pairs(route[2]) do
            if kind == "DuctTape" then
                local tape = instanceItem("Base.DuctTape")
                tape:setCurrentUsesFloat(count * tape:getUseDelta())
                inputs:add(tape)
            else
                for i = 1, count do inputs:add(instanceItem("Base." .. kind)) end
            end
        end
        assert(data:canConsumeInputs(resources, inputs, true, true), "Native recipe rejects approved ingredients: " .. route[1])
        for i = 0, inputs:size() - 1 do
            local item = inputs:get(i)
            player:getInventory():AddItem(item)
            for j = 0, recipe:getInputs():size() - 1 do data:offerInputItem(recipe:getInputs():get(j), item) end
        end
        assert(data:consumeInputs(resources) and data:createOutputs(resources, player), "Turret recipe transaction failed")
        data:luaCallOnCreate(player)
        data:processDestroyAndUsedItems(player)
        for i = 0, #tools - 1 do assert(player:getInventory():contains(inputs:get(i)), "Turret recipe consumed retained tool") end
        local item = data:getFirstCreatedItem()
        assert(item and data:getAllCreatedItems():size() == 1, "Recipe must produce exactly one item")
        if route[1] == "Base" then packed = item end
        if route[3] then
            assert(item:getFullType() == T.TYPES[route[1]] and item:getCondition() > 0, "Improvised recipe output mismatch")
            assert(require("OMHTT/LootDefinitions").WEIGHTS[route[1]] == nil, "Improvised item leaked into module loot")
        end
        if item:getFullType() == T.BASE then
            local expected = 0
            assert(T.contents(item:getInventory()).heads == expected, "Completed turret missing its real head")
        end
    end
    assert(packed and packed:getWeightReduction() == 0, "Unproven packed-weight change must not alter native inventory")
    local inventory = packed:getInventory()
    inventory:AddItem(instanceItem(T.HEAD))
    assert(not inventory:isItemAllowed(instanceItem("Base.Plank")), "Native container accepted unrelated item")
    assert(not inventory:isItemAllowed(instanceItem(T.HEAD)), "Native container accepted second head")
    local battery = instanceItem("Base.CarBattery1")
    battery:setCurrentUsesFloat(0.37)
    assert(inventory:isItemAllowed(battery), "Native battery slot rejects battery")
    inventory:AddItem(battery)
    assert(not inventory:isItemAllowed(instanceItem("Base.CarBattery2")), "Native container accepted second battery")
    local potato = instanceItem("Base.Potato")
    inventory:AddItem(potato)
    inventory:AddItem("Base.OMHTTModuleRapidFire")
    inventory:AddItem("Base.OMHTTModuleRapidFire")
    local contents = T.contents(inventory)
    assert(contents.ammo == 1 and contents.modules == 2 and T.canRemove(inventory, contents.head), "Inventory classification/removal guard failed")
    assert(math.abs(packed:getUnequippedWeight() - packed:getActualWeight() - inventory:getContentsWeight()) < 0.001, "Packed weight omits or duplicates contents")
    local baseStats = T.cycleConfig()
    local expansion = instanceItem("Base.OMHTTModuleExpansionMedium")
    assert(inventory:isItemAllowed(expansion), "Native capacity socket rejected")
    inventory:AddItem(expansion)
    inventory:AddItem("Base.OMHTTModuleReload")
    inventory:AddItem("Base.OMHTTModuleReload")
    local velocity = inventory:AddItem("Base.OMHTTModuleVelocity")
    local stats = T.cycleConfig(T.contents(inventory))
    assert(stats.modules == baseStats.modules + 10 and stats.ammo == baseStats.ammo + 650 and math.abs(stats.cooldown - baseStats.cooldown / 1.5) < 0.001
        and math.abs(stats.reload - baseStats.reload / 1.5) < 0.001 and math.abs(stats.damage - baseStats.damage * 1.2) < 0.001, "Native effective module stats failed")
    assert(not T.canRemove(inventory, expansion), "Native capacity removal lost module limit")
    assert(not inventory:isItemAllowed(instanceItem("Base.OMHTTModuleExpansionMedium")), "Native duplicate capacity accepted")
    velocity:setCondition(0)
    assert(T.cycleConfig(T.contents(inventory)).damage == baseStats.damage, "Broken native velocity remains active")
    inventory:Remove(velocity)
    local excess = {}
    for i = 0, inventory:getItems():size() - 1 do
        local module = inventory:getItems():get(i)
        if module:getFullType() == T.TYPES.Reload then excess[#excess + 1] = module end
    end
    for i = 1, #excess do inventory:Remove(excess[i]) end
    assert(T.canRemove(inventory, expansion), "Native capacity remains stuck after removing excess")
    for i = 1, #excess do inventory:AddItem(excess[i]) end
    local info = SpriteConfigManager.GetObjectInfo("OMHTTDeployTurret")
    assert(info and info:getRecipe():getCraftRecipe():getXPAwardCount() == 0, "Deployment repeats XP")
    local recipe = info:getRecipe():getCraftRecipe()
    local decoy = player:getInventory():AddItem("Base.OMHTTTurretBase")
    decoy:getInventory():AddItem("Base.OMHTTTurretPotato")
    player:getInventory():AddItem(packed)
    local containers = ArrayList.new()
    containers:add(player:getInventory())
    local installLogic = BuildLogic.new(player, nil, nil)
    installLogic:setContainers(containers)
    installLogic:setRecipe(recipe)
    installLogic:setManualSelectInputs(true)
    installLogic:clearManualInputs()
    assert(installLogic:offerInputItem(decoy), "BuildLogic rejects first matching packed base")
    installLogic:clearManualInputs()
    assert(installLogic:offerInputItem(packed), "BuildLogic rejects replacement exact selected packed base")
    assert(not installLogic:offerInputItem(packed), "Duplicate selected offer must not be mistaken for Install failure")
    local data = installLogic:getRecipeData()
    assert(data:getFirstManualInputFor(recipe:getInputs():get(0)) == packed, "BuildLogic changes selected packed item")
    assert(data:getFirstManualInputFor(recipe:getInputs():get(0)) == packed, "Placement preview cannot resolve exact packed input")
    assert(data:consumeInputs(resources), "Loaded portable turret could not be deployed")
    data:processDestroyAndUsedItems(player)
    assert(player:getInventory():contains(decoy) and decoy:getInventory():getItems():size() == 1, "Install consumed the other packed turret")
    print("[OMHTT-Smoke] native-install exact=selected decoy=preserved preview=nonconsuming")
    assert(not player:getInventory():contains(packed) and inventory:contains(battery), "Native build must consume the base but retain its contents for adoption")
    local square = IsoGridSquare.new(getCell(), nil, 6, 6, 0)
    local object = IsoThumpable.new(getCell(), square, "omhtt_turret_01_16", false)
    square:getObjects():add(object)
    square:getSpecialObjects():add(object)
    GameEntityFactory.CreateIsoObjectEntity(object, info:getScript():getParent(), true)
    packed:getModData().OMHTTTurret.nextShot = 123456789
    packed:getModData().OMHTTTurret.engagementRange = 3
    W.onCreate({thumpable = object, character = player, facing = "e", craftRecipeData = data})
    assert(not player:getInventory():contains(packed) and inventory:getItems():isEmpty(), "Deployment retained packed source")
    assert(object:getContainer():contains(battery) and object:getContainer():contains(potato), "Deployment recreated or lost contents")
    assert(T.state(object).engagementRange == 3, "Deployment reset engagement range")
    assert(T.state(object).nextShot == 123456789, "Deployment reset cooldown")
    assert(object:getContainer():getAcceptItemFunction() == "OMHTT_Turret.accept", "World container lost acceptance rules")
    local hybrid = T.hybrid
    T.hybrid = function() return false end
    for facing = 0, 15 do
        T.state(object).facing = facing
        W.refresh(object)
        assert(object:getSpriteConfig():isValid() and object:getSpriteConfig():getTileInfo():getSpriteName() == T.sprite(facing, true), "Aiming invalidates native sprite metadata")
    end
    T.hybrid = function() return true end
    for facing = 0, 15 do
        T.state(object).facing = facing
        W.refresh(object)
        assert(not object:getSprite():getProperties():has(IsoFlagType.FloorOverlay), "Upright base must not use floor depth")
        assert(object:getSpriteName() == "omhtt_turret_01_16" and object:getSpriteConfig():isValid(), "Hybrid aiming moved or invalidated stationary base")
    end
    T.hybrid = function() return false end
    T.state(object).facing = 0
    W.refresh(object)
    object:setHealth(37)
    local nativeNear = W.near
    W.near = function(candidate, device) return candidate == player and device == object and W.valid(device) end
    local headCondition, batteryCharge = contents.head:getCondition(), battery:getCurrentUsesFloat()
    player:getInventory():AddItem("Base.ScrapMetal")
    player:getInventory():AddItem("Base.Wrench")
    assert(W.repair(player, object, T.state(object).id), "Native base repair failed")
    assert(object:getHealth() == object:getMaxHealth() and contents.head:getCondition() == headCondition
        and battery:getCurrentUsesFloat() == batteryCharge, "Repair changed gun or battery")
    assert(not W.repair(player, object, T.state(object).id), "Undamaged base repair accepted")
    W.near = nativeNear
    T.hybrid = hybrid
    object:setHealth(37)
    print("[OMHTT-Smoke] native-turret-repair base=full head=preserved battery=preserved")
    T.state(object).automatic = false
    T.state(object).priority = "Toughest"
    T.state(object).baseFacing = 4
    T.state(object).facingDegrees, T.state(object).facingPending = 234.5, true
    T.state(object).condition = 37
    T.state(object).fixtureBatteryId = battery:getID()
    T.state(object).fixtureAmmoId = potato:getID()
    contents.head:getModData().OMHTTCycle = {schema = 1, loaded = 1, nextShot = 123456789, cooldownDuration = 750, reloadDuration = 750, impactReady = false, impactEmpty = true, conservationDebt = .5}
    assert(contents.head:getWorldStaticItem() == "Base.OMHTTTurretProbe", "Actual turret head has no native model")
    OMHTT_NativeTurret = object
    local starter = instanceItem(T.BASE)
    local starterStorage = starter:getInventory()
    for _, component in pairs({T.HEAD, T.TYPES.MotionDetectionImprovised, T.TYPES.FiringImprovised, T.TYPES.CapacityImprovised, "Base.Potato"}) do
        local item = starterStorage:AddItem(component)
        starter:getModData()[component] = item:getID()
    end
    local starterContents = T.contents(starterStorage)
    assert(T.cycleConfig(starterContents).modules == 4 and T.cycleConfig(starterContents).ammo == 250,
        "Improvised native expansion has wrong defaults")
    starterContents.head:getModData().OMHTTCycle = {schema = 1, loaded = 1, nextShot = 123456789, cooldownDuration = 2000}
    OMHTT_NativeImprovised = starter
    local wreckSquare = IsoGridSquare.new(getCell(), nil, 7, 7, 0)
    local wreck = IsoThumpable.new(getCell(), wreckSquare, "omhtt_turret_01_16", false)
    wreckSquare:getObjects():add(wreck)
    wreckSquare:getSpecialObjects():add(wreck)
    wreck:getModData().OMHTTTurret = {schema = 1, id = "destruction-fixture"}
    wreck:getBuildMaterials()[T.BASE] = 1
    W.clearBuildRefund(wreck)
    assert(wreck:getBuildMaterials()[T.BASE] == nil, "Destruction can refund a working base")
    local wreckContents = ItemContainer.new(T.CONTAINER, wreckSquare, wreck)
    wreck:setContainer(wreckContents)
    local savedItems = {}
    for i = 1, 100 do savedItems[#savedItems + 1] = wreckContents:AddItem("Base.Potato") end
    savedItems[#savedItems + 1] = wreckContents:AddItem(T.HEAD)
    savedItems[#savedItems + 1] = wreckContents:AddItem(T.TYPES.Capacity)
    savedItems[#savedItems + 1] = wreckContents:AddItem(T.TYPES.Velocity)
    local savedBattery = wreckContents:AddItem("Base.CarBattery1")
    savedBattery:setCurrentUsesFloat(0.37)
    savedBattery:setCondition(42)
    savedItems[#savedItems + 1] = savedBattery
    wreck:dumpContentsInSquare()
    W.removed(wreck)
    assert(not T.state(wreck), "Removal retained turret state")
    assert(wreckContents:getItems():isEmpty(), "Destroyed turret retained inventory")
    local ground, scrap, seen = wreckSquare:getWorldObjects(), 0, {}
    for i = 0, ground:size() - 1 do
        local dropped = ground:get(i):getItem()
        assert(dropped:getFullType() ~= T.BASE, "Destruction refunded a base")
        if dropped:getFullType() == "Base.ScrapMetal" then scrap = scrap + 1 end
        assert(not seen[dropped], "Duplicate dropped item")
        seen[dropped] = true
    end
    assert(scrap == 2 and ground:size() == #savedItems + 2, "Incorrect salvage or inventory drop count")
    for i = 1, #savedItems do assert(seen[savedItems[i]], "Destruction replaced or lost an actual item") end
    assert(math.abs(savedBattery:getCurrentUsesFloat() - 0.37) < 0.000001 and savedBattery:getCondition() == 42,
        "Destruction changed battery condition or charge")
    W.removed(wreck)
    assert(ground:size() == #savedItems + 2, "Repeated destruction duplicated contents or salvage")
    print("[OMHTT-Smoke] native-turret-destroy contents=104 exact=true scrap=2 base=0 repeated=stable")
    local Guns = require("OMHTT/Firearms")
    local savedGuns = ArrayList.new()
    Guns.registerAmmunition()
    local scripts = getScriptManager():getAllItems()
    local admitted = 0
    for i = 0, scripts:size() - 1 do
        local script = scripts:get(i)
        if script:isRanged() and script:getAmmoType() then
            local gun = instanceItem(script:getFullName())
            local profile = Guns.profile(gun)
            if gun:getMaxDamage() > 0 then
                assert(profile, "Native firearm not recognized: " .. script:getFullName())
                admitted = admitted + 1
            else
                assert(not profile, "Toy firearm admitted")
            end
        end
    end
    assert(admitted == 20, "Native real-firearm coverage changed: " .. admitted)
    for fullType in pairs(Guns.PROFILES) do
        local base = instanceItem(T.BASE)
        local gun = instanceItem(fullType)
        local storage = base:getInventory()
        T.configure(storage)
        assert(T.accept(storage, gun), "Supported gun rejected")
        storage:AddItem(gun)
        if gun:getMagazineType() then gun:setContainsClip(true) end
        assert(Guns.AMMO[Guns.ammoType(gun)], "Ammo classification mismatch: " .. Guns.ammoType(gun))
        assert(not T.accept(storage, instanceItem("Base.Potato")), "Gun accepted potatoes")
        local model = ScriptManager.instance:getModelScript(gun:getStaticModel())
        assert(model and model:getAttachmentById("muzzle"), "Native gun/muzzle model missing")
        print("[OMHTT-Smoke] firearm-profile type=" .. fullType .. " ammo=" .. Guns.ammoType(gun)
            .. " model=" .. gun:getStaticModel() .. " worldRotate=" .. tostring(model:getAttachmentById("world"):getRotate())
            .. " worldOffset=" .. tostring(model:getAttachmentById("world"):getOffset()))
        local gunBattery = storage:AddItem("Base.CarBattery1")
        gunBattery:setCurrentUsesFloat(0.43)
        local ammo = Guns.ammoType(gun)
        for i = 1, 90 do storage:AddItem(ammo) end
        local summary = T.contents(storage)
        local config = T.cycleConfig(summary)
        assert(summary.ammo == 90 and config.firearm and config.magazine == gun:getMaxAmmo(), "Native firearm config mismatch")
        local expected = { ["Base.Pistol"] = {15, 400 / .75, 20, 4}, ["Base.Shotgun"] = {12, 1000 / .75, 70, 12}, ["Base.HuntingRifle"] = {40, 1200 / .75, 30, 4} }
        local stats = require("OMHTT/TurretStats").resolve(summary)
        local precision = require("OMHTT/FirearmClass").precision(gun)
        assert(Accuracy.chance(gun, stats, stats.range, false) == (precision and 80 or 60), "Maximum-range accuracy mismatch")
        local values = expected[fullType]
        if values then
            assert(stats.range == values[1] and math.abs(stats.cooldown - values[2]) < .001 and stats.critChance == values[3]
                and stats.critMultiplier == values[4], "Native firearm range/cadence/crit drift: " .. fullType)
        else
            assert(stats.range == math.min(50, gun:getMaxRange()) and stats.critChance == gun:getCriticalChance()
                and stats.critMultiplier == gun:getCriticalDamageMultiplier(), "Generic stats drift: " .. fullType)
        end
        print("[OMHTT-Smoke] native-firearm-stats type=" .. fullType .. " range=" .. stats.range .. " cooldown=" .. stats.cooldown
            .. " critical=" .. stats.critChance .. " multiplier=" .. stats.critMultiplier)
        local clock = getTimestampMs()
        local _, status = Guns.update(summary, config, clock, true)
        assert(status == "Reloading" and gun:getCurrentAmmoCount() == 0, "Loaded ammo before reload elapsed")
        for i = 1, 20 do
            clock = clock + 1000
            summary = T.contents(storage)
            _, status = Guns.update(summary, config, clock, true)
            if status == "Ready" then break end
        end
        assert(status == "Ready" and T.contents(storage).ammo == 90, "Native reload invented or lost ammo")
        assert(Guns.consume(T.contents(storage), config, clock), "Ready gun failed to consume shot")
        assert(T.contents(storage).ammo == 89, "Native shot must spend exactly one round")
        assert(not Guns.consume(T.contents(storage), config, clock), "Cooldown or pump can be skipped")
        for shot = 1, gun:getMaxAmmo() + 2 do
            for tick = 1, 80 do
                clock = clock + 1000
                local _, ready = Guns.update(T.contents(storage), config, clock, true)
                if ready == "Ready" then break end
            end
            local before = T.contents(storage).ammo
            assert(Guns.consume(T.contents(storage), config, clock), "Repeat cycle failed: " .. fullType)
            assert(T.contents(storage).ammo == before - 1, "Repeat cycle round loss: " .. fullType)
        end
        local Feed = require("OMHTT/FirearmFeed")
        -- Return the native load, then exercise the extension on every admitted mechanism.
        local returnCount = Guns.loaded(gun)
        gun:setCurrentAmmoCount(0)
        gun:setRoundChambered(false)
        for i = 1, returnCount + 100 do storage:AddItem(ammo) end
        local expanded = require("OMHTT/TurretStats").resolve({head = gun, active = {Magazine = 2, Splitter = 2}})
        local total = T.contents(storage).ammo
        local weight = storage:getContentsWeight()
        Guns.cancelLoading(gun)
        for tick = 1, 4 do
            clock = clock + 1000000
            Guns.update(T.contents(storage), expanded, clock, true)
        end
        assert(Guns.loaded(gun) == expanded.magazine and Feed.count(gun) > 0
            and gun:getCurrentAmmoCount() <= gun:getMaxAmmo(), "Expanded native feed failed: " .. fullType)
        assert(T.contents(storage).ammo == total and math.abs(storage:getContentsWeight() - weight) < .001,
            "Expanded loading lost ammunition or weight: " .. fullType)
        assert(Guns.consume(T.contents(storage), expanded, clock) and T.contents(storage).ammo == total - 3,
            "Expanded Splitter consumption failed: " .. fullType)
        local savedFeed = Feed.count(gun)
        Feed.restore(gun, gun:getMaxAmmo(), player, true)
        assert(Feed.count(gun) == 0 and T.contents(storage).ammo == total - 3, "Feed removal lost rounds")
        Feed.set(gun, savedFeed)
        gun:setCondition(7)
        if fullType == "Base.Pistol" then gun:attachWeaponPart(instanceItem("Base.Laser"), false) end
        base:getModData().OMHTTGunFixture = {fullType = fullType, total = T.contents(storage).ammo,
            rounds = gun:getCurrentAmmoCount(), chamber = gun:isRoundChambered(), gunId = gun:getID(),
            feed = Feed.count(gun), condition = 7, nextShot = Guns.state(gun).nextShot, clip = gun:isContainsClip()}
        savedGuns:add(base)
    end
    print("[OMHTT-Modules] native-feed firearms=20 weight=conserved ammo=conserved nativeCapacity=unchanged splitter=3rounds removal=conserved")
    OMHTT_NativeFirearms = savedGuns
    local magazineStorage = instanceItem(T.BASE):getInventory()
    local pistol = magazineStorage:AddItem("Base.Pistol")
    pistol:setContainsClip(false)
    pistol:setRoundChambered(true)
    pistol:setCurrentAmmoCount(0)
    local magazine = player:getInventory():AddItem("Base.9mmClip")
    magazine:setCurrentAmmoCount(7)
    local token = {}
    assert(Guns.transferMagazine(player, magazineStorage, pistol, magazine, token) == magazine, "Native magazine insertion failed")
    assert(not player:getInventory():contains(magazine) and pistol:isContainsClip() and Guns.loaded(pistol) == 8,
        "Insertion lost/duplicated ammunition or chamber")
    assert(not Guns.transferMagazine(player, magazineStorage, pistol, magazine, token), "Repeated insertion accepted")
    local recovered = Guns.transferMagazine(player, magazineStorage, pistol, nil, token)
    assert(recovered and player:getInventory():contains(recovered) and recovered:getCurrentAmmoCount() == 7
        and not pistol:isContainsClip() and Guns.loaded(pistol) == 1, "Ejection lost native magazine/chamber state")
    assert(not Guns.transferMagazine(player, magazineStorage, pistol, nil, token), "Repeated ejection duplicated a magazine")
    local wrong = player:getInventory():AddItem("Base.Potato")
    assert(Guns.magazineRejection(player, magazineStorage, pistol, wrong, token) == "WrongMagazine", "Wrong item reached magazine methods")
    recovered:setFavorite(true)
    assert(Guns.magazineRejection(player, magazineStorage, pistol, recovered, token) == "TransferFavorite", "Favorite magazine consumed")
    recovered:setFavorite(false)
    local capacity = SandboxVars.OMHTurretsTraps.FirearmAmmoCapacity
    SandboxVars.OMHTurretsTraps.FirearmAmmoCapacity = 7
    assert(Guns.magazineRejection(player, magazineStorage, pistol, recovered, token) == "TransferFull", "Magazine bypassed total capacity")
    SandboxVars.OMHTurretsTraps.FirearmAmmoCapacity = capacity
    Guns.servicing[pistol] = token
    local _, servicing = Guns.update(T.contents(magazineStorage), T.cycleConfig(T.contents(magazineStorage)), getTimestampMs(), true)
    assert(servicing == "Servicing" and not T.canRemove(magazineStorage, pistol), "Active magazine service allowed feeding/head removal")
    assert(Guns.magazineRejection(player, magazineStorage, pistol, recovered, {}) == "TransferPending", "Competing magazine action accepted")
    Guns.servicing[pistol] = nil
    magazineStorage:Remove(pistol)
    assert(Guns.magazineRejection(player, magazineStorage, pistol, recovered, token) == "TransferMissing", "Stale head service accepted")
    magazineStorage:AddItem("Base.Bullets9mm")
    assert(T.accept(magazineStorage, instanceItem(T.HEAD)), "Reserve incorrectly prevents head swapping")
    local mount = instanceItem("Base.OMHTTTurretGunSupportVisual")
    assert(mount and mount:getScriptItem():isHidden() and ScriptManager.instance:getModelScript(mount:getWorldStaticItem()), "Technical mount is missing, unbound or visible in spawn list")
    print("[OMHTT-Smoke] native-magazines insert=eject=conserved chamber=retained replay=blocked capacity=checked mount=bound")
    print("[OMHTT-Smoke] native-firearms firearms=20 rounds=conserved models=bound reload=timed")
    local H = require("OMHTT/HybridProbe")
    local model = ScriptManager.instance:getModelScript("Base.OMHTTTurretProbe")
    assert(model and model:getMeshName() == "OMHTT_ProbeHead", "Native hybrid model script missing")
    local first = instanceItem(H.ITEM)
    local second = instanceItem(H.ITEM)
    assert(ScriptManager.instance:getModelScript(first:getWorldStaticItem()) == model,
        "Probe item model not bound: " .. tostring(first:getWorldStaticItem()))
    first:getModData().OMHTTHybridProbe = "native-probe"
    first:setWorldScale(1.25)
    first:getModData().OMHTTProbeScale = 1.25
    local world = IsoWorldInventoryObject.new(first, square, 0.5, 0.5, 0.3)
    first:setWorldItem(world)
    H.rotate(world, 135)
    second:setWorldZRotation(270)
    assert(first:getWorldZRotation() == 135 and second:getWorldZRotation() == 270, "Shared model rotation leaked between items")
    local base = IsoObject.new(square, H.SPRITE, "OMHTT Hybrid Probe")
    base:getModData().OMHTTHybridProbe = "native-probe"
    square:getObjects():add(base)
    square:getWorldObjects():add(world)
    local foundBase, foundHead = H.find(square)
    assert(foundBase == base and foundHead == world, "Native probe identity lookup failed")
    assert(base:getSpriteName() == H.SPRITE, "Rotating head changed base sprite")
    OMHTT_NativeHybridHead = world
    print("[OMHTT-Smoke] native-hybrid model=bound yaw=independent base=fixed lookup=exact")
    local Health = require("OMHTT/TargetHealth")
    local victim = IsoZombie.new(getCell())
    victim:setHealth(3.7)
    Health.created(victim)
    victim:setHealth(0.37)
    Health.created(victim)
    assert(math.abs(Health.maximum(victim) - 3.7) < .00001, "Wounded HP replaced the creation baseline")
    victim:getModData().OMHToughnessInitialHealth = 6
    assert(Health.maximum(victim) == 6, "Horde Night baseline was ignored")
    victim:getModData().OMHToughnessInitialHealth = nil
    victim:getModData().OMHTTInitialHealth = nil
    assert(Health.maximum(victim) == 0, "Unknown HP baseline was invented")
    victim:setStaggerBack(true)
    assert(victim:isStaggerBack() and not victim:isKnockedDown() and not victim:isOnFloor(), "Standing stagger requested a fall")
    victim:setStaggerBack(false)
    assert(not victim:isStaggerBack() and math.abs(victim:getHealth() - .37) < .00001, "Stagger changed health or failed to clear")
    local Stats = require("OMHTT/TurretStats")
    local savedOptions = SandboxVars.OMHTurretsTraps
    SandboxVars.OMHTurretsTraps = {}
    -- Keep the real owner rarity configuration while isolating combat tuning.
    for key, value in pairs(savedOptions) do
        if string.sub(key, 1, 12) == "RarityWeight" or string.sub(key, 1, 8) == "LootRate" then
            SandboxVars.OMHTurretsTraps[key] = value
        end
    end
    require("OMHTT/TurretRarity").refresh(SandboxVars.OMHTurretsTraps)
    local powerStore = instanceItem(T.BASE):getInventory()
    local powerGun = powerStore:AddItem("Base.Pistol")
    powerStore:AddItem(T.TYPES.FiringEnhanced)
    powerStore:AddItem(T.TYPES.MotionDetectionEnhanced)
    powerStore:AddItem(T.TYPES.CapacityLarge)
    for i = 1, 14 do powerStore:AddItem(T.TYPES.Execute) end
    local powerContents = T.contents(powerStore)
    local powerStats = Stats.resolve(powerContents)
    assert(math.abs(powerContents.powerLoad - 17) < .00001 and math.abs(powerStats.batteryPercent - .01215) < .000001, "Native M9 rarity power failed")
    assert(math.abs(powerStats.generatorFuel - .0018) < .0000001, "Native generator cost mismatch")
    powerStore:Remove(powerGun)
    powerStore:AddItem("Base.HuntingRifle")
    powerStats = Stats.resolve(T.contents(powerStore))
    assert(math.floor(100 / powerStats.batteryPercent) == 3563 and math.abs(powerStats.weaponPower - math.sqrt(16 / 3)) < .000001, "Native rifle endurance mismatch")
    local Conditional = require("OMHTT/TurretConditionalHit")
    victim:getModData().OMHTTInitialHealth = 3.7
    victim:setHealth(.37)
    local conditionalStats = Stats.resolve({active = {Execute = 1, InitialBlow = 2}})
    assert(Conditional.snapshot(victim, conditionalStats).execute, "Native Execute boundary failed")
    victim:setHealth(3.7)
    assert(Conditional.snapshot(victim, conditionalStats).bonus == 1.5, "Native Initial Blow baseline failed")
    for _, fullType in pairs({"Base.Pistol", "Base.Shotgun", "Base.HuntingRifle"}) do
        local store = instanceItem(T.BASE):getInventory()
        local gun = store:AddItem(fullType)
        gun:setContainsClip(true)
        gun:setCurrentAmmoCount(0)
        gun:setRoundChambered(true)
        gun:setSpentRoundChambered(false)
        store:AddItem(T.TYPES.Conservation)
        local summary = T.contents(store)
        local config = Stats.resolve(summary)
        local Guns = require("OMHTT/Firearms")
        local cycle = Guns.state(gun)
        cycle.nextShot, cycle.impactReady = 0, true
        assert(Guns.consume(summary, config, 100000), "Conserved native shot rejected")
        assert(Guns.loaded(gun) == 1 and not cycle.impactReady and cycle.conservationDebt == .5, "First conserved shot damaged last-round/Impact state")
        assert(not Guns.consume(T.contents(store), config, 100000), "Conservation bypassed cooldown")
        assert(Guns.consume(T.contents(store), config, 100000 + config.cooldown + config.rack + 1), "Second conserved native shot rejected")
        assert(Guns.loaded(gun) == 0 and cycle.conservationDebt == 0, "Second use did not consume native last round")
    end
    print("[OMHTT-Smoke] native-conservation guns=3 lastRound=two-uses cooldown=retained impact=not-rearmed")
    require("OMHTT/NativeHeads")(player)
    require("OMHTT/NativeProc")(player)
    require("OMHTT/NativeBulkTransfer")(player)
    local Rarity = require("OMHTT/TurretRarity")
    local raritySettings, rarityAnchors = {}, {20, 16, 12, 8, 5, 2, 1}
    for i = 1, #Rarity.names do
        local name = "RarityWeight" .. Rarity.names[i]
        local option = getSandboxOptions():getOptionByName("OMHTurretsTraps." .. name)
        assert(option and option:getDefaultValue() == ({20, 18, 14, 10, 6, 3, 1})[i], "Native rarity setting missing: " .. name)
        raritySettings[name] = rarityAnchors[i]
    end
    local LootDefinitions = require("OMHTT/LootDefinitions")
    for i = 1, #rarityAnchors do
        raritySettings.LootRateRange = rarityAnchors[i] / LootDefinitions.WEIGHTS.Range
        SandboxVars.OMHTurretsTraps = raritySettings
        Rarity.refresh(raritySettings)
        assert(Rarity.get("Range").band == i and Rarity.get("Range").surcharge == Rarity.surcharges[i], "Native custom rarity/power parity failed")
    end
    Rarity.refresh(savedOptions)
    print("[OMHTT-Smoke] native-rarity anchors=7 settings=registered defaults=owner-tiers colorsAndSurcharges=matched")
    SandboxVars.OMHTurretsTraps = savedOptions
    print("[OMHTT-Smoke] native-power modules=16 aliases=once m9=0.01215 rifleShots=3563 generator=matched conditionals=valid")
    print("[OMHTT-Smoke] native-offensive-feasibility health=creation-recorded wounded=preserved horde=preferred unknown=zero stagger=exposed-standing")
    print("[OMHTT-Smoke] native-turret recipes=6 loadedDeploy=exact contents=preserved weight=exact filters=valid cooldown=preserved")
    isServer, isClient = serverFunction, clientFunction
    require("OMHTT/NativeTurretAuthority")(IsoPlayer.new(getCell()))
    require("OMHTT/NativeControls")(IsoPlayer.new(getCell()))
end

Events.OnServerStarted.Add(verifyTurrets)

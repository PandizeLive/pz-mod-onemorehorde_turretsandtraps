local T = require("OMHTT/Turret")
local W = require("OMHTT/TurretWorld")

local function verifyTurrets()
    local serverFunction, clientFunction = isServer, isClient
    isServer = function() return false end
    isClient = function() return false end
    SandboxVars.OMHTurretsTraps.Enabled = true
    SandboxVars.OMHTurretsTraps.PotatoTurret = true
    local player = IsoPlayer.new(getCell())
    local Modules = require("OMHTT/TurretModules")
    local Loot = require("OMHTT/ModuleLoot")
    Loot.loaded()
    local count = 0
    for i = 1, #Loot.POOLS do
        local items = ProceduralDistributions.list[Loot.POOLS[i]].items
        for n = 1, #items, 2 do
            if require("OMHTT/Turret").component(items[n]) then
                assert(instanceItem(items[n]), "Loot module script missing")
                count = count + 1
            end
        end
    end
    assert(count == 48, "Expected twelve active components in four native loot pools")
    local retired = {"OMHTTModuleCapacitySmall", "OMHTTModuleCapacity", "OMHTTModuleCapacityLarge",
        "OMHTTModuleMotionDetection", "OMHTTModuleDetection360"}
    for i = 1, #retired do
        local fullType = "Base." .. retired[i]
        assert(ScriptManager.instance:getItem(fullType) == nil and T.component(fullType) == nil, "Retired item remains registered")
    end
    local visibleComponents, visibleCount = {}, 0
    local scripts = getAllItems()
    for i = 0, scripts:size() - 1 do
        local script = scripts:get(i)
        local fullType = script:getFullName()
        local component = T.component(fullType)
        if component then
            assert(not script:getObsolete() and not script:isHidden(), "Current component is unavailable")
            assert(not visibleComponents[component] and fullType == T.TYPES[component], "Duplicate component type")
            assert(instanceItem(fullType), "Current component cannot be instantiated")
            visibleComponents[component], visibleCount = true, visibleCount + 1
        end
    end
    assert(visibleCount == 12, "Expected twelve canonical components")
    print("[OMHTT-Smoke] native-component-list visible=12 hidden=0 duplicates=0 legacy=removed")
    local nativeContents = {active = {Detection360 = 1, Filter = 1}}
    local profile = Modules.profile({baseFacing = 4, facing = 12, priority = "Toughest"}, nativeContents)
    assert(profile.cone == 360 and profile.heading == 90 and profile.priority == "Toughest", "Module profile failed")
    local live = instanceItem("Base.OMHTTTurretBase"):getInventory()
    local tooltipBattery = instanceItem("Base.CarBattery1")
    tooltipBattery:setCurrentUsesFloat(0.37)
    live:AddItem(tooltipBattery)
    local chargeTooltip = T.description(live, 4)
    assert(string.find(chargeTooltip, "37 percent", 1, true), "Charge wording missing")
    assert(getText(chargeTooltip) == chargeTooltip, "Native tooltip translation must not reinterpret charge as format arguments")
    live:Remove(tooltipBattery)

    local detector = instanceItem("Base.OMHTTModuleDetection")
    live:AddItem(detector)
    assert(T.contents(live).active.MotionDetection == 1, "Native module condition defaults are not active")
    detector:setCondition(0)
    assert(T.contents(live).active.MotionDetection == nil, "Broken native module remains active")
    print("[OMHTT-Smoke] native-modules loot=48 profiles=valid condition=checked")
    local resources = ArrayList.new()
    local tools = {"Base.Screwdriver", "Base.Wrench"}
    local routes = {
        {"Base", {MetalPipe = 2, SmallSheetMetal = 2, ScrapMetal = 1, Screws = 8}},
        {"Head", {MetalPipe = 1, SmallSheetMetal = 1, ScrapMetal = 2, ElectronicsScrap = 2, ElectricWire = 1, TirePump = 1, DuctTape = 2}},
        {"HeadImprovised", {MetalPipe = 1, SmallSheetMetal = 1, ScrapMetal = 6, ElectronicsScrap = 2, ElectricWire = 1, DuctTape = 2}},
        {"Complete", {MetalPipe = 3, SmallSheetMetal = 3, ScrapMetal = 3, Screws = 8, ElectronicsScrap = 2, ElectricWire = 1, TirePump = 1, DuctTape = 2}},
        {"CompleteImprovised", {MetalPipe = 3, SmallSheetMetal = 3, ScrapMetal = 7, Screws = 8, ElectronicsScrap = 2, ElectricWire = 1, DuctTape = 2}},
    }
    local packed = nil
    for index = 1, #routes do
        local route = routes[index]
        local recipe = getScriptManager():getCraftRecipe("Base.OMHTTCraftTurret" .. route[1])
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
        if route[1] == "Complete" then packed = item end
        if item:getFullType() == T.BASE then
            local expected = route[1] == "Base" and 0 or 1
            assert(T.contents(item:getInventory()).heads == expected, "Completed turret missing its real head")
        end
    end
    assert(packed and packed:getWeightReduction() == 0, "Turret must not reduce contents weight")
    local inventory = packed:getInventory()
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
    local expansion = instanceItem("Base.OMHTTExpansionKitMedium")
    assert(inventory:isItemAllowed(expansion), "Native capacity socket rejected")
    inventory:AddItem(expansion)
    inventory:AddItem("Base.OMHTTModuleReload")
    inventory:AddItem("Base.OMHTTModuleReload")
    local velocity = inventory:AddItem("Base.OMHTTModuleVelocity")
    local stats = T.cycleConfig(T.contents(inventory))
    assert(stats.modules == baseStats.modules + 4 and stats.ammo == baseStats.ammo + 100 and math.abs(stats.cooldown - baseStats.cooldown / 1.5) < 0.001
        and math.abs(stats.reload - baseStats.reload / 1.5) < 0.001 and math.abs(stats.damage - baseStats.damage * 1.2) < 0.001, "Native effective module stats failed")
    assert(not T.canRemove(inventory, expansion), "Native capacity removal lost module limit")
    assert(not inventory:isItemAllowed(instanceItem("Base.OMHTTExpansionKitMedium")), "Native duplicate capacity accepted")
    velocity:setCondition(0)
    assert(T.cycleConfig(T.contents(inventory)).damage == baseStats.damage, "Broken native velocity remains active")
    inventory:Remove(velocity)
    assert(T.canRemove(inventory, expansion), "Native capacity remains stuck after removing excess")
    local info = SpriteConfigManager.GetObjectInfo("OMHTTDeployTurret")
    assert(info and info:getRecipe():getCraftRecipe():getXPAwardCount() == 0, "Deployment repeats XP")
    local recipe = info:getRecipe():getCraftRecipe()
    local decoy = player:getInventory():AddItem("Base.OMHTTTurretBase")
    decoy:getInventory():AddItem("Base.OMHTTPotatoHead")
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
    local object = IsoThumpable.new(getCell(), square, "omhtt_barrier_01_44", false)
    square:getObjects():add(object)
    square:getSpecialObjects():add(object)
    GameEntityFactory.CreateIsoObjectEntity(object, info:getScript():getParent(), true)
    packed:getModData().OMHTTTurret.nextShot = 123456789
    W.onCreate({thumpable = object, character = player, facing = "e", craftRecipeData = data})
    assert(not player:getInventory():contains(packed) and inventory:getItems():isEmpty(), "Deployment retained packed source")
    assert(object:getContainer():contains(battery) and object:getContainer():contains(potato), "Deployment recreated or lost contents")
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
        assert(object:getSpriteName() == "omhtt_barrier_01_44" and object:getSpriteConfig():isValid(), "Hybrid aiming moved or invalidated stationary base")
    end
    T.hybrid = function() return false end
    T.state(object).facing = 0
    W.refresh(object)
    T.hybrid = hybrid
    object:setHealth(37)
    T.state(object).automatic = false
    T.state(object).priority = "Toughest"
    T.state(object).baseFacing = 4
    T.state(object).condition = 37
    T.state(object).fixtureBatteryId = battery:getID()
    T.state(object).fixtureAmmoId = potato:getID()
    contents.head:getModData().OMHTTCycle = {schema = 1, loaded = 1, nextShot = 123456789, cooldownDuration = 750, reloadDuration = 750}
    assert(contents.head:getWorldStaticItem() == "Base.OMHTTProbeHead", "Actual turret head has no native model")
    OMHTT_NativeTurret = object
    local wreckSquare = IsoGridSquare.new(getCell(), nil, 7, 7, 0)
    local wreck = IsoThumpable.new(getCell(), wreckSquare, "omhtt_barrier_01_44", false)
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
        for i = 1, 35 do storage:AddItem(ammo) end
        local summary = T.contents(storage)
        local config = T.cycleConfig(summary)
        assert(summary.ammo == 35 and config.firearm and config.magazine == gun:getMaxAmmo(), "Native firearm config mismatch")
        local clock = getTimestampMs()
        local _, status = Guns.update(summary, config, clock, true)
        assert(status == "Reloading" and gun:getCurrentAmmoCount() == 0, "Loaded ammo before reload elapsed")
        for i = 1, 20 do
            clock = clock + 1000
            summary = T.contents(storage)
            _, status = Guns.update(summary, config, clock, true)
            if status == "Ready" then break end
        end
        assert(status == "Ready" and T.contents(storage).ammo == 35, "Native reload invented or lost ammo")
        assert(Guns.consume(T.contents(storage), config, clock), "Ready gun failed to consume shot")
        assert(T.contents(storage).ammo == 34, "Native shot must spend exactly one round")
        assert(not Guns.consume(T.contents(storage), config, clock), "Cooldown or pump can be skipped")
        gun:setCondition(7)
        if fullType == "Base.Pistol" then gun:attachWeaponPart(instanceItem("Base.Laser"), false) end
        base:getModData().OMHTTGunFixture = {fullType = fullType, total = 34,
            rounds = gun:getCurrentAmmoCount(), chamber = gun:isRoundChambered(), gunId = gun:getID(),
            condition = 7, nextShot = Guns.state(gun).nextShot, clip = gun:isContainsClip()}
        savedGuns:add(base)
    end
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
    local mount = instanceItem("Base.OMHTTGunSupportVisual")
    assert(mount and mount:getScriptItem():isHidden() and ScriptManager.instance:getModelScript(mount:getWorldStaticItem()), "Technical mount is missing, unbound or visible in spawn list")
    print("[OMHTT-Smoke] native-magazines insert=eject=conserved chamber=retained replay=blocked capacity=checked mount=bound")
    print("[OMHTT-Smoke] native-firearms mechanisms=3 rounds=conserved models=bound reload=timed")
    local H = require("OMHTT/HybridProbe")
    local model = ScriptManager.instance:getModelScript("Base.OMHTTProbeHead")
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
    print("[OMHTT-Smoke] native-turret recipes=5 loadedDeploy=exact contents=preserved weight=exact filters=valid cooldown=preserved")
    isServer, isClient = serverFunction, clientFunction
end

Events.OnServerStarted.Add(verifyTurrets)

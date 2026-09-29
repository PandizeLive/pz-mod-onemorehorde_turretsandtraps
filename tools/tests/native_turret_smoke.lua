local T = require("OMHTT/Turret")
local W = require("OMHTT/TurretWorld")

local function verifyTurrets()
    local serverFunction, clientFunction = isServer, isClient
    isServer = function() return false end
    isClient = function() return false end
    SandboxVars.OMHTurretsTraps.Enabled = true
    SandboxVars.OMHTurretsTraps.PotatoTurret = true
    local player = IsoPlayer.new(getCell())
    local resources = ArrayList.new()
    local tools = {"Base.Screwdriver", "Base.Wrench", "Base.SheetMetalSnips", "Base.Pliers"}
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
        for i = 0, 3 do assert(player:getInventory():contains(inputs:get(i)), "Turret recipe consumed retained tool") end
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
    assert(contents.ammo == 1 and contents.modules == 2 and not T.canRemove(inventory, contents.head), "Inventory classification/removal guard failed")
    assert(math.abs(packed:getUnequippedWeight() - packed:getActualWeight() - inventory:getContentsWeight()) < 0.001, "Packed weight omits or duplicates contents")
    local info = SpriteConfigManager.GetObjectInfo("OMHTTDeployTurret")
    assert(info and info:getRecipe():getCraftRecipe():getXPAwardCount() == 0, "Deployment repeats XP")
    local recipe = info:getRecipe():getCraftRecipe()
    local data = CraftRecipeData.new(CraftMode.Handcraft, false, true, false, true)
    data:setRecipe(recipe)
    player:getInventory():AddItem(packed)
    assert(data:offerInputItem(recipe:getInputs():get(0), packed), "Loaded portable turret rejected by build recipe")
    assert(data:consumeInputs(resources), "Loaded portable turret could not be deployed")
    data:processDestroyAndUsedItems(player)
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
    for facing = 0, 15 do
        T.state(object).facing = facing
        W.refresh(object)
        assert(object:getSpriteConfig():isValid() and object:getSpriteConfig():getTileInfo():getSpriteName() == T.sprite(facing, true), "Aiming invalidates native sprite metadata")
    end
    T.state(object).facing = 0
    W.refresh(object)
    object:setHealth(37)
    T.state(object).condition = 37
    T.state(object).fixtureBatteryId = battery:getID()
    T.state(object).fixtureAmmoId = potato:getID()
    OMHTT_NativeTurret = object
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

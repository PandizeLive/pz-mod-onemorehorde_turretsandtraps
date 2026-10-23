return function(player)
    local count = 0
    for _, suffix in pairs({"Critical", "Velocity", "Magazine", "Accuracy", "Range", "RapidFire", "Reload", "Autoloader", "Suppression", "Regulator", "Conservation"}) do
        local item = instanceItem("Base.OMHTTModule" .. suffix)
        assert(item and item:getScriptItem():getIcon() == "OMHTT_ModulePerformance", "Performance icon missing: " .. suffix)
        assert(item:getDisplayCategory() == "OMHTTPerformance", "Performance category missing: " .. suffix)
        count = count + 1
    end
    assert(count == 11, "Performance module coverage")
    print("[OMHTT-C373] native-performance-icons=11 category=Performance")
    local T = require("OMHTT/Turret")
    local S = require("OMHTT/TurretStats")
    local Heads = require("OMHTT/TurretHeads")
    local descriptions = require("OMHTT/TurretHeadDescription")
    for _, name in pairs({"Base.Pistol", "Base.Shotgun", "Base.HuntingRifle"}) do
        local gun = instanceItem(name)
        local stats = S.resolve({head = gun, active = {}, powerLoad = 0})
        local rating, drain = descriptions.rating(gun)
        local reload = stats.reload * (gun:getMagazineType() and 1 or stats.magazine)
        local seconds = ((stats.magazine - 1) * stats.cooldown + math.max(stats.cooldown, reload + (gun:haveChamber() and stats.rack or 0))) / 1000
        assert(rating and math.abs(drain - stats.batteryPercent * stats.magazine * 3600 / seconds) < .0000001,
            "Native head rating must include magazine/per-round loading and chamber timing")
        assert(string.find(descriptions.get(gun, true), "<RGB:1,1,1>", 1, true), "Native rich head rating")
    end
    local arc = instanceItem("Base.OMHTTTurretArc")
    assert(arc and arc:getActualWeight() == 8 and arc:getConditionMax() == 100, "Native Arc head metadata")
    local base = instanceItem(T.BASE)
    local storage = base:getInventory()
    T.configure(storage)
    assert(T.accept(storage, arc), "Arc uses normal universal base")
    storage:AddItem(arc)
    local contents = T.contents(storage)
    local arcStats = S.resolve(contents)
    local cycle, status = require("OMHTT/TurretFeed").update(contents, arcStats, 1000, true)
    local fired, rounds = require("OMHTT/TurretFeed").consume(contents, arcStats, cycle, 1000)
    assert(status == "Ready" and fired and rounds == 0 and cycle.nextShot == 2000, "Native Arc ammo-free cadence")
    assert(not T.accept(storage, instanceItem(T.TYPES.Magazine)), "Arc refuses incompatible ammo module")
    assert(not require("OMHTT/TurretAmmo").accepts(arc, "Base.Bullets9mm"), "Arc does not accept ammunition")
    local arcRating, arcDrain = descriptions.rating(arc)
    assert(arcRating.key == "UI_OMHTT_HeadBatteryExtreme" and math.abs(arcDrain - 72) < .0001, "Native Arc cadence-aware rating")
    assert(instanceItem("Base.OMHTTTrapTetherCableVisual"), "Arc electrical segment model exists independently")
    print("[OMHTT-C421] native-arc metadata=pass install=pass no-ammo=pass cooldown=pass rating=Extreme visual-model=registered GPU=pending")
    local shared = {MetalPipe = 1, SmallSheetMetal = 1, ScrapMetal = 2, ElectronicsScrap = 2, ElectricWire = 1, Screws = 8}
    local cases = {
        {"Ballista", {Plank = 4, MetalBar = 2, Rope = 1, Nails = 8}, {"Hammer", "Saw"}, 90},
        {"RotaryBat", {BaseballBat = 2}, {"Hammer"}, 60},
        {"RotaryBlades", {CircularSawblade = 2, MetalBar = 2}, {"SheetMetalSnips"}, 90},
    }
    local resources = ArrayList.new()
    for n = 1, #cases do
        local case = cases[n]
        local recipe = getScriptManager():getCraftRecipe("Base.OMHTTCraft" .. case[1])
        assert(recipe and recipe:needToBeLearn() == (case[1] ~= "RotaryBat"), "Missing head recipe " .. case[1])
        assert(math.abs(recipe:getTime() * 5 - case[4] * getGameTime():getMultiplierFromTimeDelta(1)) < .001, "Head recipe duration conversion")
        local inputs, tools = ArrayList.new(), {"Screwdriver", "Wrench", "Pliers"}
        for i = 1, #case[3] do tools[#tools + 1] = case[3][i] end
        for i = 1, #tools do inputs:add(instanceItem("Base." .. tools[i])) end
        for _, group in pairs({shared, case[2]}) do
            for name, count in pairs(group) do
                for i = 1, count do inputs:add(instanceItem("Base." .. name)) end
            end
        end
        local data = CraftRecipeData.new(CraftMode.Handcraft, false, true, false, true)
        data:setRecipe(recipe)
        assert(data:canConsumeInputs(resources, inputs, true, true), "Native head ingredients rejected: " .. case[1])
        for i = 0, inputs:size() - 1 do
            local item = inputs:get(i)
            assert(item, "Missing native recipe material")
            player:getInventory():AddItem(item)
            for j = 0, recipe:getInputs():size() - 1 do data:offerInputItem(recipe:getInputs():get(j), item) end
        end
        assert(data:consumeInputs(resources) and data:createOutputs(resources, player), "Head recipe transaction failed")
        data:luaCallOnCreate(player)
        data:processDestroyAndUsedItems(player)
        local head = data:getFirstCreatedItem()
        assert(head and head:getFullType() == "Base.OMHTTTurret" .. case[1] and data:getAllCreatedItems():size() == 1, "Head output identity/count")
        for i = 0, #tools - 1 do assert(player:getInventory():contains(inputs:get(i)), "Head craft consumed retained tool") end
        local base = instanceItem(T.BASE)
        local inventory = base:getInventory()
        T.configure(inventory)
        assert(T.accept(inventory, head), "Head install rejected")
        inventory:AddItem(head)
        local stats = S.resolve(T.contents(inventory))
        assert(stats.headKind == case[1], "Native head profile mismatch")
        if stats.rotary then
            local splitter = instanceItem(T.TYPES.Splitter)
            assert(not T.accept(inventory, splitter), "Rotary accepted incompatible Splitter")
            inventory:AddItem(splitter)
            local contents = T.contents(inventory)
            assert(not contents.active.Splitter and contents.powerLoad == 0 and T.canRemove(inventory, splitter), "Incompatible stored module must be inactive/removable/free of power cost")
            assert(not T.accept(inventory, instanceItem("Base.Potato")), "Rotary accepted ammunition")
        else
            local spear = instanceItem("Base.SpearCrafted")
            assert(T.accept(inventory, spear) and not T.accept(inventory, instanceItem("Base.Potato")), "Ballista feed identity mismatch")
            inventory:AddItem(spear)
            assert(T.contents(inventory).ammo == 1, "Ballista native spear inventory count")
            assert(Heads.accuracy(stats, 12) == 60, "Ballista midpoint accuracy")
        end
    end
    for _, name in pairs({"SpearCraftedSwing", "AxeSawBladeHit", "BaseballBatHit"}) do
        assert(GameSounds.getSound(name), "Native head sound missing: " .. name)
    end
    print("[OMHTT-Heads] native recipes=3 outputs=3 retainedTools=verified timing=verified ammo=spears modules=filtered sounds=3")
    require("OMHTT/NativeContentC247")(player)
end

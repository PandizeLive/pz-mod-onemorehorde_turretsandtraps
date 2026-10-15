return function(player)
    local T = require("OMHTT/Turret")
    local Void = require("OMHTT/TurretVoid")
    local Feed = require("OMHTT/TurretFeed")
    local recipes = {
        {"Lobber", {MetalPipe = 2, SmallSheetMetal = 2, ScrapMetal = 2, ElectronicsScrap = 4, ElectricWire = 2, Screws = 12, TirePump = 1}, "OMHTTTurretLobber"},
        {"LobberImprovised", {MetalPipe = 2, SmallSheetMetal = 2, ScrapMetal = 4, ElectronicsScrap = 4, ElectricWire = 2, Screws = 12}, "OMHTTTurretLobber"},
        {"Scrapshot", {MetalPipe = 1, SmallSheetMetal = 1, ScrapMetal = 2, ElectronicsScrap = 2, ElectricWire = 1, Screws = 8, TirePump = 1}, "OMHTTTurretScrapshot"},
        {"ScrapshotImprovised", {MetalPipe = 2, SmallSheetMetal = 1, ScrapMetal = 4, ElectronicsScrap = 2, ElectricWire = 1, Screws = 8}, "OMHTTTurretScrapshot"},
        {"MakeshiftBomb", {MetalPipe = 1, ScrapMetal = 2, ElectronicsScrap = 1, GunPowder = 1, DuctTape = 1}, "OMHTTAmmoMakeshiftBomb"},
    }
    local resources = ArrayList.new()
    for n = 1, #recipes do
        local case, inputs, kept = recipes[n], ArrayList.new(), {}
        for _, name in pairs({"Screwdriver", "Wrench", "Pliers", "Saw"}) do
            local item = instanceItem("Base." .. name)
            assert(item, "Missing native retained tool " .. name)
            inputs:add(item)
            kept[#kept + 1] = item
        end
        local powder, tape
        for name, count in pairs(case[2]) do
            for _ = 1, count do
                local item = instanceItem("Base." .. name)
                assert(item, "Missing native material " .. name)
                inputs:add(item)
                if name == "GunPowder" then powder = item end
                if name == "DuctTape" then tape = item end
            end
        end
        local powderUses = powder and powder:getCurrentUses()
        local tapeUses = tape and tape:getCurrentUses()
        local recipe = getScriptManager():getCraftRecipe("Base.OMHTTCraft" .. case[1])
        assert(recipe, "Missing new recipe " .. case[1])
        local data = CraftRecipeData.new(CraftMode.Handcraft, false, true, false, true)
        data:setRecipe(recipe)
        assert(data:canConsumeInputs(resources, inputs, true, true), "New recipe cannot use approved materials: " .. case[1])
        for i = 0, inputs:size() - 1 do
            local item = inputs:get(i)
            player:getInventory():AddItem(item)
            for j = 0, recipe:getInputs():size() - 1 do data:offerInputItem(recipe:getInputs():get(j), item) end
        end
        assert(data:consumeInputs(resources) and data:createOutputs(resources, player), "New native recipe transaction failed")
        data:processDestroyAndUsedItems(player)
        assert(data:getAllCreatedItems():size() == 1 and data:getFirstCreatedItem():getFullType() == "Base." .. case[3], "Recipe output mismatch")
        for i = 1, #kept do assert(player:getInventory():contains(kept[i]), "Retained tool consumed") end
        if powder then
            assert(powder:getCurrentUses() == powderUses - 8 and tape:getCurrentUses() == tapeUses - 2, "Bomb drainable quantities are uses, not whole containers")
        end
    end
    for _, name in pairs({"OMHTTLure", "PipeBombExplode", "JS2000ShotgunShoot", "SpearCraftedHit"}) do
        assert(GameSounds.getSound(name), "New-head sound missing: " .. name)
    end
    local base = instanceItem(T.BASE)
    local storage = base:getInventory()
    T.configure(storage)
    local gun = storage:AddItem("Base.Pistol")
    local module = storage:AddItem(Void.TYPE)
    assert(module and math.abs(module:getActualWeight() - .2) < .00001, "Void module missing or weight changed")
    gun:setContainsClip(true)
    gun:setCurrentAmmoCount(0)
    gun:setRoundChambered(false)
    for _ = 1, 30 do
        local round = player:getInventory():AddItem("Base.Bullets9mm")
        assert(Void.deposit(module, round, player:getInventory()), "Native Void conversion failed")
    end
    local stats = T.cycleConfig(T.contents(storage))
    local cycle, status = Feed.update(T.contents(storage), stats, 1000, true)
    assert(status == "Reloading" and cycle.virtual and gun:getCurrentAmmoCount() == 0, "Virtual firearm must begin an actual reload")
    Feed.update(T.contents(storage), stats, 1000 + stats.reload, true)
    cycle, status = Feed.update(T.contents(storage), stats, 1001 + stats.reload + stats.rack, true)
    assert(status == "Ready" and cycle.loaded <= stats.magazine and not gun:isRoundChambered(), "Virtual magazine leaked into native chamber")
    assert(Feed.consume(T.contents(storage), stats, cycle, 1001 + stats.reload + stats.rack), "Virtual native firearm could not fire")
    assert(Void.count(module) == 29 and gun:getCurrentAmmoCount() == 0 and not gun:isRoundChambered(), "Virtual shot materialized native ammo")
    Feed.cancel(gun)
    storage:Remove(module)
    assert(cycle.loaded == 0 and Void.count(module) == 29, "Removing storage loses or duplicates rounds")
    local bomb = instanceItem("Base.OMHTTAmmoMakeshiftBomb")
    assert(not instanceof(bomb, "HandWeapon"), "Makeshift Bomb accidentally became a handheld explosive")
    print("[OMHTT-C247] recipes=5 drainableUses=8/2 tools=retained sounds=4 virtualNativeGun=no-materialized-rounds exactModule=preserved")
end

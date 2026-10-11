local nativeServer, nativeClient, nativeCell = nil, nil, nil

---@param squares ArrayList Native isolated squares with real chunks
---@return ArrayList fixtures
function OMHTT_NativeBarbCheck(squares)
    assert(GameSounds.getSound("ZombieClawChainlinkFence") ~= nil, "Missing native barb contact cue")
    local B = require("OMHTT/BarbSections")
    local S = require("OMHTT/BarbSupport")
    local C = require("OMHTT/BarbContact")
    nativeServer, nativeClient, nativeCell = isServer, isClient, getCell
    isServer = function() return false end
    isClient = function() return false end
    local cell, lookup = nativeCell(), {}
    for i = 0, squares:size() - 1 do
        local square = squares:get(i)
        local floorObject = IsoObject.new(square, "floors_interior_tilesandwood_01_0", "floor")
        square:getObjects():add(floorObject)
        square:RecalcProperties()
        lookup[square:getX() .. ":" .. square:getY() .. ":0"] = square
    end
    getCell = function() return {getGridSquare = function(_, x, y, z) return lookup[x .. ":" .. y .. ":" .. z] end} end
    B.initialize()
    B.store.nextId = 100000
    local info = SpriteConfigManager.GetObjectInfo("OMHTTBarbs")
    assert(info, "Barb build entity missing")
    local recipe = info:getRecipe():getCraftRecipe()
    assert(recipe:getOnAddToMenu() == "OMHTT_PlacementMenu" and OMHTT_PlacementMenu({recipe = recipe}), "Panel placement Building gate missing")
    recipe = ScriptManager.instance:getCraftRecipe("Base.OMHTTCraftBarbs")
    assert(getRecipeDisplayName("OMHTTBarbs") == "Barbed Panel", "Barb recipe translation missing")
    assert(recipe:getInputs():size() == 6 and recipe:getInputs():get(0):isKeep() and recipe:getInputs():get(1):isKeep(), "Retained barb tools wrong")
    assert(recipe:getRequiredSkill(0):getLevel() == 1 and recipe:getXPAward(0):getAmount() == 10, "Barb skill/XP wrong")
    local player = IsoPlayer.new(cell)
    do
        local builder = OMHTT_NativeBuilder
        builder:setCurrent(squares:get(0))
        builder:setX(squares:get(0):getX() + 0.5)
        builder:setY(squares:get(0):getY() + 0.5)
        builder:setZ(0)
        builder:setPerkLevelDebug(Perks.Woodwork, 1)
        local inventory = builder:getInventory()
        inventory:setCapacity(50)
        local knife = inventory:AddItem(instanceItem("Base.KitchenKnife"))
        for i = 1, 4 do
            inventory:AddItem(instanceItem("Base.Plank"))
            inventory:AddItem(instanceItem("Base.RippedSheets"))
        end
        local containers = ArrayList.new()
        containers:add(inventory)
        local craft = ScriptManager.instance:getCraftRecipe("Base.OMHTTCraftBedSpikes")
        local build = BuildLogic.new(builder, nil, nil)
        local entries = ArrayList.new()
        entries:add(craft)
        build:setContainers(containers)
        build:setRecipes(entries)
        build:setRecipe(craft)
        assert(build:getRecipe() == craft and build:canPerformCurrentRecipe(), "Building cannot display/check original crafting fallback")
        assert(build:getCategoryList():contains("OMHTraps"), "Native Normal category is unavailable")
        local logic = HandcraftLogic.new(builder, nil, nil)
        logic:setContainers(containers)
        logic:setRecipe(craft)
        assert(logic:canPerformCurrentRecipe(), "Native crafting fallback rejects valid ingredients")
        local resolved, bound = logic:getRecipeData():getAllInputItems(), ArrayList.new()
        for i = 0, resolved:size() - 1 do bound:add(resolved:get(i)) end
        logic:setManualSelectInputs(true)
        logic:clearManualInputs()
        for i = 0, bound:size() - 1 do logic:offerInputItem(bound:get(i)) end
        assert(logic:canPerformCurrentRecipe(), "Exact fallback input binding failed")
        require("Entity/TimedActions/ISHandcraftAction")
        local action = ISHandcraftAction.FromLogic(logic)
        action.logic = logic
        assert(logic:isContainersAccessible(containers), "Fixture crafting containers must be in reach")
        action:performRecipe()
        local outputs = logic:getRecipeData():getAllCreatedItems()
        assert(outputs:size() == 2 and inventory:contains(outputs:get(0)) and inventory:contains(outputs:get(1))
            and outputs:get(0):getFullType() == "Base.OMHTTTrapBedSpikes", "Fallback must leave two independent carried tiles")
        assert(inventory:contains(knife) and inventory:getAllTypeRecurse("Base.Plank"):isEmpty()
            and inventory:getAllTypeRecurse("Base.RippedSheets"):isEmpty(), "Fallback must retain tools and consume inputs exactly")
        local deploy = SpriteConfigManager.GetObjectInfo("OMHTTDeployBedSpikes"):getRecipe():getCraftRecipe()
        build:setContainers(containers)
        build:setRecipe(deploy)
        assert(build:canPerformCurrentRecipe(), "Crafted output cannot enter native placement")
        assert(deploy:getXPAwardCount() == 0, "Placement must award no crafting XP")
        local pairItems = ArrayList.new()
        pairItems:add(outputs:get(0))
        local pairData = CraftRecipeData.new(CraftMode.Handcraft, false, true, false, true)
        pairData:setRecipe(deploy)
        assert(not pairData:canConsumeInputs(ArrayList.new(), pairItems, true, true), "One tile must not pay for pair placement")
        pairItems:add(outputs:get(1))
        assert(pairData:canConsumeInputs(ArrayList.new(), pairItems, true, true), "Two tiles must pay for pair placement")
        for i = 0, pairItems:size() - 1 do assert(pairData:offerInputItem(deploy:getInputs():get(0), pairItems:get(i))) end
        assert(pairData:consumeInputs(ArrayList.new()), "Pair placement cannot consume bound tiles")
        pairData:processDestroyAndUsedItems(builder)
        assert(not inventory:contains(pairItems:get(0)) and not inventory:contains(pairItems:get(1)), "Pair placement consumes exactly two inventory units")
        local single = SpriteConfigManager.GetObjectInfo("OMHTTDeployBedSpikesSingle"):getRecipe():getCraftRecipe()
        local recovered = instanceItem("Base.OMHTTTrapBedSpikes")
        inventory:AddItem(recovered)
        local singleData = CraftRecipeData.new(CraftMode.Handcraft, false, true, false, true)
        singleData:setRecipe(single)
        assert(singleData:offerInputItem(single:getInputs():get(0), recovered) and singleData:consumeInputs(ArrayList.new()), "Recovered tile cannot deploy singly")
        singleData:processDestroyAndUsedItems(builder)
        assert(not inventory:contains(recovered), "Single placement fails to consume its exact recovered unit")
        print("[OMHTT-HybridBuild] native-original-recipe=true build-category=true craft-output=exact ingredients=consumed tools=retained deploy-xp=0")
    end
    local data = CraftRecipeData.new(CraftMode.Handcraft, false, true, false, true)
    data:setRecipe(recipe)
    local types, amounts = {"Base.Hammer", "Base.Pliers", "Base.BarbedWire", "Base.Plank", "Base.Nails", "Base.Wire"}, {1, 1, 1, 2, 4, 1}
    local tools, wire = {}, nil
    for i = 1, #types do
        for j = 1, amounts[i] do
            local item = instanceItem(types[i])
            assert(item, "Native ingredient missing " .. types[i])
            player:getInventory():AddItem(item)
            assert(data:offerInputItem(recipe:getInputs():get(i - 1), item), "Native barb input rejected " .. types[i])
            if i <= 2 then tools[#tools + 1] = item end
            if i == 6 then wire = item end
        end
    end
    local before = wire:getCurrentUses()
    assert(data:consumeInputs(ArrayList.new()), "Native barb consumption failed")
    assert(data:createOutputs(ArrayList.new(), player) and data:getAllCreatedItems():size() == 1
        and data:getFirstCreatedItem():getFullType() == "Base.OMHTTTrapBarbedPanel", "Panel crafting must produce one portable item")
    data:processDestroyAndUsedItems(player)
    assert(wire:getCurrentUses() == before - 2, "Wire consumption must be two uses")
    assert(player:getInventory():contains(tools[1]) and player:getInventory():contains(tools[2]), "Barb tools consumed")
    assert(player:getInventory():getItemCountRecurse("Base.BarbedWire") == 0 and player:getInventory():getItemCountRecurse("Base.Plank") == 0
        and player:getInventory():getItemCountRecurse("Base.Nails") == 0, "Barb ingredients not consumed exactly")
    assert(tools[2]:hasTag(ItemTag.PLIERS), "Pliers service tag missing")
    local Service = require("OMHTT/BarbService")
    assert(Service and type(Service.tools) == "function", "Barb service unavailable through shared loading")
    local placement = info:getRecipe():getCraftRecipe()
    assert(placement:getInputs():size() == 3 and placement:getXPAwardCount() == 0
        and placement:getRequiredSkillCount() == 0, "Attachment must consume only panel plus retained tools without repeating skill/XP")
    local faces, fixtures = {"e", "n", "w", "s"}, ArrayList.new()
    for i = 0, 7 do
        local facing = faces[i % 4 + 1]
        local x, y, north = C.edge(1000 + i * 4, 1000, facing)
        local square = lookup[x .. ":" .. y .. ":0"]
        local host
        if i < 4 then
            host = IsoWindow.new(cell, square, getSprite(north and "fixtures_windows_01_1" or "fixtures_windows_01_0"), north)
        else
            host = IsoThumpable.new(cell, square, north and "carpentry_02_81" or "carpentry_02_80", north)
            host:setMaxHealth(200)
            host:setHealth(137)
            host:setIsThumpable(true)
        end
        square:getObjects():add(host)
        square:getSpecialObjects():add(host)
        local floor = lookup[(1000 + i * 4) .. ":1000:0"]
        local face = info:getFace(facing)
        assert(face:getWidth() == 1 and face:getHeight() == 1, "Barb footprint wrong")
        local valid = {square = floor, facing = facing}
        assert(B.onIsValid(valid) and valid.testCollisions == false, "Native backed panel preview rejected: " .. facing)
        local panel = instanceItem("Base.OMHTTTrapBarbedPanel")
        player:getInventory():AddItem(panel)
        local attach = CraftRecipeData.new(CraftMode.Handcraft, false, true, false, true)
        attach:setRecipe(placement)
        assert(attach:offerInputItem(placement:getInputs():get(0), panel)
            and attach:offerInputItem(placement:getInputs():get(1), tools[1])
            and attach:offerInputItem(placement:getInputs():get(2), tools[2]), "Native attach exact inputs rejected")
        assert(attach:consumeInputs(ArrayList.new()), "Native panel consumption failed")
        attach:processDestroyAndUsedItems(player)
        assert(not player:getInventory():contains(panel) and player:getInventory():contains(tools[1])
            and player:getInventory():contains(tools[2]), "Attach must consume one panel and retain tools")
        local original = IsoThumpable.new(cell, floor, face:getTileInfo(0, 0, 0):getSpriteName(), north)
        floor:getObjects():add(original)
        floor:getSpecialObjects():add(original)
        GameEntityFactory.CreateIsoObjectEntity(original, info:getScript():getParent(), true)
        local result = B.onCreate({thumpable = original, character = player, facing = facing})
        local frame = result.object
        assert(not B.onIsValid(valid), "Native duplicate panel preview accepted")
        local record = B.record(frame)
        local resolved, exact, attachment, status = B.resolve(record)
        assert(resolved == frame and exact == host and status == "active", "Native frame/support binding failed")
        assert(not frame:isThumpable() and frame:isCanPassThrough(), "Native barb marker changes traversal")
        if i < 4 then
            assert(not attachment.shared and attachment.health == 50 and host:getHealth() == 50, "Window HP was changed or shared")
            S.wear(attachment, .1)
            S.wear(attachment, .1)
            S.wear(attachment, .1)
        else
            assert(attachment.shared and host:getHealth() == 137, "Constructed host health was changed")
        end
        fixtures:add(frame)
        fixtures:add(host)
    end
    local wireInfo = SpriteConfigManager.GetObjectInfo("OMHTTDeployConcertinaWire")
    for _, direction in pairs({"e", "n", "w", "s"}) do
        local face = wireInfo:getFace(direction)
        assert(face:getWidth() * face:getHeight() == 2, "Wire must occupy two native tiles in every orientation")
    end
    local wireRecipe = ScriptManager.instance:getCraftRecipe("Base.OMHTTCraftConcertinaWire")
    assert(wireRecipe:getRequiredSkillCount() == 0 and wireRecipe:getXPAwardCount() == 0
        and wireRecipe:getInputs():size() == 3 and wireRecipe:getInputs():get(0):isKeep(), "Wire recipe skill/XP/tools differ")
    assert(wireRecipe:getTime() * 5 == 10 * getGameTime():getMultiplierFromTimeDelta(1), "Wire crafting must take ten seconds")
    local inputs = CraftRecipeData.new(CraftMode.Handcraft, false, true, false, true)
    inputs:setRecipe(wireRecipe)
    local pliers, barbedWire, binding = instanceItem("Base.Pliers"), instanceItem("Base.BarbedWire"), instanceItem("Base.Wire")
    local ingredients = {pliers, barbedWire, binding}
    for i = 1, #ingredients do
        player:getInventory():AddItem(ingredients[i])
        assert(inputs:offerInputItem(wireRecipe:getInputs():get(i - 1), ingredients[i]), "Wire input rejected")
    end
    local wireUses = binding:getCurrentUses()
    assert(inputs:consumeInputs(ArrayList.new()) and inputs:createOutputs(ArrayList.new(), player), "Wire craft transaction failed")
    inputs:processDestroyAndUsedItems(player)
    assert(inputs:getAllCreatedItems():size() == 1 and inputs:getFirstCreatedItem():getFullType() == "Base.OMHTTTrapConcertinaWire"
        and player:getInventory():contains(pliers) and not player:getInventory():contains(barbedWire)
        and binding:getCurrentUses() == wireUses - 2, "Wire craft does not conserve inputs/output")
    local floor, tailFloor = lookup["1000:1001:0"], lookup["1001:1001:0"]
    local preview = {square = floor, facing = "n", tileInfo = wireInfo:getFace("n"):getTileInfo(0, 0, 0)}
    assert(B.onWireValid(preview), "Clear paired floor rejects wire")
    local coil = IsoThumpable.new(cell, floor, "omhtt_barrier_01_61", false)
    floor:getObjects():add(coil); floor:getSpecialObjects():add(coil)
    GameEntityFactory.CreateIsoObjectEntity(coil, wireInfo:getScript():getParent(), true)
    B.onWireCreate({thumpable = coil})
    local tail = IsoThumpable.new(cell, tailFloor, "omhtt_barrier_01_73", false)
    tailFloor:getObjects():add(tail); tailFloor:getSpecialObjects():add(tail)
    GameEntityFactory.CreateIsoObjectEntity(tail, wireInfo:getScript():getParent(), true)
    B.onWireCreate({thumpable = tail})
    local wireRecord = B.record(coil)
    assert(wireRecord.kind == "wire" and wireRecord.health == 50 and coil:isCanPassThrough() and not coil:isThumpable(),
        "Wire durability or native collision differs")
    assert(B.record(tail) == wireRecord and B.resolve(wireRecord) == coil, "Paired native wire identity differs")
    assert(not B.onWireValid(preview), "Wire permits duplicate placement")
    for i = 1, 3 do S.wear(wireRecord, .1) end
    fixtures:add(coil)
    fixtures:add(tail)
    print("[OMHTT-Wire] craft=exact wireUses=2 pliers=retained skills=0 xp=0 footprint=2 durability=shared50 duplicate=blocked")
    print("[OMHTT-Barbs] PASS construction=8 facings=4 tools=retained wireUses=2 recipe=exact separateWindowHP=50 sharedHostHP=137")
    return fixtures
end

---@param fixtures ArrayList Restored native frame/support pairs
---@return boolean valid
function OMHTT_NativeBarbRestoredCheck(fixtures)
    local B = require("OMHTT/BarbSections")
    B.initialize()
    for i = 0, 15, 2 do
        local frame = fixtures:get(i)
        local resolved, host, attachment, status = B.resolve(B.record(frame))
        assert(resolved == frame and host == fixtures:get(i + 1) and status == "active", "Restored backing identity did not resolve")
        assert(attachment.shared or attachment.health == 47, "Independent durability did not survive")
    end
    local wire = fixtures:get(16)
    B.loaded(fixtures:get(17):getSquare())
    B.loaded(wire:getSquare())
    local frame, _, record, status = B.resolve(B.record(wire))
    assert(frame == wire and status == "active" and record.health == 47 and record.kind == "wire", "Wire state lost on reload")
    assert(B.record(fixtures:get(17)) == record and record.paired, "Restored halves lost shared durability")
    isServer, isClient, getCell = nativeServer, nativeClient, nativeCell
    return true
end

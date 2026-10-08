local nativeServer, nativeClient, nativeCell = nil, nil, nil

---@param squares ArrayList Native isolated squares with real chunks
---@return ArrayList fixtures
function OMHTT_NativeBarbCheck(squares)
    local B = require("OMHTT/BarbSections")
    local S = require("OMHTT/BarbSupport")
    local C = require("OMHTT/BarbContact")
    nativeServer, nativeClient, nativeCell = isServer, isClient, getCell
    isServer = function() return false end
    isClient = function() return false end
    local cell, lookup = nativeCell(), {}
    for i = 0, squares:size() - 1 do
        local square = squares:get(i)
        lookup[square:getX() .. ":" .. square:getY() .. ":0"] = square
    end
    getCell = function() return {getGridSquare = function(_, x, y, z) return lookup[x .. ":" .. y .. ":" .. z] end} end
    B.initialize()
    B.store.nextId = 100000
    local info = SpriteConfigManager.GetObjectInfo("OMHTTBarbs")
    assert(info, "Barb build entity missing")
    local recipe = info:getRecipe():getCraftRecipe()
    assert(recipe:getOnAddToMenu() == "OMHTT_BarbMenuAvailable" and OMHTT_BarbMenuAvailable(), "Barb construction menu is closed in SP")
    assert(getRecipeDisplayName("OMHTTBarbs") == "Barbed Section", "Barb recipe translation missing")
    assert(recipe:getInputs():size() == 6 and recipe:getInputs():get(0):isKeep() and recipe:getInputs():get(1):isKeep(), "Retained barb tools wrong")
    assert(recipe:getRequiredSkill(0):getLevel() == 1 and recipe:getXPAward(0):getAmount() == 10, "Barb skill/XP wrong")
    local player = IsoPlayer.new(cell)
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
    data:processDestroyAndUsedItems(player)
    assert(wire:getCurrentUses() == before - 2, "Wire consumption must be two uses")
    assert(player:getInventory():contains(tools[1]) and player:getInventory():contains(tools[2]), "Barb tools consumed")
    assert(player:getInventory():getItemCountRecurse("Base.BarbedWire") == 0 and player:getInventory():getItemCountRecurse("Base.Plank") == 0
        and player:getInventory():getItemCountRecurse("Base.Nails") == 0, "Barb ingredients not consumed exactly")
    assert(tools[2]:hasTag(ItemTag.PLIERS), "Pliers service tag missing")
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
        local original = IsoThumpable.new(cell, floor, face:getTileInfo(0, 0, 0):getSpriteName(), north)
        floor:getObjects():add(original)
        floor:getSpecialObjects():add(original)
        GameEntityFactory.CreateIsoObjectEntity(original, info:getScript():getParent(), true)
        local result = B.onCreate({thumpable = original, character = player, facing = facing})
        local frame = result.object
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
    print("[OMHTT-Barbs] PASS construction=8 facings=4 tools=retained wireUses=2 recipe=exact separateWindowHP=50 sharedHostHP=137")
    return fixtures
end

---@param fixtures ArrayList Restored native frame/support pairs
---@return boolean valid
function OMHTT_NativeBarbRestoredCheck(fixtures)
    local B = require("OMHTT/BarbSections")
    for i = 0, fixtures:size() - 1, 2 do
        local frame = fixtures:get(i)
        local resolved, host, attachment, status = B.resolve(B.record(frame))
        assert(resolved == frame and host == fixtures:get(i + 1) and status == "active", "Restored backing identity did not resolve")
        assert(attachment.shared or attachment.health == 47, "Independent durability did not survive")
    end
    isServer, isClient, getCell = nativeServer, nativeClient, nativeCell
    return true
end

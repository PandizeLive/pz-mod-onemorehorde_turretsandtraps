---@return nil
local function checkBeds()
    local sounds = {"ZombieTrip", "BodyHitGround", "SpearCraftedHit"}
    for i = 1, #sounds do assert(GameSounds.getSound(sounds[i]) ~= nil, "Missing native bed sound: " .. sounds[i]) end
    local B = require("OMHTT/BedSpikes")
    local oldServer, oldClient, oldCell = isServer, isClient, getCell
    isServer = function() return false end
    isClient = function() return false end
    local cell = oldCell()
    local squares = {}
    getCell = function() return {getGridSquare = function(_, x, y, z) return squares[x .. ":" .. y .. ":" .. z] end} end
    B.initialize()
    OMHTT_NativeBedFixtures = ArrayList.new()
    assert(SandboxVars.OMHTurretsTraps.BedWear == 6 and SandboxVars.OMHTurretsTraps.BedDamage == 20
        and SandboxVars.OMHTurretsTraps.BedReinforcedDamage == 50, "Bed tuning defaults missing")
    local entities = {"OMHTTBedSpikes", "OMHTTDeployBedSpikes", "OMHTTDeployReinforcedBedSpikes"}
    local faces = {"e", "n", "w", "s"}
    for e = 1, #entities do
        local info = SpriteConfigManager.GetObjectInfo(entities[e])
        assert(info ~= nil, "Bed entity missing: " .. entities[e])
        local recipe = info:getRecipe():getCraftRecipe()
        assert(callLuaBool(recipe:getOnAddToMenu(), {recipe = recipe}) == (e > 1), "Building must expose current bed placement routes only")
        if e == 1 then
            recipe = ScriptManager.instance:getCraftRecipe("Base.OMHTTCraftBedSpikes")
            assert(recipe:getInputs():size() == 3 and recipe:getInputs():get(0):isKeep()
                and recipe:getInputs():get(1):getIntAmount() == 4 and recipe:getInputs():get(2):getIntAmount() == 4,
                "Bed construction inputs differ from approval")
            assert(recipe:getRequiredSkill(0):getLevel() == 1 and recipe:getXPAward(0):getAmount() == 10, "Bed skill/XP differ")
        end
        for f = 1, #faces do
            local face = info:getFace(faces[f])
            assert(face:getWidth() * face:getHeight() == 2, "Bed footprint is not two tiles")
            local baseX, baseY = 800 + e * 20 + f * 3, 800
            local parts = {}
            for x = 0, face:getWidth() - 1 do
                for y = 0, face:getHeight() - 1 do
                    local name = face:getTileInfo(x, y, 0):getSpriteName()
                    local square = IsoGridSquare.new(cell, nil, baseX + x, baseY + y, 0)
                    squares[(baseX + x) .. ":" .. (baseY + y) .. ":0"] = square
                    local object = IsoThumpable.new(cell, square, name, false)
                    square:getObjects():add(object)
                    square:getSpecialObjects():add(object)
                    GameEntityFactory.CreateIsoObjectEntity(object, info:getScript():getParent(), true)
                    B.onCreate({thumpable = object, facing = faces[f]})
                    assert(object:isBush() and square:hasBush(), "Bed must use native bush movement recognition")
                    assert(object:isCanPassThrough() and not object:isHoppable() and not object:isThumpable(), "Native bed movement flags incorrect")
                    parts[#parts + 1] = object
                end
            end
            local record = B.record(parts[1])
            assert(record == B.record(parts[2]) and #B.parts(record) == 2, "Bed lost shared identity")
            record.health = record.maxHealth - 6
            for p = 1, #parts do
                parts[p]:setHealth(record.health)
                OMHTT_NativeBedFixtures:add(parts[p])
            end
        end
    end
    local zombie = IsoZombie.new(cell)
    zombie:setVariable("BumpAnimFinished", false)
    zombie:setVariable("SprinterTripped", false)
    zombie:setBumpType("OMHTTBedTrip")
    assert(zombie:getBumpType() == "OMHTTBedTrip" and not zombie:isKnockedDown(), "Forward trip must not enter hit knockback")
    for itemType, weight in pairs({OMHTTBarbedPanelItem = 2, OMHTTBedSpikesItem = 3,
        OMHTTReinforcedBedSpikesItem = 4, OMHTTSpikeBarrierItem = 4, OMHTTReinforcedBarrierItem = 5,
        OMHTTTurretBase = 6, OMHTTPotatoHead = 4}) do
        local item = instanceItem("Base." .. itemType)
        assert(item and item:getActualWeight() == weight, "Approved weight mismatch: " .. itemType)
    end
    Translator.loadFiles()
    assert(getRecipeDisplayName("OMHTTPackSpikeBarriers") == "Pack Spike Barriers"
        and getRecipeDisplayName("OMHTTPackReinforcedBarriers") == "Pack Reinforced Spike Barriers", "Pack naming mismatch")
    local player = IsoPlayer.new(cell)
    for _, spec in pairs({
        {"OMHTTReinforceSpikeBarrier", "Base.OMHTTSpikeBarrierItem", "Base.OMHTTReinforcedBarrierItem"},
        {"OMHTTReinforceBedSpikes", "Base.OMHTTBedSpikesItem", "Base.OMHTTReinforcedBedSpikesItem"},
    }) do
        local recipe = ScriptManager.instance:getCraftRecipe("Base." .. spec[1])
        assert(recipe and recipe:getRequiredSkill(0):getLevel() == 3 and recipe:getXPAward(0):getAmount() == 30,
            "Portable reinforcement must preserve approved skill/XP")
        local data = CraftRecipeData.new(CraftMode.Handcraft, false, true, false, true)
        data:setRecipe(recipe)
        local types, amounts = {"Base.Hammer", spec[2], "Base.Plank", "Base.Nails"}, {1, 1, 2, 8}
        local hammer
        for i = 1, #types do
            for j = 1, amounts[i] do
                local item = instanceItem(types[i])
                player:getInventory():AddItem(item)
                assert(data:offerInputItem(recipe:getInputs():get(i - 1), item), "Reinforcement input rejected")
                if i == 1 then hammer = item end
            end
        end
        assert(data:consumeInputs(ArrayList.new()) and data:createOutputs(ArrayList.new(), player), "Portable reinforcement failed")
        data:processDestroyAndUsedItems(player)
        assert(data:getAllCreatedItems():size() == 1 and data:getFirstCreatedItem():getFullType() == spec[3]
            and player:getInventory():contains(hammer), "Reinforcement output/tool mismatch")
    end
    local part = player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L)
    part:setCut(true, true)
    assert(part:isCut() and not part:IsInfected(), "Spike fall must be an environmental laceration")
    player:getInventory():AddItem(instanceItem("Base.Pliers"))
    assert(require("OMHTT/BarbService").tools(player), "Native retained hammer/pliers service lookup failed")
    assert(type(zombie:isGettingUp()) == "boolean" and type(zombie:isCrawling()) == "boolean", "Native recovery/crawler APIs unavailable")
    isServer, isClient, getCell = oldServer, oldClient, oldCell
    print("[OMHTT-Beds] PASS entities=3 facings=4 parts=24 wear=6 damage=20/50 nativeMovementFlags=valid nativeTripAPI=exposed")
end

Events.OnServerStarted.Add(checkBeds)

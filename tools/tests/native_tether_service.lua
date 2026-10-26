return function(player)
    local W = require("OMHTT/ControlWorld")
    local S = require("OMHTT/TetherServer")
    local M = require("OMHTT/TetherMount")
    local Lane = require("OMHTT/TetherLane")
    local Action = require("OMHTT/ControlAction")
    local cell, originalCell = getCell(), getCell
    local square = IsoGridSquare.new(cell, nil, 72, 72, 0)
    local chunk = IsoChunk.new(cell)
    chunk:assignLoadID()
    chunk:setSquare(0, 0, 0, square)
    player:setX(72.5); player:setY(72.5); player:setZ(0); player:setCurrent(square)
    local trap = IsoThumpable.new(cell, square, "omhtt_barrier_01_90", false)
    local button = IsoThumpable.new(cell, square, "lighting_indoor_01_0", false)
    square:getObjects():add(trap); square:getSpecialObjects():add(trap)
    square:getObjects():add(button); square:getSpecialObjects():add(button)
    trap:setMaxHealth(100); trap:setHealth(100); button:setHealth(100)
    local state = W.register(trap, player, "Tether")
    local input = W.register(button, player, "Button")
    state.itemType, state.maxHealth, state.facing, state.recoverAt = "Base.OMHTTTrapTetherDart", 100, "e", 0
    input.recoverAt = 0
    local zombie = IsoZombie.new(cell)
    zombie:setX(72.6); zombie:setY(72.5); zombie:setZ(0); zombie:setCurrent(square); zombie:setHealth(1)
    local oldResolve, oldSupport, oldCast, oldDetect = M.resolve, M.supported, Lane.cast, Lane.detect
    M.resolve = function() return {x=72.1,y=72.5,z=0,dx=1,dy=0,north=false}, button end
    M.supported = function() return true end
    Lane.cast = function() return 0, zombie, "zombie" end
    Lane.detect = function() return zombie end
    getCell = function() return {getGridSquare = function(_, x, y, z) if x==72 and y==72 and z==0 then return square end end} end
    assert(W.link(button, trap, true), "Tether receiver link rejected")
    assert(not state.active, "Linked trap fired from detection alone")
    W.pulse(trap)
    assert(state.active, "Button did not start Tether cycle")
    S.time = S.time + 50; S.step(trap, state)
    assert(math.abs(zombie:getHealth() - .7) < .00001, "Native Tether impact is not 30")
    assert(not zombie:isStaggerBack() and zombie:getBumpType()=="", "Impact must not push or start a reaction")
    for i=1,14 do S.time=S.time+50; S.step(trap,state) end
    assert(math.abs(zombie:getHealth() - .7) < .00001, "Tether pulled before hold elapsed")
    S.time=S.time+50; S.step(trap,state)
    assert(math.abs(zombie:getHealth() - .55) < .00001, "Native Tether pull is not 15")
    for i=1,12 do S.time=S.time+50; S.step(trap,state) end
    assert(not state.active and trap:getHealth()==99 and math.abs(zombie:getHealth()-.55)<.00001, "Released input repeats or wear is wrong")
    assert(W.link(button,trap,false) and state.active, "Last unlink does not restore detection")
    assert(Action:new(player,trap,"TetherEnabled",false,nil,state.id):complete(), "Disable rejected")
    S.time=S.time+50; S.step(trap,state)
    assert(not state.active, "Disabled trap remains busy")
    trap:setHealth(37)
    assert(Action:new(player,trap,"Pickup",nil,nil,state.id):complete(), "Tether pickup failed")
    local packed=player:getInventory():getFirstType("Base.OMHTTTrapTetherDart")
    assert(packed and W.records().packed[tostring(packed:getID())].carriedHealth==37, "Tether pickup loses exact condition")
    W.retire(button); W.removed(button)
    zombie:setHealth(0)
    getCell, M.resolve, M.supported, Lane.cast, Lane.detect = originalCell, oldResolve, oldSupport, oldCast, oldDetect
    local recipe = getScriptManager():getCraftRecipe("Base.OMHTTCraftTether")
    assert(recipe and recipe:getTime() == 288, "Tether crafting time must remain 30 seconds")
    local materials = ArrayList.new()
    for _, fullType in pairs({"Screwdriver", "Pliers", "Wrench", "SmallSheetMetal", "SmallSheetMetal", "MetalBar", "Rope", "Screws", "Screws", "Screws", "Screws", "Wire"}) do
        materials:add(player:getInventory():AddItem("Base." .. fullType))
    end
    local wire = materials:get(materials:size()-1)
    local wireUses = wire:getCurrentUses()
    local data = CraftRecipeData.new(CraftMode.Handcraft, false, true, false, true)
    data:setRecipe(recipe)
    local resources = ArrayList.new()
    assert(data:canConsumeInputs(resources, materials, true, true), "Tether recipe rejects selected materials")
    for i=0,materials:size()-1 do
        for j=0,recipe:getInputs():size()-1 do data:offerInputItem(recipe:getInputs():get(j), materials:get(i)) end
    end
    assert(data:consumeInputs(resources) and data:createOutputs(resources,player), "Tether crafting transaction failed")
    data:processDestroyAndUsedItems(player)
    assert(data:getFirstCreatedItem():getFullType()=="Base.OMHTTTrapTetherDart" and data:getAllCreatedItems():size()==1, "Tether output identity/count")
    for i=0,2 do assert(player:getInventory():contains(materials:get(i)), "Tether craft consumes retained tool") end
    assert(wire:getCurrentUses()==wireUses-2, "Tether recipe must consume two Wire uses")
    print("[OMHTT-C370] native-tether damage=30+15 hold=0.75 links=override unlink=automatic wear=1 pickup=37")
    print("[OMHTT-C370] native-tether-craft output=1 tools=retained wireUses=2")
end

local F = require("OMHTT/Foundation")
local S = require("OMHTT/FoundationServer")
local P = require("OMHTT/BarrierFootprint")
local C = require("OMHTT/Construction")
local B = require("OMHTT/BarrierRetaliation")
testMode = "sp"
testData, testSquares = nil, {}
SandboxVars.OMHTurretsTraps.Enabled = true
SandboxVars.OMHTurretsTraps.SpikeBarrier = true
SandboxVars.OMHTurretsTraps.FoundationTestControls = false
S.initialize()
check(C.onAddToMenu({}), "native construction does not require debug controls")
for _, mode in pairs({"client", "server"}) do
    testMode = mode
    check(C.onAddToMenu({}), "Native construction is available with server completion on " .. mode)
end
testMode = "sp"

local function makeCursor(heading, number, portable)
    local horizontal = heading == "n" or heading == "s"
    local width, height = 1, 2
    if horizontal then width, height = 2, 1 end
    local face = {}
    function face:getWidth() return width end
    function face:getHeight() return height end
    function face:getzLayers() return 1 end
    function face:getFaceName() return heading end
    function face:getTileInfo(x, y, z)
        local part = "A"
        if (heading == "e" and y == 1) or (heading == "n" and x == 1)
            or (heading == "w" and y == 0) or (heading == "s" and x == 0) then part = "B" end
        return {
            getX = function() return x end, getY = function() return y end,
            getSpriteName = function() return "omhtt_barrier_01_" .. ((number - 1) * 2 + (part == "B" and 1 or 0) + (portable and 8 or 0)) end,
        }
    end
    local cursor = {character = testPlayer, consumed = 0, processed = 0, parts = {}, materials = true}
    function cursor:getFace() return face end
    function cursor:getOpenFace() return nil end
    function cursor:haveMaterial() return self.materials or testBuildCheat end
    function cursor:isValidPerSquare(square, tile)
        return C.onIsValid({square = square, tileInfo = tile, facing = heading})
    end
    cursor.isValid = ISBuildIsoEntity.isValid
    function cursor:updateModData() end
    function cursor:setInfo(square, north, sprite)
        local object = IsoThumpable.new(getCell(), square, sprite, C.edgeNorth(sprite, north))
        square:AddSpecialObject(object)
        C.onCreate({thumpable = object, character = testPlayer, facing = heading})
        object:transmitCompleteItemToClients()
        self.parts[#self.parts + 1] = object
    end
    cursor.craftRecipe = {getName = function() return portable and "OMHTTDeploySpikeBarrier" or "OMHTTSpikeBarrier" end}
    local data = {
        getRecipe = function() return cursor.craftRecipe end,
        luaCallOnCreate = function() end,
        processDestroyAndUsedItems = function() cursor.processed = cursor.processed + 1 end,
    }
    cursor.buildPanelLogic = {
        performCurrentRecipe = function()
            if not cursor.materials then return false end
            cursor.consumed = cursor.consumed + 1
            return true
        end,
        getRecipeDataInProgress = function() return data end,
    }
    return cursor
end

local headings = {"e", "n", "w", "s"}
for index = 1, #headings do
    local heading = headings[index]
    local originX, originY = 110 + index * 4, 110
    for x = originX, originX + 2 do
        for y = originY, originY + 2 do makeSquare(x, y, 0) end
    end
    local cursor = makeCursor(heading, index)
    local first = testSquares[F.key(originX, originY, 0)]
    local obstructed = testSquares[F.key(originX, originY + 1, 0)]
    if heading == "n" or heading == "s" then obstructed = testSquares[F.key(originX + 1, originY, 0)] end
    obstructed.free = false
    ISBuildIsoEntity.create(cursor, originX, originY, 0, false, "unused")
    check(cursor.consumed == 0 and #cursor.parts == 0, "native create rejects second-tile obstruction before consumption " .. heading)
    obstructed.free = true
    cursor.materials = false
    ISBuildIsoEntity.create(cursor, originX, originY, 0, false, "unused")
    check(cursor.consumed == 0 and #cursor.parts == 0, "missing ingredients consume/create nothing " .. heading)
    cursor.materials = true
    SandboxVars.OMHTurretsTraps.SpikeBarrier = false
    ISBuildIsoEntity.create(cursor, originX, originY, 0, false, "unused")
    check(cursor.consumed == 0 and not C.onAddToMenu({shouldShowAll = true}), "content toggle gates pending recipe and menu even with show-all")
    SandboxVars.OMHTurretsTraps.SpikeBarrier = true
    ISBuildIsoEntity.create(cursor, originX, originY, 0, false, "unused")
    check(cursor.consumed == 1 and cursor.processed == 1 and #cursor.parts == 2, "native two-tile creation consumes one recipe " .. heading)
    local record = P.slot(first).device
    check(record.facing == (index - 1) * 4 and record.width == 2 and record.builderUsername == testPlayer:getUsername(), "heading and builder persist " .. heading)
    check(cursor.parts[1].data.OMHTT.id == cursor.parts[2].data.OMHTT.id and not cursor.parts[1].blockAll
        and not cursor.parts[1].hoppable and cursor.parts[1]:getNorth() == (heading == "n" or heading == "s")
        and record.collisionModel == "outline-v1" and #P.colliders(record) == 4, "separate native outline stays zombie-blocking " .. heading)
    check(string.find(cursor.parts[1]:getSpriteName(), "omhtt_barrier_01_", 1, true)
        and cursor.parts[1]:getSpriteName() ~= cursor.parts[2]:getSpriteName(), "native parts retain distinct SpriteConfig names " .. heading)
    local nextId = testData.nextId
    C.onCreate({thumpable = cursor.parts[1], character = testPlayer, facing = heading})
    check(testData.nextId == nextId and select(2, F.find(first, record.id)) == 1, "duplicate completion does not create another device " .. heading)
    ISBuildIsoEntity.create(cursor, originX, originY, 0, false, "unused")
    check(cursor.consumed == 1, "replayed native build rejected without a second charge " .. heading)
    cursor.parts[1]:setHealth(83)
    P.sync(P.slot(first))
    check(cursor.parts[2]:getHealth() == 83 and record.condition == 83, "native construction joins shared condition " .. heading)
    testData = nativeRoundTrip(testData)
    S.initialize()
    S.reconcile(first, "construction-test-reload")
    record = P.slot(first).device
    check(record.placementSource == "construction" and record.builderUsername == testPlayer:getUsername() and record.condition == 83,
        "native save roundtrip retains construction identity, builder and condition " .. heading)
    local nx, ny = F.barrierDirection(record.facing)
    local zombie = makeZombie(first, 2)
    function zombie:getX() return first.x + 0.5 + nx end
    function zombie:getY() return first.y + 0.5 + ny end
    zombie.state, zombie.thumpTarget = "ThumpState", cursor.parts[1]
    B.update(zombie)
    zombie.variables[B.TOKEN] = "left"
    B.update(zombie)
    check(zombie:getHealth() == 1.9, "built barrier retaliates without debug controls " .. heading)
    SandboxVars.OMHTurretsTraps.Enabled = false
    zombie.variables[B.TOKEN] = "right"
    B.update(zombie)
    check(zombie:getHealth() == 1.9 and record.condition == 83 and not C.onAddToMenu({}), "master off preserves barrier but stops damage/building")
    SandboxVars.OMHTurretsTraps.Enabled = true
    first:transmitRemoveItemFromSquare(cursor.parts[1])
    for i = 1, 16 do S.tick() end
    check(#first.objects == 0 and cursor.parts[2].removed and P.slot(first).device == nil, "native-built pair retires from either half " .. heading)
end
for x = 140, 142 do
    for y = 140, 142 do makeSquare(x, y, 0) end
end
testData.tileCount = F.MAX_TILES - 1
local capped = makeCursor("e", 1)
ISBuildIsoEntity.create(capped, 140, 140, 0, false, "unused")
check(capped.consumed > 0 and #capped.parts == 2, "Real barrier placement crosses the old 64-entry prototype cap")
P.retire(P.slot(testSquares["140:140:0"]), nil)
testData.tileCount = 0
testBuildCheat = true
local cheat = makeCursor("e", 1)
ISBuildIsoEntity.create(cheat, 140, 140, 0, false, "unused")
check(cheat.consumed == 0 and #cheat.parts == 2, "native build-cheat behavior remains explicit")
ISBuildIsoEntity.create(cheat, 140, 140, 0, false, "unused")
check(#cheat.parts == 2 and cheat.consumed == 0, "Build Cheat cannot overlap an existing barrier")
local overlap = makeCursor("n", 2)
ISBuildIsoEntity.create(overlap, 140, 140, 0, false, "unused")
check(#overlap.parts == 2, "perpendicular native edges may share a corner tile without overlapping collision")
makeSquare(143, 140, 0)
local wall = makeSquare(143, 141, 0)
wall.free = false
local blocked = makeCursor("e", 1)
ISBuildIsoEntity.create(blocked, 143, 140, 0, false, "unused")
check(#blocked.parts == 0, "Build Cheat still rejects physical obstruction under the second half")
testBuildCheat = false

for index = 1, #headings do
    local x, y = 170 + index * 4, 170
    for dx = 0, 2 do
        for dy = 0, 2 do makeSquare(x + dx, y + dy, 0) end
    end
    local cursor = makeCursor(headings[index], index, true)
    local square = testSquares[F.key(x, y, 0)]
    cursor.materials = false
    ISBuildIsoEntity.create(cursor, x, y, 0, false, "unused")
    check(#cursor.parts == 0 and cursor.consumed == 0, "missing portable item preserves footprint " .. headings[index])
    cursor.materials = true
    ISBuildIsoEntity.create(cursor, x, y, 0, false, "unused")
    local record = P.slot(square).device
    check(cursor.consumed == 1 and #cursor.parts == 2 and record.constructionEntity == "OMHTTDeploySpikeBarrier",
        "one portable transaction creates one paired deployment " .. headings[index])
    cursor.parts[1]:setHealth(63)
    P.sync(P.slot(square))
    testData = nativeRoundTrip(testData)
    S.initialize()
    S.reconcile(square, "portable-test-reload")
    check(P.slot(square).device.constructionEntity == "OMHTTDeploySpikeBarrier" and cursor.parts[2]:getHealth() == 63,
        "portable identity and damage persist " .. headings[index])
    ISBuildIsoEntity.create(cursor, x, y, 0, false, "unused")
    check(cursor.consumed == 1 and #cursor.parts == 2, "repeat portable placement rejected before item charge " .. headings[index])
end

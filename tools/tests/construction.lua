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
    check(not C.onAddToMenu({}), "MP construction remains explicitly gated on " .. mode)
end
testMode = "sp"

local function makeCursor(heading, number)
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
            getSpriteName = function() return "media/textures/OMHTT_BuildBarrier" .. string.upper(heading) .. "_" .. part .. ".png" end,
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
        local object = IsoThumpable.new(getCell(), square, sprite, north)
        square:AddSpecialObject(object)
        C.onCreate({thumpable = object, character = testPlayer, facing = heading})
        object:transmitCompleteItemToClients()
        self.parts[#self.parts + 1] = object
    end
    cursor.craftRecipe = {getName = function() return "OMHTTSpikeBarrier" end}
    local data = {
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
    for x = originX, originX + 1 do
        for y = originY, originY + 1 do makeSquare(x, y, 0) end
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
    check(cursor.parts[1].data.OMHTT.id == cursor.parts[2].data.OMHTT.id and cursor.parts[1].blockAll
        and not cursor.parts[1].hoppable, "paired solid non-vaultable native parts " .. heading)
    local nextId = testData.nextId
    C.onCreate({thumpable = cursor.parts[1], character = testPlayer, facing = heading})
    check(testData.nextId == nextId and #first.objects == 1, "duplicate completion does not create another device " .. heading)
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
    check(zombie:getHealth() == 1.8, "built barrier retaliates without debug controls " .. heading)
    SandboxVars.OMHTurretsTraps.Enabled = false
    zombie.variables[B.TOKEN] = "right"
    B.update(zombie)
    check(zombie:getHealth() == 1.8 and record.condition == 83 and not C.onAddToMenu({}), "master off preserves barrier but stops damage/building")
    SandboxVars.OMHTurretsTraps.Enabled = true
    first:transmitRemoveItemFromSquare(cursor.parts[1])
    check(#first.objects == 0 and cursor.parts[2].removed and P.slot(first).device == nil, "native-built pair retires from either half " .. heading)
end
makeSquare(140, 140, 0)
makeSquare(140, 141, 0)
testData.tileCount = F.MAX_TILES - 1
local capped = makeCursor("e", 1)
ISBuildIsoEntity.create(capped, 140, 140, 0, false, "unused")
check(capped.consumed == 0 and #capped.parts == 0, "ledger cap rejects both-tile reservation before materials")
testData.tileCount = 0
testBuildCheat = true
local cheat = makeCursor("e", 1)
ISBuildIsoEntity.create(cheat, 140, 140, 0, false, "unused")
check(cheat.consumed == 0 and #cheat.parts == 2, "native build-cheat behavior remains explicit")
testBuildCheat = false

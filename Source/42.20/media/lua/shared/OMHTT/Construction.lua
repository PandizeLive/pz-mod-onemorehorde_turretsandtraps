local F = require("OMHTT/Foundation")
local Diagnostics = require("OMHTT/Diagnostics")
local Sprites = require("OMHTT/BarrierSprites")
local Geometry = require("OMHTT/BarrierGeometry")
OMHTT_Construction = {}
local Construction = OMHTT_Construction
local facings = {e = 0, n = 4, w = 8, s = 12}
local previewState = nil
local previewTime = -1000
local menuAvailable = nil

---@param sprite string Native part sprite
---@param north boolean Native cursor orientation
---@return boolean north Correct blocking edge for this part
---@nodiscard
function Construction.edgeNorth(sprite, north)
    local index = tonumber(string.match(sprite, "^omhtt_barrier_01_(%d+)$"))
    if index == nil or (index >= 16 and index <= 19) or index > 27 then return north end
    if index >= 20 then
        index = index - 20
    end
    local heading = math.floor(index / 2) % 4
    return heading == 1 or heading == 3
end

---@return nil
function Construction.installEdges()
    if isClient() or isServer() then return end
    require("BuildingObjects/ISBuildingObject")
    require("BuildingObjects/ISBuildIsoEntity")
    if ISBuildIsoEntity.omhttEdgeInstalled then return end
    local original = ISBuildIsoEntity.setInfo
    ---@param self ISBuildIsoEntity Native cursor
    ---@param square IsoGridSquare Part tile
    ---@param north boolean Cursor orientation
    ---@param sprite string Part sprite
    ---@param openSprite string? Open sprite
    ---@return nil
    function ISBuildIsoEntity:setInfo(square, north, sprite, openSprite)
        return original(self, square, Construction.edgeNorth(sprite, north), sprite, openSprite)
    end
    local originalRender = ISBuildIsoEntity.render
    ---@param self ISBuildIsoEntity Native placement cursor
    ---@param x number Cursor X
    ---@param y number Cursor Y
    ---@param z number Floor
    ---@param square IsoGridSquare Cursor square
    ---@return nil
    function ISBuildIsoEntity:render(x, y, z, square)
        originalRender(self, x, y, z, square)
        local face = self:getFace()
        if not face then return end
        for xx = 0, face:getWidth() - 1 do
            for yy = 0, face:getHeight() - 1 do
                local tile = face:getTileInfo(xx, yy, 0)
                local name = tile and tile:getSpriteName()
                local index = name and tonumber(string.match(name, "^omhtt_barrier_01_(%d+)$"))
                if index and (index < 16 or (index >= 20 and index <= 27)) then
                    local visualIndex = index
                    if index >= 20 then
                        visualIndex = index - 20
                    end
                    local facing = math.floor(visualIndex / 2) % 4 * 4
                    local ax, ay = x + xx, y + yy
                    if index % 2 == 1 then
                        local nx, ny = F.barrierDirection(facing)
                        ax, ay = ax + ny, ay - nx
                    end
                    local Outline = require("OMHTT/BarrierOutline")
                    local edges = Geometry.outline({id = "preview", x = ax, y = ay, z = z, facing = facing}, Outline.records())
                    for i = 1, #edges do
                        local edge = edges[i]
                        renderIsoLine(edge.x, edge.y, z, edge.tx, edge.ty, z, 4, 1, 1, 1, 1)
                    end
                    return
                end
            end
        end
    end
    ISBuildIsoEntity.omhttEdgeInstalled = true
    Diagnostics.emit("construction-edge-hook", {model = "outline-v1"})
end

Events.OnGameStart.Add(Construction.installEdges)

---@param params table Native recipe menu parameters
---@return boolean available Initial SP construction gate
---@nodiscard
function Construction.onAddToMenu(params)
    local available = not isClient() and not isServer() and F.barrierEnabled()
    if menuAvailable ~= available then
        menuAvailable = available
        Diagnostics.emit("construction-menu", {available = available, multiplayer = isClient() or isServer()})
    end
    return available
end

OMHTT_ConstructionMenuAvailable = Construction.onAddToMenu

---@param item InventoryItem Recipe input
---@param player IsoGameCharacter Crafter
---@return boolean allowed
---@nodiscard
function Construction.portableInputAllowed(item, player)
    if isClient() or isServer() or not F.barrierEnabled() then return false end
    if item:getFullType() == "Base.OMHTTTrapSpikeBarrier" or item:getFullType() == "Base.OMHTTTrapSpikeBarrierReinforced" then
        return item:getCondition() == item:getConditionMax()
    end
    return true
end

---@param data CraftRecipeData Completed recipe
---@param player IsoGameCharacter Crafter
---@return nil
function Construction.onCrafted(data, player)
    local item = data:getFirstCreatedItem()
    Diagnostics.emit("portable-crafted", {recipe = data:getRecipe():getName(), type = item:getFullType(),
        itemId = item:getID(), weight = item:getActualWeight(), count = data:getAllCreatedItems():size(),
        crafter = player:getUsername()})
end

---@return nil
function Construction.initializeSprites()
    for i = 0, 27 do
        local name = Sprites.SHEET .. i
        local sprite = getSprite(name)
        if sprite:getName() ~= name or sprite:getID() ~= 1918369792 + i then
            error("[OMHTT] Persistent barrier tile missing or conflicting: " .. name)
        end
    end
    -- Direct metadata avoids the tile loader turning these developer markers into generic climbable walls.
    for i = 16, 19 do
        local properties = getSprite(Sprites.SHEET .. i):getProperties()
        local north = i % 2 == 0
        if north then
            properties:set(IsoFlagType.WallN)
            properties:set(IsoFlagType.TallHoppableN)
            properties:set(IsoFlagType.collideN)
            properties:set(IsoFlagType.transparentN)
        else
            properties:set(IsoFlagType.WallW)
            properties:set(IsoFlagType.TallHoppableW)
            properties:set(IsoFlagType.collideW)
            properties:set(IsoFlagType.transparentW)
        end
        properties:set(IsoFlagType.CantClimb)
        properties:set("doorTrans", "true")
        if i >= 18 then
            properties:set(IsoFlagType.WallN)
            properties:set(IsoFlagType.WallW)
        end
    end
    Diagnostics.emit("construction-sprites", {persistent = 28, tiledef = 7316, outlineMetadata = true})
end

Events.OnInitGlobalModData.Add(Construction.initializeSprites)

---@param params table Native per-tile placement parameters
---@return boolean valid Both squares and authority ledger can accept the footprint
---@nodiscard
function Construction.onIsValid(params)
    if isClient() or isServer() or not F.barrierEnabled() then return false end
    local facing = facings[params.facing]
    if facing == nil or not params.square or not params.tileInfo then return false end
    local x = params.square:getX() - params.tileInfo:getX()
    local y = params.square:getY() - params.tileInfo:getY()
    if facing == 8 then
        y = y + 1
    elseif facing == 12 then
        x = x + 1
    end
    local Footprint = require("OMHTT/BarrierFootprint")
    local failure = Footprint.canBuild(x, y, params.square:getZ(), facing)
    if failure == nil then
        params.testCollisions = false
    end
    if Diagnostics.enabled() then
        local status = failure
        if status == nil then
            status = "Ready"
        end
        local state = F.key(x, y, params.square:getZ()) .. ":" .. facing .. ":" .. status
        local now = getTimestampMs()
        if state ~= previewState and (now - previewTime >= 500 or now < previewTime) then
            previewState, previewTime = state, now
            Diagnostics.emit("construction-preview", {x = x, y = y, z = params.square:getZ(), facing = facing, status = status})
        end
    end
    return failure == nil
end

---@param params table Native SpriteConfig completion parameters
---@return nil
function Construction.onCreate(params)
    if isClient() or isServer() then
        error("[OMHTT] Multiplayer construction is not enabled in this checkpoint")
    end
    local object, player = params.thumpable, params.character
    local facing = facings[params.facing]
    if not object or not player or facing == nil then
        error("[OMHTT] Invalid native construction callback")
    end
    local square = object:getSquare()
    local x, y = square:getX(), square:getY()
    local marker = object:getModData().OMHTT
    if marker and marker.placementSource == "construction" then
        x, y = marker.anchorX, marker.anchorY
    else
        local index = tonumber(string.match(object:getSpriteName() or "", "^omhtt_barrier_01_(%d+)$"))
        if index == nil then error("[OMHTT] Invalid barrier construction sprite") end
        if index % 2 == 1 then
            local nx, ny = F.barrierDirection(facing)
            x, y = x + ny, y - nx
        end
    end
    if not marker and not object:getSpriteName() then
        error("[OMHTT] Native construction sprite has no registered name")
    end
    local Footprint = require("OMHTT/BarrierFootprint")
    local entity = object:getSpriteConfig():getObjectInfo():getName()
    Footprint.adoptBuild(object, player, x, y, facing, entity)
    Diagnostics.object(object, "native-construction")
end

return Construction

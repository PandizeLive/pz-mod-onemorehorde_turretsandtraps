local F = require("OMHTT/Foundation")
local Diagnostics = require("OMHTT/Diagnostics")
OMHTT_Construction = {}
local Construction = OMHTT_Construction
local facings = {e = 0, n = 4, w = 8, s = 12}
local previewState = nil
local previewTime = -1000
local menuAvailable = nil

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

---@return nil
function Construction.initializeSprites()
    for heading in pairs(facings) do
        for i = 1, 2 do
            local part = i == 1 and "A" or "B"
            local name = "media/textures/OMHTT_BuildBarrier" .. string.upper(heading) .. "_" .. part .. ".png"
            getSprite(name):setName(name)
        end
    end
    Diagnostics.emit("construction-sprites", {named = 8})
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
    elseif string.match(object:getSpriteName() or "", "_B%.png$") then
        local nx, ny = F.barrierDirection(facing)
        x, y = x + ny, y - nx
    end
    if not marker and not object:getSpriteName() then
        error("[OMHTT] Native construction sprite has no registered name")
    end
    local Footprint = require("OMHTT/BarrierFootprint")
    Footprint.adoptBuild(object, player, x, y, facing)
    Diagnostics.object(object, "native-construction")
end

return Construction

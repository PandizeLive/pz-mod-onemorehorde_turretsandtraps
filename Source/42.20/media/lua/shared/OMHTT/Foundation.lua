---@class OMHTTFoundation
local Foundation = {
    VERSION = "0.2.33",
    MODULE = "OMHTT_Foundation",
    STORE = "OMHTT_Foundation_v1",
    PREFIX = "OMHTT_P1C1_",
    SPRITE = "media/textures/OMHTT_TestCube.png",
    MAX_TILES = 64,
}

LuaEventManager.AddEvent("OnOMHTTDamage")
LuaEventManager.AddEvent("OnOMHTTTurretChanged")

---@param facing number Cardinal heading index
---@return number x Front direction X
---@return number y Front direction Y
---@nodiscard
function Foundation.barrierDirection(facing)
    local quarter = math.floor(Foundation.normalizeFacing(facing) / 4)
    if quarter == 0 then return 1, 0 end
    if quarter == 1 then return 0, -1 end
    if quarter == 2 then return -1, 0 end
    return 0, 1
end

---@param object IsoObject Exact device object
---@param record table Authoritative device state
---@return nil
function Foundation.writeMarker(object, record)
    object:getModData().OMHTT = {
        schema = 1, tier = record.tier, id = record.id, condition = record.condition, revision = record.revision,
        testOwner = record.testOwner, kind = record.kind, ammo = record.ammo, shots = record.shots,
        nextShot = record.nextShot, facing = record.facing, width = record.width,
        anchorX = record.x, anchorY = record.y, anchorZ = record.z,
        placementSource = record.placementSource, builderUsername = record.builderUsername,
        constructionEntity = record.constructionEntity, maxHealth = record.maxHealth, collisionModel = record.collisionModel,
    }
end

---@return boolean enabled Barrier content configuration
---@nodiscard
function Foundation.barrierEnabled()
    local options = SandboxVars.OMHTurretsTraps
    return options ~= nil and options.Enabled ~= false and options.SpikeBarrier ~= false
end

---@param key string Sandbox option key
---@param fallback number Default integer
---@param minimum number Inclusive minimum
---@param maximum number Inclusive maximum
---@return number value Bounded integer; invalid values use the default
local function barrierOption(key, fallback, minimum, maximum)
    local options = SandboxVars.OMHTurretsTraps
    local value = options and options[key]
    if type(value) ~= "number" or value ~= value then return fallback end
    return math.floor(math.max(minimum, math.min(maximum, value)))
end

---@param record table? Defense tier; nil means basic
---@return number damage Readable health points per thump
---@nodiscard
function Foundation.barrierDamage(record)
    if record and record.tier == "reinforced" then return barrierOption("ReinforcedBarrierDamage", 25, 0, 1000) end
    return barrierOption("SpikeBarrierDamage", 10, 0, 1000)
end

---@param record table? Defense tier; nil means basic
---@return number health Shared maximum across both tiles
---@nodiscard
function Foundation.barrierHealth(record)
    if record and record.tier == "reinforced" then
        return barrierOption("SpikeBarrierHealth", 100, 1, 10000) * barrierOption("ReinforcedBarrierHealthMultiplier", 2, 1, 10)
    end
    return barrierOption("SpikeBarrierHealth", 100, 1, 10000)
end

---@return number denominator Zero disables spike scratches
---@nodiscard
function Foundation.barrierScratchChance()
    return barrierOption("SpikeBarrierScratchChance", 5, 0, 50)
end

---@param facing number Signed heading index
---@return number normalized Integer heading in 0-15
---@nodiscard
function Foundation.normalizeFacing(facing)
    local index = math.floor(facing)
    return index - math.floor(index / 16) * 16
end

---@param kind string Prototype kind
---@param facing number Sixteen-step heading
---@return string path Technical sprite path
---@nodiscard
function Foundation.spriteFor(kind, facing)
    facing = Foundation.normalizeFacing(facing)
    if kind == "barrier" then
        return "media/textures/OMHTT_Barrier" .. math.floor(facing / 4) % 4 .. ".png"
    elseif kind == "potato" then
        return "media/textures/OMHTT_Aim" .. facing % 16 .. ".png"
    end
    return "media/textures/OMHTT_Foundation.png"
end

---@param value any Candidate integer
---@param minimum number Inclusive lower bound
---@param maximum number Inclusive upper bound
---@return boolean valid
---@nodiscard
function Foundation.isInteger(value, minimum, maximum)
    return type(value) == "number" and value >= minimum and value <= maximum and value == math.floor(value)
end

---@param x number Tile X
---@param y number Tile Y
---@param z number Tile Z
---@return string key
---@nodiscard
function Foundation.key(x, y, z)
    return tostring(x) .. ":" .. tostring(y) .. ":" .. tostring(z)
end

---@param player IsoPlayer Requesting player
---@return boolean allowed
---@nodiscard
function Foundation.canUse(player)
    if not player or player:isDead() then return false end
    local options = SandboxVars.OMHTurretsTraps
    if not options then return false end
    local traps = options.FoundationTestControls == true and options.Enabled ~= false
    local turrets = options.TurretTestControls == true and options.TurretsEnabled ~= false
    if not traps and not turrets then return false end
    if isClient() then
        return player:getRole():hasCapability(Capability.UseDebugContextMenu)
    elseif isServer() then
        return player:getRole():hasCapability(Capability.UseDebugContextMenu)
    else
        return true
    end
end

---@param object IsoObject World object
---@param id string Expected device identity
---@return boolean matches
---@nodiscard
function Foundation.matches(object, id)
    if object:getName() ~= Foundation.PREFIX .. id or not object:hasModData() then return false end
    local marker = object:getModData().OMHTT
    return type(marker) == "table" and marker.id == id and marker.schema == 1
end

---@param square IsoGridSquare Loaded tile
---@param id string Device identity
---@return IsoObject? object
---@return number count
---@nodiscard
function Foundation.find(square, id)
    local found = nil
    local count = 0
    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do
        local object = objects:get(i)
        if Foundation.matches(object, id) then
            found = object
            count = count + 1
        end
    end
    return found, count
end

---@param square IsoGridSquare Loaded tile
---@return number count
---@nodiscard
function Foundation.countPrototypes(square)
    local count = 0
    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do
        local name = objects:get(i):getName()
        if type(name) == "string" and string.sub(name, 1, #Foundation.PREFIX) == Foundation.PREFIX then
            count = count + 1
        end
    end
    return count
end


---@return boolean visible
---@nodiscard
function OMHTT_PlacementHidden()
    return false
end

return Foundation

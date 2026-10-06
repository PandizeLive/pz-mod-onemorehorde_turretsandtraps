local Foundation = require("OMHTT/Foundation")

---@class OMHTTDiagnostics
local Diagnostics = {}
local sequence = 0
local windowStart = 0
local windowLines = 0
local suppressed = 0
local pending = {}
local pendingFirst, pendingLast = 1, 0
local counters, summaryAt = {}, 0

---@param component string? Optional component filter
---@return boolean enabled
---@nodiscard
function Diagnostics.enabled(component)
    local options = SandboxVars.OMHTurretsTraps
    if not options then return false end
    local traps = (options.FoundationTestControls == true or options.Enabled == true)
        and options.DiagnosticLogging ~= false
    local turrets = (options.TurretTestControls == true or options.TurretsEnabled == true)
        and options.TurretDiagnosticLogging ~= false
    if component == "turrets" then return turrets end
    if component == "traps" then return traps end
    return traps or turrets
end

---@param value any Log value
---@return string safe
---@nodiscard
local function sanitize(value)
    return string.sub(string.gsub(tostring(value), "[%s=]", "_"), 1, 180)
end

---@param event string Diagnostic category
---@param fields table? Scalar evidence
---@param occurredAt number? Original event time for deferred output
---@return nil
function Diagnostics.emit(event, fields, occurredAt, retain)
    if not Diagnostics.enabled() then return end
    local now = getTimestampMs()
    if now - windowStart >= 1000 or now < windowStart then
        windowStart = now
        windowLines = 0
    end
    if windowLines >= 120 then
        if not retain then suppressed = suppressed + 1 end
        return false
    end
    local side = "sp"
    if isClient() then
        side = "client"
    elseif isServer() then
        side = "server"
    end
    sequence = sequence + 1
    windowLines = windowLines + 1
    local line = "[OMHTT-Diag] version=" .. Foundation.VERSION .. " side=" .. side
        .. " seq=" .. sequence .. " ms=" .. tostring(occurredAt or now) .. " event=" .. sanitize(event)
        .. " suppressed=" .. suppressed
    suppressed = 0
    if fields then
        local names = {}
        for name in pairs(fields) do
            names[#names + 1] = name
        end
        table.sort(names)
        for i = 1, #names do
            line = line .. " " .. sanitize(names[i]) .. "=" .. sanitize(fields[names[i]])
        end
    end
    print(line)
    return true
end

---@param object IsoObject Observed world object
---@param reason string Capture reason
---@param playerNum number? Local viewport, omitted on server
---@return nil
function Diagnostics.object(object, reason, playerNum)
    if not Diagnostics.enabled() or not object then return end
    local square = object:getSquare()
    local sprite = object:getSprite()
    local fields = {
        reason = reason, name = tostring(object:getName()), index = object:getObjectIndex(),
        sprite = tostring(object:getSpriteName()), spritePresent = sprite ~= nil,
        offsetX = object:getOffsetX(), offsetY = object:getOffsetY(),
    }
    if square then
        fields.tile = Foundation.key(square:getX(), square:getY(), square:getZ())
        fields.tileObjects = square:getObjects():size()
    end
    if object:hasModData() then
        local marker = object:getModData().OMHTT
        if type(marker) == "table" then
            fields.id, fields.kind, fields.revision = marker.id, marker.kind, marker.revision
            fields.condition, fields.ammo, fields.shots = marker.condition, marker.ammo, marker.shots
            fields.facing, fields.nextShot = marker.facing, marker.nextShot
        end
    end
    if instanceof(object, "IsoThumpable") then
        fields.nativeHP = object:getHealth()
        fields.maxHP = object:getMaxHealth()
        fields.blockAll = object:isBlockAllTheSquare()
        fields.passThrough = object:isCanPassThrough()
        fields.hoppable = object:isHoppable()
        fields.thumpable = object:isThumpable()
    end
    if not isServer() and playerNum ~= nil then
        fields.zoom = getCore():getZoom(playerNum)
        if square then
            fields.tileScreenX = (IsoUtils.XToScreen(square:getX(), square:getY(), square:getZ(), 0)
                - IsoCamera.getOffX(playerNum)) / fields.zoom
            fields.tileScreenY = (IsoUtils.YToScreen(square:getX(), square:getY(), square:getZ(), 0)
                - IsoCamera.getOffY(playerNum)) / fields.zoom
        end
        if sprite then
            local texture = sprite:getTextureForCurrentFrame(IsoDirections.N)
            fields.texturePresent = texture ~= nil
            if texture then
                fields.texture = tostring(texture:getName())
                fields.textureReady = texture:isReady()
                fields.width, fields.height = texture:getWidth(), texture:getHeight()
                fields.originalWidth, fields.originalHeight = texture:getWidthOrig(), texture:getHeightOrig()
                fields.textureOffsetX, fields.textureOffsetY = texture:getOffsetX(), texture:getOffsetY()
            end
        end
    end
    Diagnostics.emit("object", fields)
end

---@return number missing
function Diagnostics.auditTranslations()
    local keys = {
        "ContextMenu_OMHTT_Foundation", "ContextMenu_OMHTT_Inspect", "ContextMenu_OMHTT_Place",
        "ContextMenu_OMHTT_PlaceBarrier", "ContextMenu_OMHTT_PlacePotato", "ContextMenu_OMHTT_Fire",
        "UI_OMHTT_Header", "UI_OMHTT_Placed", "UI_OMHTT_State", "UI_OMHTT_TooFar", "UI_OMHTT_Supplies",
        "Sandbox_OMHTurretsTraps", "Sandbox_OMHTurretsTraps_FoundationTestControls",
        "Sandbox_OMHTurretsTraps_DiagnosticLogging",
        "IGUI_CraftingCategories_OMHTurretsTraps", "UI_OMHTT_SpikeBarrier", "UI_OMHTT_BarrierTools",
    }
    local missing = 0
    for i = 1, #keys do
        local key = keys[i]
        local value = getText(key, "1", "2", "3", "4")
        if value == key or value == "!" .. key then
            missing = missing + 1
            print("[OMHTT] translation-missing key=" .. key .. " expectedFormat=EN/category.json version=" .. Foundation.VERSION)
        end
    end
    print("[OMHTT] translation-audit version=" .. Foundation.VERSION .. " checked=" .. #keys .. " missing=" .. missing)
    return missing
end

---@param event string Diagnostic category
---@param fields table Scalar snapshot
---@return nil
function Diagnostics.defer(event, fields)
    if not Diagnostics.enabled() then return end
    if SandboxVars.OMHTurretsTraps.DetailedLogging ~= true and SandboxVars.OMHTurretsTraps.TurretDetailedLogging ~= true then
        Diagnostics.count(event, 1)
        for key, value in pairs(fields) do
            if type(value) == "number" and string.sub(key, -2) == "Ms" then
                local metric = event .. "_" .. key .. "Max"
                counters[metric] = math.max(counters[metric] or 0, value)
            end
        end
        return
    end
    if pendingLast - pendingFirst + 1 >= 256 then
        suppressed = suppressed + 1
        return
    end
    pendingLast = pendingLast + 1
    pending[pendingLast] = {event = event, fields = fields, at = getTimestampMs()}
end

---@param event string Category
---@param fields table Detail fields
---@return nil
function Diagnostics.trace(event, fields)
    if SandboxVars.OMHTurretsTraps.DetailedLogging == true or SandboxVars.OMHTurretsTraps.TurretDetailedLogging == true then
        Diagnostics.emit(event, fields)
    end
end

---@param event string Category
---@param amount number Occurrences
---@return nil
function Diagnostics.count(event, amount)
    if Diagnostics.enabled() then counters[event] = (counters[event] or 0) + amount end
end

---@return nil
function Diagnostics.flush()
    local now = getTimestampMs()
    if now - summaryAt >= 5000 or now < summaryAt then
        summaryAt = now
        local any = false
        for _ in pairs(counters) do any = true; break end
        if any then Diagnostics.emit("summary", counters); counters = {} end
    end
    if pendingFirst > pendingLast then return end
    if not Diagnostics.enabled() then
        pending, pendingFirst, pendingLast = {}, 1, 0
        return
    end
    local deadline = getTimestampMs() + 1
    for i = 1, 2 do
        if pendingFirst > pendingLast or getTimestampMs() >= deadline then break end
        local entry = pending[pendingFirst]
        pending[pendingFirst], pendingFirst = nil, pendingFirst + 1
        Diagnostics.emit(entry.event, entry.fields, entry.at)
    end
    if pendingFirst > pendingLast then
        pending, pendingFirst, pendingLast = {}, 1, 0
    end
end

---@return nil
function Diagnostics.reset()
    pending, pendingFirst, pendingLast = {}, 1, 0
    counters, summaryAt = {}, 0
    sequence, windowStart, windowLines, suppressed = 0, 0, 0, 0
end

Events.OnTick.Add(Diagnostics.flush)
Events.OnGameStart.Add(Diagnostics.reset)
return Diagnostics

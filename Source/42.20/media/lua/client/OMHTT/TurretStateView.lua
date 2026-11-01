if isServer() then return end
local Options = require("OMHTT/ControlOptions")
local Draw = require("OMHTT/ControlModelDraw")
local T = require("OMHTT/Turret")
local V = {lights = {}, entries = {}, order = {}, cursor = 1, due = 0}
local colors = {Amber = {.8, .45, .05}, Green = {.1, .7, .15}}

---@param entry table Reused native light
---@param strength number Current intensity
---@return nil
local function updateLight(entry, strength)
    if entry.strength == strength and entry.appliedKind == entry.kind then return end
    local color = colors[entry.kind]
    entry.light:setR(color[1] * strength)
    entry.light:setG(color[2] * strength)
    entry.light:setB(color[3] * strength)
    entry.light:setActive(strength > 0)
    entry.strength, entry.appliedKind = strength, entry.kind
end

---@param now number Real milliseconds
---@param start number Start of the warning
---@return number strength Snap on, half-second fade, half-second pause
function V.strength(now, start)
    local phase = math.max(0, now - start) % 1000
    return math.max(0, 1 - phase / 500) ^ 2
end

---@return nil
function V.clear()
    for object, entry in pairs(V.lights) do
        entry.cell:removeLamppost(entry.light)
        V.lights[object] = nil
    end
    V.due = 0
end

---@param object IsoObject Loaded turret
---@param entry table Shared renderer presentation state
---@return nil
function V.track(object, entry)
    if not V.entries[object] then
        V.order[#V.order + 1] = object
    end
    V.entries[object] = entry
end

---@param object IsoObject Turret whose world light must stop
---@return nil
function V.unlight(object)
    local light = V.lights[object]
    if not light then return end
    light.cell:removeLamppost(light.light)
    V.lights[object] = nil
end

---@param state table Replicated turret controls
---@return string kind
function V.kind(state)
    if not T.isOn(state) or state.standby == "disabled" or state.powerSource == "none" then return "Dark" end
    if state.feedStatus == "Empty" or state.standby == "asleep" or state.standby == "waking" then return "Amber" end
    return "Green"
end

---@param object IsoObject Visible turret
---@param entry table Renderer-owned marker cache
---@param square IsoGridSquare Current visible tile
---@param kind string Dark, Amber or Green
---@param empty boolean Powered empty feeder
---@return nil
function V.draw(object, entry, square, kind, empty)
    local now = getTimestampMs()
    if empty then
        if not entry.emptySince or now < entry.emptySince then entry.emptySince = now end
        kind = "Amber"
    else
        entry.emptySince = nil
    end
    if entry.indicatorKind ~= kind then
        entry.indicatorKind = kind
        entry.indicator = instanceItem("Base.OMHTTTurretState" .. kind .. "Visual")
    end
    local alpha = empty and V.strength(now, entry.emptySince) or 1
    if empty then
        entry.darkIndicator = entry.darkIndicator or instanceItem("Base.OMHTTTurretStateDarkVisual")
        Render3DItem(entry.darkIndicator, square, square:getX() + .7, square:getY() + .7, square:getZ() + .28, 0)
    end
    entry.indicator:setWorldAlpha(alpha)
    -- Bypass the static item atlas so the native model respects changing alpha.
    if empty then
        Draw.draw(entry.indicator, square, square:getX() + .7, square:getY() + .7,
            square:getZ() + .281, 0, 0, 0)
    else
        Render3DItem(entry.indicator, square, square:getX() + .7, square:getY() + .7, square:getZ() + .28, 0)
    end
end

---@return nil
function V.tick()
    local now = getTimestampMs()
    if now < V.due and now >= V.due - 50 then return end
    V.due = now + 50
    local enabled = Options.get("StateMarkers") and (SandboxVars.OMHTurretsTraps or {}).TurretStateIndicator ~= false
    local cell, deadline = getCell(), now + 1
    for _ = 1, math.min(64, #V.order) do
        if V.cursor > #V.order then
            V.cursor = 1
        end
        local object = V.order[V.cursor]
        local entry, square, state = V.entries[object], object:getSquare(), T.state(object)
        if not square or not state or object:getObjectIndex() < 0 or not cell
            or cell:getGridSquare(square:getX(), square:getY(), square:getZ()) ~= square then
            V.unlight(object)
            V.entries[object] = nil
            V.order[V.cursor] = V.order[#V.order]
            V.order[#V.order] = nil
        else
            local nearby = false
            if enabled and entry.head then
                for i = 0, getNumActivePlayers() - 1 do
                    local player = getSpecificPlayer(i)
                    if player and math.floor(player:getZ()) == square:getZ()
                        and (player:getX() - square:getX()) ^ 2 + (player:getY() - square:getY()) ^ 2 <= 400 then
                        nearby = true
                        break
                    end
                end
            end
            local kind = V.kind(state)
            if not nearby or not colors[kind] then
                V.unlight(object)
            else
                if state.feedStatus == "Empty" then
                    if not entry.emptySince or now < entry.emptySince then
                        entry.emptySince = now
                    end
                else
                    entry.emptySince = nil
                end
                local strength = entry.emptySince and V.strength(now, entry.emptySince) or 1
                local light = V.lights[object]
                if light and light.cell ~= cell then
                    V.unlight(object)
                    light = nil
                end
                if not light then
                    local source = IsoLightSource.new(square:getX(), square:getY(), square:getZ(), 0, 0, 0, 3)
                    cell:addLamppost(source)
                    light = {cell = cell, light = source}
                    V.lights[object] = light
                end
                light.kind = kind
                updateLight(light, strength)
            end
            V.cursor = V.cursor + 1
        end
        if getTimestampMs() >= deadline then break end
    end
end

Events.OnTick.Add(V.tick)
Events.OnGameStart.Add(V.clear)
return V

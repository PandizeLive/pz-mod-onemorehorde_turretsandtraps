if isServer() then return end
local Options = require("OMHTT/ControlOptions")
local Draw = require("OMHTT/ControlModelDraw")
local V = {lights = {}, due = 0}
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

---@param object IsoObject Visible turret
---@param entry table Renderer-owned marker cache
---@param square IsoGridSquare Current visible tile
---@param kind string Dark, Amber or Green
---@param empty boolean Powered empty feeder
---@param nearby boolean Within local lighting distance
---@return nil
function V.draw(object, entry, square, kind, empty, nearby)
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
    if colors[kind] and nearby then
        local light = V.lights[object]
        if not light then
            local cell = getCell()
            local color = colors[kind]
            local source = IsoLightSource.new(square:getX(), square:getY(), square:getZ(), color[1] * alpha, color[2] * alpha, color[3] * alpha, 3)
            source:setActive(alpha > 0)
            cell:addLamppost(source)
            light = {cell = cell, light = source, kind = kind, appliedKind = kind, strength = alpha}
            V.lights[object] = light
        end
        local changed = light.kind ~= kind or light.start ~= entry.emptySince
        light.seen, light.start, light.kind = now, entry.emptySince, kind
        if changed then updateLight(light, alpha) end
    elseif V.lights[object] then
        local light = V.lights[object]
        light.cell:removeLamppost(light.light)
        V.lights[object] = nil
    end
end

---@return nil
function V.tick()
    local now = getTimestampMs()
    if now < V.due and now >= V.due - 50 then return end
    V.due = now + 50
    local enabled = Options.get("StateMarkers") and (SandboxVars.OMHTurretsTraps or {}).TurretStateIndicator ~= false
    for object, entry in pairs(V.lights) do
        if not enabled or getCell() ~= entry.cell or now - entry.seen > 200 or now < entry.seen
            or object:getObjectIndex() < 0 then
            entry.cell:removeLamppost(entry.light)
            V.lights[object] = nil
        else
            local strength = entry.start and V.strength(now, entry.start) or 1
            updateLight(entry, strength)
        end
    end
end

Events.OnTick.Add(V.tick)
Events.OnGameStart.Add(V.clear)
return V

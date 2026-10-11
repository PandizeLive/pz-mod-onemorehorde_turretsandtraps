if isServer() then return end
require("ISUI/ISUIElement")
local F = require("OMHTT/Foundation")
local D = require("OMHTT/Diagnostics")
local T = require("OMHTT/Turret")
local E = {effects = {}}
local canvas = nil

---@param name string Sound script
---@param x number World X
---@param y number World Y
---@param z number Floor
---@return nil
---@param gain number? Fallback playback gain
function E.sound(name, x, y, z, gain)
    if string.find(name, "OMHTTPotato", 1, true) or string.find(name, "OMHTTSuppressedPotato", 1, true) then
        gain = require("OMHTT/TurretStats").option("PotatoPlaybackVolume", 35, 0, 100) / 100
    end
    local logging = D.enabled("turrets")
    local started = logging and getTimestampMs()
    local emitter = getWorld():getFreeEmitter(x, y, z)
    local acquired = logging and getTimestampMs()
    local handle = emitter:playSound(name)
    local played = logging and getTimestampMs()
    if gain then emitter:setVolume(handle, gain) end
    if logging then
        local finished = getTimestampMs()
        D.defer("potato-audio", {sound = name, x = x, y = y, z = z,
            audioMs = finished - started, emitterMs = acquired - started, playMs = played - acquired,
            volumeMs = finished - played})
    end
end

---@param module string Namespace
---@param command string Launch or Impact
---@param facts table Shot facts; target reference is local SP only
---@return nil
function E.receive(module, command, facts)
    if module == F.MODULE and command == "Volley" then
        for i = 1, math.min(64, #facts.rays) do E.receive(module, "Ray", facts.rays[i]) end
        return
    end
    if module == F.MODULE and command == "GunShot" and facts.deferVisual then
        E.sound(facts.sound or "OMHTTPotatoFire", facts.fromX, facts.fromY, facts.z, facts.gain)
        return
    end
    if module == F.MODULE and command == "Click" then
        if facts.sound then E.sound(facts.sound, facts.x, facts.y, facts.z) end
        return
    end
    if module ~= F.MODULE or (command ~= "Launch" and command ~= "Impact" and command ~= "GunShot" and command ~= "Ray") then return end
    local effect = nil
    for i = 1, #E.effects do
        local entry = E.effects[i]
        if entry.id == facts.id and entry.shot == facts.shot then effect = entry; break end
    end
    if effect and (effect.phase == command or effect.phase == "Impact") then return end
    if not effect then
        if #E.effects >= 64 then table.remove(E.effects, 1) end
        effect = {id = facts.id, shot = facts.shot}
        E.effects[#E.effects + 1] = effect
    end
    effect.phase, effect.start, effect.logged = command, require("OMHTT/TurretClock").now(), false
    effect.x, effect.y, effect.z = facts.x, facts.y, facts.z
    effect.fromX, effect.fromY, effect.flight = facts.fromX, facts.fromY, facts.flight or 0
    effect.target, effect.missed = facts.target, facts.missed
    effect.firearm = facts.firearm == true
    effect.muzzleHeight = facts.muzzleHeight or T.HEAD_VISUAL.height
    if command == "Launch" or command == "GunShot" then
        effect.start = facts.start or effect.start
        local dx, dy = facts.x - facts.fromX, facts.y - facts.fromY
        local distance = math.sqrt(dx * dx + dy * dy)
        if distance > 0 then
            local forward = math.min(facts.muzzle or T.HEAD_VISUAL.muzzle * T.HEAD_VISUAL.scale * 1.5, distance / 2)
            effect.fromX = facts.fromX + dx / distance * forward
            effect.fromY = facts.fromY + dy / distance * forward
        end
        E.sound(facts.sound or "OMHTTPotatoFire", effect.fromX, effect.fromY, facts.z, facts.gain)
    elseif command ~= "Ray" then
        E.sound("OMHTTPotatoImpact", facts.x, facts.y, facts.z)
    end
    D.defer("projectile-effect", {id = facts.id, shot = facts.shot, phase = command, flightMs = effect.flight,
        x = facts.x, y = facts.y, z = facts.z, fromX = effect.fromX, fromY = effect.fromY})
end

---@param effect table Presentation state
---@return number x
---@return number y
---@return number height World Z offset
function E.position(effect)
    local target = effect.target
    if target and target:getSquare() and target:getZ() == effect.z then
        return target:getX(), target:getY(), target:isOnFloor() and 0.06 or 0.30
    end
    return effect.x, effect.y, effect.missed and 0.02 or 0.30
end

---@param x number World X
---@param y number World Y
---@param z number World height
---@param index number Viewport
---@return number screenX
---@return number screenY
function E.screen(x, y, z, index)
    local zoom = getCore():getZoom(index)
    return (IsoUtils.XToScreen(x, y, z, 0) - IsoCamera.getOffX(index)) / zoom + getPlayerScreenLeft(index),
        (IsoUtils.YToScreen(x, y, z, 0) - IsoCamera.getOffY(index)) / zoom + getPlayerScreenTop(index)
end

---@param effect table Tracer
---@param index number Viewport
---@return table? endpoint Last visible point from the muzzle
function E.visibleTrace(effect, index)
    effect.visible = effect.visible or {}
    if effect.visible[index] ~= nil then return effect.visible[index] or nil end
    local dx, dy = effect.x - effect.fromX, effect.y - effect.fromY
    local steps = math.max(1, math.min(100, math.ceil(math.sqrt(dx * dx + dy * dy) * 2)))
    local point = nil
    for step = 0, steps do
        local fraction = step / steps
        local x, y = effect.fromX + dx * fraction, effect.fromY + dy * fraction
        local square = getCell():getGridSquare(math.floor(x), math.floor(y), effect.z)
        if not square or not square:isCanSee(index) then break end
        point = {x = x, y = y}
    end
    effect.visible[index] = point or false
    return point
end

---@return nil
function E.render()
    if #E.effects == 0 then return end
    local started = D.enabled("turrets") and getTimestampMs()
    local now = require("OMHTT/TurretClock").now()
    for i = #E.effects, 1, -1 do
        local effect = E.effects[i]
        local elapsed = now - effect.start
        local traceAge = effect.renderStart and now - effect.renderStart or 0
        if (effect.phase == "Impact" and elapsed >= 450) or (effect.firearm and (traceAge >= 100 or elapsed >= 1000)) or elapsed > effect.flight + 10000 then
            table.remove(E.effects, i)
        else
            for index = 0, getNumActivePlayers() - 1 do
                local player = getSpecificPlayer(index)
                local wx, wy, height = E.position(effect)
                local square = getCell():getGridSquare(math.floor(wx), math.floor(wy), effect.z)
                local trace = effect.firearm and E.visibleTrace(effect, index)
                local visible = effect.firearm and trace or (not effect.firearm and square and square:isCanSee(index))
                if player and math.floor(player:getZ()) == effect.z and visible then
                    if trace then wx, wy = trace.x, trace.y end
                    local renderStarted = getTimestampMs()
                    if not canvas then
                        canvas = ISUIElement:new(0, 0, getCore():getScreenWidth(), getCore():getScreenHeight())
                        canvas:instantiate()
                    end
                    canvas:setStencilRect(getPlayerScreenLeft(index), getPlayerScreenTop(index), getPlayerScreenWidth(index), getPlayerScreenHeight(index))
                    local zoom = getCore():getZoom(index)
                    if effect.phase == "Launch" then
                        local fraction = math.min(1, math.max(0, elapsed / effect.flight))
                        wx = effect.fromX + (wx - effect.fromX) * fraction
                        wy = effect.fromY + (wy - effect.fromY) * fraction
                        height = 0.32 + (height - 0.32) * fraction
                    end
                    local x, y = E.screen(wx, wy, effect.z + height, index)
                    if effect.firearm then
                        effect.renderStart = effect.renderStart or now
                        local sx, sy = E.screen(effect.fromX, effect.fromY, effect.z + effect.muzzleHeight, index)
                        canvas:drawLine(nil, sx, sy, x, y, math.max(1, 1 / zoom), 1 - traceAge / 100, 0.9, 0.85, 0.65)
                    elseif effect.phase == "Launch" then
                        local size = math.max(4, 6 / zoom)
                        canvas:drawRect(x - size / 2, y - size / 2, size, size * 0.75, 1, 0.55, 0.32, 0.13)
                    else
                        local age = elapsed / 450
                        for n = 0, 5 do
                            local angle, radius = n * math.pi / 3, age * 24 / zoom
                            canvas:drawRect(x + math.cos(angle) * radius - 2 / zoom,
                                y + math.sin(angle) * radius - 2 / zoom, 4 / zoom, 4 / zoom, 1 - age, 0.55, 0.32, 0.13)
                        end
                    end
                    canvas:clearStencilRect()
                    if not effect.logged then
                        effect.logged = true
                        D.defer("projectile-first-render", {id = effect.id, shot = effect.shot, phase = effect.phase,
                            screenX = x, screenY = y, zoom = zoom, viewport = index, renderMs = getTimestampMs() - renderStarted})
                    end
                end
            end
        end
    end
    if started then D.measure("effects-render", getTimestampMs() - started) end
end

---@return nil
function E.reset()
    E.effects, canvas = {}, nil
end

Events.OnServerCommand.Add(E.receive)
Events.OnPreUIDraw.Add(E.render)
Events.OnGameStart.Add(E.reset)
return E

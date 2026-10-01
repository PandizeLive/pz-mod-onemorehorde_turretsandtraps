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
function E.sound(name, x, y, z)
    local started = getTimestampMs()
    local emitter = getWorld():getFreeEmitter(x, y, z)
    local handle = emitter:playSound(name)
    local pitch = 0.95 + ZombRand(101) / 1000
    emitter:setPitch(handle, pitch)
    D.defer("potato-audio", {sound = name, pitch = pitch, x = x, y = y, z = z, audioMs = getTimestampMs() - started})
end

---@param module string Namespace
---@param command string Launch or Impact
---@param facts table Shot facts; target reference is local SP only
---@return nil
function E.receive(module, command, facts)
    if module ~= F.MODULE or (command ~= "Launch" and command ~= "Impact") then return end
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
    effect.phase, effect.start, effect.logged = command, getTimestampMs(), false
    effect.x, effect.y, effect.z = facts.x, facts.y, facts.z
    effect.fromX, effect.fromY, effect.flight = facts.fromX, facts.fromY, facts.flight or 0
    effect.target, effect.missed = facts.target, facts.missed
    if command == "Launch" then
        effect.start = facts.start or effect.start
        local dx, dy = facts.x - facts.fromX, facts.y - facts.fromY
        local distance = math.sqrt(dx * dx + dy * dy)
        if distance > 0 then
            local forward = math.min(T.HEAD_VISUAL.muzzle * T.HEAD_VISUAL.scale * 1.5, distance / 2)
            effect.fromX = facts.fromX + dx / distance * forward
            effect.fromY = facts.fromY + dy / distance * forward
        end
        E.sound("OMHTTPotatoFire", effect.fromX, effect.fromY, facts.z)
    else
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

---@return nil
function E.render()
    if #E.effects == 0 then return end
    local now = getTimestampMs()
    for i = #E.effects, 1, -1 do
        local effect = E.effects[i]
        local elapsed = now - effect.start
        if (effect.phase == "Impact" and elapsed >= 450) or elapsed > effect.flight + 10000 then
            table.remove(E.effects, i)
        else
            for index = 0, getNumActivePlayers() - 1 do
                local player = getSpecificPlayer(index)
                local wx, wy, height = E.position(effect)
                local square = getCell():getGridSquare(math.floor(wx), math.floor(wy), effect.z)
                if player and square and math.floor(player:getZ()) == effect.z and square:isCanSee(index) then
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
                    if effect.phase == "Launch" then
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
end

---@return nil
function E.reset()
    E.effects, canvas = {}, nil
end

Events.OnServerCommand.Add(E.receive)
Events.OnPreUIDraw.Add(E.render)
Events.OnGameStart.Add(E.reset)
return E

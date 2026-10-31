if isServer() then return end
require("ISUI/ISUIElement")
local F = require("OMHTT/Foundation")
local D = require("OMHTT/Diagnostics")
local T = require("OMHTT/Turret")
local E = {effects = {}, textures = {}}
local canvas = nil
local phases, phaseOrder, phaseCursor = {}, {}, 1

local function progress(command, facts)
    if not isClient() or (not facts.packet and not facts.predicted) then return true end
    local rank = command == "Impact" and 3 or command == "Land" and 2 or command == "Launch" and 1
    if not rank then return true end
    local key = tostring(facts.id) .. ":" .. tostring(facts.shot)
    local previous = phases[key]
    if previous and previous >= rank then return false end
    if not previous then
        local old = phaseOrder[phaseCursor]
        if old then phases[old] = nil end
        phaseOrder[phaseCursor] = key
        phaseCursor = phaseCursor % 512 + 1
    end
    phases[key] = rank
    return true
end

---@param name string Sound script
---@param x number World X
---@param y number World Y
---@param z number Floor
---@return nil
---@param gain number? Fallback playback gain
function E.sound(name, x, y, z, gain)
    if require("OMHTT/ActiveTime").paused() then return end
    if string.find(name, "OMHTTPotato", 1, true) or string.find(name, "OMHTTSuppressedPotato", 1, true) then
        gain = (gain or 1) * require("OMHTT/TurretStats").option("PotatoPlaybackVolume", 35, 0, 100) / 100
    end
    gain = (gain or 1) * require("OMHTT/ControlOptions").volume()
    if gain <= 0 then return end
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
            volumeMs = finished - played}, "turrets")
    end
end

---@param module string Namespace
---@param command string Launch or Impact
---@param facts table Shot facts; target reference is local SP only
---@return nil
function E.receive(module, command, facts)
    if module ~= F.MODULE or (command ~= "Volley" and command ~= "Click" and command ~= "Launch"
        and command ~= "Land" and command ~= "Impact" and command ~= "GunShot" and command ~= "Ray") then return end
    if module == F.MODULE and not require("OMHTT/DefenseEffects").accept(facts) then return end
    if require("OMHTT/ActiveTime").paused() then return end
    if not progress(command, facts) then return end
    local age = 0
    if command == "Ray" and type(facts.firedAt) == "number" then
        age = math.max(0, GameTime.getServerTimeMills() - facts.firedAt, facts.elapsedMs or 0)
        -- Late network/work results cannot restart a finished muzzle burst.
        if age >= 250 then return end
    end
    if module == F.MODULE and command == "Volley" then
        for i = 1, math.min(64, #facts.rays) do E.receive(module, "Ray", facts.rays[i]) end
        return
    end
    if module == F.MODULE and command == "GunShot" and facts.deferVisual then
        E.sound(facts.sound or "OMHTTPotatoFire", facts.fromX, facts.fromY, facts.z, facts.gain)
        return
    end
    if module == F.MODULE and command == "Click" then
        if not facts.warning and facts.sound ~= "OMHTTTriggerClick" then
            if facts.sound then E.sound(facts.sound, facts.x, facts.y, facts.z, facts.gain) end
            return
        end
        -- Both empty and native firearm misfire cues use the same local warning
        -- envelope. Native weapon sound definitions are otherwise unchanged.
        local distance = 8
        for i = 0, getNumActivePlayers() - 1 do
            local player = getSpecificPlayer(i)
            if player then
                local dx, dy, dz = player:getX() - facts.x, player:getY() - facts.y, player:getZ() - facts.z
                distance = math.min(distance, math.sqrt(dx * dx + dy * dy + dz * dz * 9))
            end
        end
        local gain = (facts.gain or 1) * math.max(0, 1 - distance / 8)^2
        if facts.sound and gain > 0 then E.sound(facts.sound, facts.x, facts.y, facts.z, gain) end
        return
    end
    if module ~= F.MODULE or (command ~= "Launch" and command ~= "Land" and command ~= "Impact" and command ~= "GunShot" and command ~= "Ray") then return end
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
    if command == "Ray" and type(facts.firedAt) == "number" then
        effect.start = effect.start - age
        effect.traceDeadline = effect.start + 250
    end
    effect.x, effect.y, effect.z = facts.x, facts.y, facts.z
    effect.fromX, effect.fromY, effect.flight = facts.fromX, facts.fromY, facts.flight or 0
    effect.target, effect.missed = facts.target, facts.missed
    effect.targetId, effect.targetOutfit = facts.targetId, facts.targetOutfit
    effect.firearm = facts.firearm == true
    effect.projectile = facts.projectile
    effect.contactFlight, effect.excludeId, effect.excludeOutfit = facts.contactFlight, facts.excludeId, facts.excludeOutfit
    effect.ammoType = facts.ammoType or effect.ammoType
    effect.muzzleHeight = facts.muzzleHeight or T.HEAD_VISUAL.height
    if command == "Launch" or command == "GunShot" then
        if not isClient() then
            effect.start = facts.start or effect.start
        elseif command == "Launch" and type(facts.sentAt)=="number" then
            local transit = GameTime.getServerTimeMills()-facts.sentAt
            effect.start = effect.start-math.max(0,math.min(750,transit))
                - math.max(0,math.min(effect.flight, facts.elapsedMs or 0))
        end
        local dx, dy = facts.x - facts.fromX, facts.y - facts.fromY
        local distance = math.sqrt(dx * dx + dy * dy)
        if distance > 0 then
            local forward = math.min(facts.muzzle or T.HEAD_VISUAL.muzzle * T.HEAD_VISUAL.scale * 1.5, distance / 2)
            effect.fromX = facts.fromX + dx / distance * forward
            effect.fromY = facts.fromY + dy / distance * forward
        end
        if not facts.silent then
            E.sound(facts.sound or "OMHTTPotatoFire", effect.fromX, effect.fromY, facts.z, facts.gain)
        end
    elseif command ~= "Ray" and not facts.silent then
        E.sound(facts.sound or (effect.projectile == "spear" and "SpearCraftedHit" or "OMHTTPotatoImpact"), facts.x, facts.y, facts.z, facts.gain)
    end
    D.defer("projectile-effect", {id = facts.id, shot = facts.shot, packet = facts.packet, phase = command, flightMs = effect.flight,
        x = facts.x, y = facts.y, z = facts.z, fromX = effect.fromX, fromY = effect.fromY}, "turrets")
end

---@param effect table Presentation state
---@return number x
---@return number y
---@return number height World Z offset
function E.position(effect)
    local target = effect.target
    if isClient() and effect.targetId and not effect.missed then
        target = require("OMHTT/DefenseCombatClient").find(effect.targetId, effect.targetOutfit)
    end
    if target and not effect.missed and not target:isDead() and target:getSquare() and math.floor(target:getZ()) == effect.z
        and (target:getX() - effect.x)^2 + (target:getY() - effect.y)^2 <= 4 then
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
        if require("OMHTT/PrototypeFlight").contact(effect, now) then
            D.defer("projectile-local-contact", {id=effect.id, shot=effect.shot, elapsedMs=now-effect.start,
                x=effect.x, y=effect.y, flightMs=effect.flight}, "turrets")
            E.receive(F.MODULE,"Impact",{id=effect.id,shot=effect.shot,x=effect.x,y=effect.y,z=effect.z,
                projectile=effect.projectile,ammoType=effect.ammoType,silent=true,predicted=true})
        end
        local elapsed = now - effect.start
        local traceAge = effect.renderStart and now - effect.renderStart or 0
        if (effect.traceDeadline and now >= effect.traceDeadline) or (effect.phase == "Impact" and elapsed >= 450)
            or (effect.firearm and (traceAge >= 100 or elapsed >= 1000)) or elapsed > effect.flight + 750 then
            table.remove(E.effects, i)
        else
            for index = 0, getNumActivePlayers() - 1 do
                local player = getSpecificPlayer(index)
                local wx, wy, height = E.position(effect)
                if effect.phase == "Launch" then
                    local fraction = effect.flight > 0 and math.min(1, math.max(0, elapsed / effect.flight)) or 1
                    if effect.contactFlight and effect.contactDistance then
                        local length = math.sqrt((wx-effect.fromX)^2+(wy-effect.fromY)^2)
                        if length > 0 then fraction = math.min(fraction, effect.contactDistance / length) end
                    end
                    wx = effect.fromX + (wx - effect.fromX) * fraction
                    wy = effect.fromY + (wy - effect.fromY) * fraction
                    height = effect.muzzleHeight + (height - effect.muzzleHeight) * fraction
                    if effect.projectile == "grenade" or effect.projectile == "spear" then height = height + math.sin(fraction * math.pi) * .35 end
                end
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
                    local x, y = E.screen(wx, wy, effect.z + height, index)
                    if effect.firearm then
                        effect.renderStart = effect.renderStart or now
                        local sx, sy = E.screen(effect.fromX, effect.fromY, effect.z + effect.muzzleHeight, index)
                        canvas:drawLine(nil, sx, sy, x, y, math.max(1, 1 / zoom), 1 - traceAge / 100, 0.9, 0.85, 0.65)
                    elseif effect.phase == "Launch" or effect.phase == "Land" then
                        local size = math.max(4, 6 / zoom)
                        if effect.projectile == "spear" then
                            local dx, dy = wx - effect.fromX, wy - effect.fromY
                            local length = math.sqrt(dx * dx + dy * dy)
                            if length > 0 then
                                local sx, sy = E.screen(wx - dx / length * .6, wy - dy / length * .6, effect.z + height, index)
                                canvas:drawLine(nil, sx, sy, x, y, math.max(1, 2 / zoom), 1, .85, .85, .85)
                            end
                        elseif effect.ammoType then
                            local texture = E.textures[effect.ammoType]
                            if texture == nil then
                                local item = instanceItem(effect.ammoType)
                                texture = item and item:getTex() or false
                                E.textures[effect.ammoType] = texture
                            end
                            if texture then
                                local width = math.max(8, 14 / zoom)
                                canvas:drawTextureScaled(texture, x - width / 2, y - width / 2, width, width, 1, 1, 1, 1)
                            else
                                canvas:drawRect(x - size / 2, y - size / 2, size, size * .75, 1, .55, .32, .13)
                            end
                        else
                            canvas:drawRect(x - size / 2, y - size / 2, size, size * 0.75, 1, 0.55, 0.32, 0.13)
                        end
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
                            screenX = x, screenY = y, zoom = zoom, viewport = index, renderMs = getTimestampMs() - renderStarted}, "turrets")
                    end
                end
            end
        end
    end
    if started then D.measure("effects-render", getTimestampMs() - started, "turrets") end
end

---@return nil
function E.reset()
    E.effects, canvas = {}, nil
    phases, phaseOrder, phaseCursor = {}, {}, 1
end

Events.OnServerCommand.Add(E.receive)
Events.OnPreUIDraw.Add(E.render)
Events.OnGameStart.Add(E.reset)
return E

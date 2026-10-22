if isClient() then return end
local Horde = require("OMHTT/DefenseHorde")
local Active = require("OMHTT/ActiveTime")
local P = {entries = setmetatable({}, {__mode = "k"}), clock = Active.new(), time = 0}

function P.option(key, fallback, minimum, maximum)
    local value = SandboxVars.OMHTurretsTraps and tonumber(SandboxVars.OMHTurretsTraps["Poke" .. key])
    return math.max(minimum, math.min(maximum, value or fallback))
end

function P.visual(object, state, raised)
    local W = require("OMHTT/ControlWorld")
    local sprite = "omhtt_barrier_01_" .. (raised and 89 or 85)
    if object:getSpriteName() ~= sprite then
        local old = W.locations[state.location]
        if old then old[state.id] = nil end
        object:setSpriteFromName(sprite)
        state.sprite = sprite
        state.location = state.x .. ":" .. state.y .. ":" .. state.z .. ":" .. sprite
        W.locations[state.location] = W.locations[state.location] or {}
        W.locations[state.location][state.id] = true
        if isServer() then object:transmitUpdatedSpriteToClients() end
    end
    state.active = raised
    W.publish(object)
end

function P.step(object, state)
    local W = require("OMHTT/ControlWorld")
    local now = P.time
    local entry = P.entries[object]
    if not entry then
        entry = {players = setmetatable({}, {__mode = "k"}), due = now + 1000}
        P.entries[object] = entry
        P.visual(object, state, false)
    end
    if entry.finish and now >= entry.finish then
        entry.finish, entry.strike, entry.victims = nil, nil, nil
        P.visual(object, state, false)
    end
    local moving = object:getSquare():getMovingObjects()
    local eligible, requests = false, {}
    entry.scan = (entry.scan or 0) + 1
    for i = 0, moving:size() - 1 do
        local actor = moving:get(i)
        if instanceof(actor, "IsoZombie") and not actor:isDead() and Horde.allowed(actor) then
            eligible = true
        elseif instanceof(actor, "IsoPlayer") and not actor:isDead() and not actor:isGodMod()
            and not actor:isNoClip() and not actor:isGhostMode() then
            local before = entry.players[actor]
            local entered = not before or before.seen ~= entry.scan - 1
            local down = actor:isOnFloor()
            local fall = down and before and not before.down
            if fall or (entered and not down and (actor:isRunning() or actor:isSprinting())
                and ZombRand(100) < P.option("ScratchChance", 20, 0, 100)) then
                requests[actor] = fall and "cut" or "scratch"
                eligible = true
            end
            entry.players[actor] = {seen = entry.scan, down = down}
        end
    end
    local enabled = state.enabled ~= false and object:getHealth() > 0
        and SandboxVars.OMHTurretsTraps.Enabled ~= false
    if not entry.finish and now >= entry.due and enabled and eligible then
        local duration = P.option("CycleSeconds", 1.5, .3, 60) * 1000
        entry.finish, entry.strike, entry.due = now + duration, now + math.min(150, duration / 3), now + duration
        entry.victims = requests
        state.powerSource = nil
        P.visual(object, state, true)
        require("OMHTT/ControlAudio").emit(object, "poke")
    end
    if not entry.strike or now < entry.strike then return end
    entry.strike = nil
    local worn = false
    local function wear(lost)
        if worn or lost <= 0 or W.state(object) ~= state or object:getObjectIndex() < 0 then return end
        worn = true
        object:setHealth(math.max(0, object:getHealth() - P.option("Wear", 1, 0, 1000)))
        if isServer() then object:sync() end
    end
    for i = 0, moving:size() - 1 do
        local actor = moving:get(i)
        if instanceof(actor, "IsoZombie") and not actor:isDead() and Horde.allowed(actor) then
            require("OMHTT/Damage").resolve(actor, P.option("Damage", 45, 0, 2500) / 100, state.id, "poke-floor", wear)
        elseif entry.victims[actor] and not actor:isDead() and not actor:isGodMod()
            and not actor:isNoClip() and not actor:isGhostMode() then
            wear(1)
            require("OMHTT/DefenseInjury").poke(actor, entry.victims[actor])
        end
    end
    entry.victims = nil
    W.publish(object)
end

function P.advance()
    P.time = P.time + math.min(250, Active.step(P.clock))
end

return P

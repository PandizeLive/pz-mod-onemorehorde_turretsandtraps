if isClient() then return end
local Horde = require("OMHTT/DefenseHorde")
local Active = require("OMHTT/ActiveTime")
local P = {entries = setmetatable({}, {__mode = "k"}), objects = {}, clock = Active.new(true), time = 0}
local Actors = require("OMHTT/DefenseActors")
local F = require("OMHTT/Foundation")
local single = {__index = {size = function() return 1 end, get = function(list) return list[1] end}}

function P.register(object, state)
    P.objects[F.key(state.x, state.y, state.z)] = object
    if isServer() then require("OMHTT/DefenseContacts").watch(object, "poke", state.x, state.y, state.x, state.y, state.z) end
end

function P.contact(actor, position)
    local object = P.objects[F.key(math.floor(position.x), math.floor(position.y), position.z)]
    local W = require("OMHTT/ControlWorld")
    local state = object and W.state(object)
    if state and state.kind == "Poke" and object:getObjectIndex() >= 0 then P.step(object, state, actor) end
end

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

function P.step(object, state, contact)
    local W = require("OMHTT/ControlWorld")
    local now = P.time
    local entry = P.entries[object]
    if not entry then
        entry = {players = setmetatable({}, {__mode = "k"}), due = now}
        P.entries[object] = entry
        P.visual(object, state, false)
    end
    if entry.finish and now >= entry.finish then
        entry.finish, entry.cycle = nil, nil
        P.visual(object, state, false)
    end
    local moving = contact and setmetatable({contact}, single) or Actors.at(object:getSquare())
    if isServer() and not contact then
        for i=#moving,1,-1 do
            local actor=moving[i]
            if instanceof(actor,"IsoZombie") and actor:getOwner() then table.remove(moving,i) end
        end
    end
    local eligible, requests = false, {}
    entry.scan = (entry.scan or 0) + (contact and 0 or 1)
    for i = 0, moving:size() - 1 do
        local actor = moving:get(i)
        if instanceof(actor, "IsoZombie") and require("OMHTT/DefenseCombatProtocol").living(actor) and Horde.allowed(actor) then
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
    local enabled = object:getHealth() > 0
        and SandboxVars.OMHTurretsTraps.Enabled ~= false
    if not entry.finish and now >= entry.due and enabled and eligible then
        local duration = P.option("CycleSeconds", 1.5, .3, 60) * 1000
        entry.finish, entry.due = now + duration, now + duration
        entry.cycle = {untilTime = now + 150, hits = setmetatable({}, {__mode = "k"})}
        state.powerSource = nil
        P.visual(object, state, true)
        require("OMHTT/ControlAudio").emit(object, "poke")
    end
    local cycle = entry.cycle
    if not enabled or not cycle or now > cycle.untilTime then return end
    local function wear(lost)
        if cycle.worn or lost <= 0 or W.state(object) ~= state or object:getObjectIndex() < 0 then return end
        cycle.worn = true
        object:setHealth(math.max(0, object:getHealth() - P.option("Wear", 1, 0, 1000)))
        if isServer() then object:sync() end
    end
    for i = 0, moving:size() - 1 do
        local actor = moving:get(i)
        if not cycle.hits[actor] and instanceof(actor, "IsoZombie") and require("OMHTT/DefenseCombatProtocol").living(actor) and Horde.allowed(actor) then
            cycle.hits[actor] = true
            require("OMHTT/Damage").resolve(actor, P.option("Damage", 45, 0, 2500) / 100, state.id, "poke-floor", wear)
        elseif not cycle.hits[actor] and requests[actor] and not actor:isDead() and not actor:isGodMod()
            and not actor:isNoClip() and not actor:isGhostMode() then
            cycle.hits[actor] = true
            wear(1)
            require("OMHTT/DefenseInjury").poke(actor, requests[actor], state.id)
        end
    end
end

function P.advance()
    P.time = P.time + Active.step(P.clock)
end

require("OMHTT/DefenseContacts").handlers.poke = P.contact

return P

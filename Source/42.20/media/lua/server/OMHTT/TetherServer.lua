if isClient() then return end
require("OMHTT/TetherDefinition")
local C = require("OMHTT/TetherCycle")
local Lane = require("OMHTT/TetherLane")
local Mount = require("OMHTT/TetherMount")
local Horde = require("OMHTT/DefenseHorde")
local Active = require("OMHTT/ActiveTime")
local S = {entries = setmetatable({}, {__mode = "k"}), clock = Active.new(true), time = 0, serial = 0, session = tostring(getTimestampMs())}
---@param key string Setting suffix
---@param default number Default
---@param low number Minimum
---@param high number Maximum
---@return number value
local function option(key, default, low, high)
    local value = (SandboxVars.OMHTurretsTraps or {})["Tether" .. key]
    return math.max(low, math.min(high, type(value) == "number" and value or default))
end

---@param entry table Active trap
---@return nil
function S.publish(entry)
    S.serial = S.serial + 1
    local message = C.snapshot(entry.cycle, entry.state.id, S.serial, S.session)
    if isServer() then
        local players = getOnlinePlayers()
        for i = 0, players:size() - 1 do
            local player = players:get(i)
            if math.floor(player:getZ()) == message.z
                and (player:getX() - message.x) ^ 2 + (player:getY() - message.y) ^ 2 <= 6400 then
                sendServerCommand(player, "OMHTTTether", "State", message)
            end
        end
    else
        require("OMHTT/TetherView").receive("OMHTTTether", "State", message)
    end
    entry.sent = S.time
end

---@param cycle table Cycle with active entry
---@param victim IsoGameCharacter? First collision
---@param reason string Classification
---@return nil
local function hit(cycle, victim, reason)
    local entry = cycle.entry
    require("OMHTT/ControlAudio").emit(entry.object, "impact")
    if reason == "zombie" and Horde.allowed(victim) then
        entry.victim = victim
        require("OMHTT/Damage").resolve(victim, option("HitDamage", 30, 0, 2500) / 100, entry.state.id, "tether-dart")
    elseif reason == "player" and require("OMHTT/ControlCombat").protected(require("OMHTT/ControlCombat").source(entry.object), victim) then
        require("OMHTT/DefenseInjury").poke(victim, "scratch", entry.state.id)
    end
end

---@param cycle table Returning nail
---@return nil
local function pull(cycle)
    local entry = cycle.entry
    require("OMHTT/ControlAudio").emit(entry.object, "pull")
    local victim = entry.victim
    entry.victim = nil
    if not victim or victim:isDead() or math.floor(victim:getZ()) ~= cycle.z or not Horde.allowed(victim) then return end
    local square = victim:getSquare()
    if not square or getCell():getGridSquare(square:getX(), square:getY(), square:getZ()) ~= square then return end
    local origin = entry.object:getSquare()
    if not require("OMHTT/DefenseLine").clear(origin, square, cycle.range + 2) then return end
    require("OMHTT/DefenseMotion").request(victim, "pull", entry.state.id, cycle.x, cycle.y,
        option("PullDistance", .75, 0, 2))
    require("OMHTT/Damage").resolve(victim, option("PullDamage", 15, 0, 2500) / 100, entry.state.id, "tether-pull")
end

---@param object IsoObject Trap
---@param state table Authoritative identity
---@return table? entry
function S.entry(object, state)
    local entry = S.entries[object]
    if entry then
        if entry.cycle.phase == "idle" then
            local cycle = entry.cycle
            cycle.range, cycle.speed = option("Range", 6, 1, 32), option("LaunchSpeed", 30, 1, 64)
            cycle.returnSpeed = option("ReturnSpeed", 4, 1, 64)
            cycle.resetTime, cycle.holdTime = option("ResetSeconds", .5, 0, 60), option("HoldSeconds", .75, 0, 10)
        end
        return entry
    end
    local mount, support = Mount.resolve(state.x, state.y, state.z, state.facing)
    if not mount then return nil end
    local tuning = {range = option("Range", 6, 1, 32), speed = option("LaunchSpeed", 30, 1, 64),
        returnSpeed = option("ReturnSpeed", 4, 1, 64), resetTime = option("ResetSeconds", .5, 0, 60),
        holdTime = option("HoldSeconds", .75, 0, 10)}
    local cycle = C.new(mount.x, mount.y, mount.z, mount.dx, mount.dy, tuning)
    entry = {cycle = cycle, mount = mount, support = support, object = object, state = state, time = S.time, sent = S.time, scan = S.time}
    cycle.entry = entry
    S.entries[object] = entry
    return entry
end

---@param object IsoObject Trap
---@return nil
function S.cancel(object)
    local entry = S.entries[object]
    if not entry then return end
    require("OMHTT/ControlAudio").emit(object, "stop")
    C.cancel(entry.cycle)
    S.publish(entry)
    S.entries[object] = nil
end

---@param object IsoObject Trap
---@param state table Authoritative identity
---@param pulse boolean? Fresh button signal
---@return nil
function S.step(object, state, pulse)
    local W = require("OMHTT/ControlWorld")
    if object:getHealth() <= 0 or state.enabled == false or SandboxVars.OMHTurretsTraps.Enabled == false then
        S.cancel(object)
        if state.active then
            state.active = false
            W.publish(object)
        end
        return
    end
    local entry = S.entry(object, state)
    if not entry then return end
    if entry.support:getObjectIndex() < 0 or not Mount.supported(entry.support, entry.mount.north) then
        S.cancel(object)
        state.active = false
        W.publish(object)
        return
    end
    local cycle = entry.cycle
    local elapsed = (S.time - entry.time) / 1000
    entry.time = S.time
    local before, revision = cycle.phase, cycle.revision
    C.step(cycle, elapsed, Lane.cast, hit, pull)
    if before ~= "idle" and cycle.phase == "idle" then
        entry.victim = nil
        object:setHealth(math.max(0, object:getHealth() - 1))
        if isServer() then object:sync() end
    end
    local linked, on, valid, leverAllowed = W.input(object, getTimestampMs())
    cycle.links, cycle.held = linked and 1 or 0, on
    if cycle.phase == "idle" and object:getHealth() > 0 and require("OMHTT/ControlClock").now() >= state.recoverAt then
        local detected = false
        if not linked and S.time >= entry.scan then
            entry.scan = S.time + 200
            local fraction, victim = Lane.cast(cycle, 0, cycle.range)
            detected = fraction ~= nil and require("OMHTT/ControlCombat").eligible(object, victim)
        end
        if C.start(cycle, detected, pulse == true and (not linked or leverAllowed ~= false)) then
            require("OMHTT/ControlAudio").emit(object, "launch")
        end
    end
    if cycle.phase ~= before then
        if cycle.phase == "back" then
            require("OMHTT/ControlAudio").emit(object, "reel")
        elseif before == "back" or cycle.phase == "idle" then
            require("OMHTT/ControlAudio").emit(object, "stop")
            if cycle.phase == "reset" then
                require("OMHTT/ControlAudio").emit(object, "reset")
            end
        end
    end
    local active = cycle.phase ~= "idle"
    if state.active ~= active then
        state.active = active
        W.publish(object)
    end
    if revision ~= cycle.revision or (active and S.time - entry.sent >= 100) then S.publish(entry) end
end

---@return nil
local function advance()
    S.time = S.time + Active.step(S.clock)
end

Events.OnTick.Add(advance)
return S
